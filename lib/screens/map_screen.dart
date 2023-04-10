import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:police/screens/component/map/map_screen_status.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import 'package:provider/provider.dart';
import '../config/palette.dart';
import '../mqtt/MQTTManager.dart';
import '../mqtt/state/MQTTAppState.dart';
import 'package:wakelock/wakelock.dart';

import '../service/handcuffInfo.dart';

enum FocusedPosition { POLICE, HANDCUFF }

class HandcuffOnMap extends StatefulWidget {
  const HandcuffOnMap({Key? key}) : super(key: key);

  @override
  State<HandcuffOnMap> createState() => _HandcuffOnMapState();
}

class _HandcuffOnMapState extends State<HandcuffOnMap> {
  late MQTTAppState currentMqttAppState;
  late MQTTManager manager;

  late bool isHandcuffRegistered;
  late bool isHandcuffConnected;
  late HandcuffStatus handcuffStatus;
  late BatteryLevel batteryLevel;

  // late GpsStatus gpsStatus;
  late GpsStatus gpsStatusFromMqtt;

  // 어플리케이션에서 지도를 이동하기 위한 컨트롤러
  final Completer<GoogleMapController> _controller = Completer();

  String userId = 'ID_0001';

  double _currentZoomValue = 16.5;

  LocationData? currentLocation;
  LocationData? startLocation;
  List<LatLng> policeTrackingPoints = []; // 스마트폰에서 식별된 GPS 좌표를 저장
  List<LatLng> handcuffTrackingPoints = []; // MQTT를 통해 수신된 수갑의 좌표를 저장
  List<LatLng> handcuffTrackingPoints2 = []; // MQTT를 통해 수신된 수갑의 좌표를 저장

  BitmapDescriptor startIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor handcuffIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor policeIcon = BitmapDescriptor.defaultMarker;

  late StreamSubscription<LocationData> locationSubscription;

  FocusedPosition focusedPosition = FocusedPosition.POLICE;

  void getCurrentLocation() async {
    Location location = Location();

    // 앱이 백그라운드에 있을 때도 location을 받을 수 있도록 enable
    location.enableBackgroundMode(enable: true);

    location.getLocation().then(
      (location) {
        currentLocation = location;
        // startLocation = location;
        debugPrint("First currentLocation = $currentLocation");

        policeTrackingPoints.add(
          LatLng(location.latitude as double, location.longitude as double),
        );
        setState(() {});
      },
    );

    GoogleMapController googleMapController = await _controller.future;

    locationSubscription = location.onLocationChanged.listen(
      (newLocation) {
        currentLocation = newLocation;
        setCustomMarkerIcon();

        policeTrackingPoints.add(
          LatLng(
              newLocation.latitude as double, newLocation.longitude as double),
        );

        if (focusedPosition == FocusedPosition.POLICE) {
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  newLocation.latitude!,
                  newLocation.longitude!,
                ),
                zoom: _currentZoomValue,
              ),
            ),
          );
        } else {
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: handcuffTrackingPoints.last,
                zoom: _currentZoomValue,
              ),
            ),
          );
        }
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "images/start.png")
        .then((icon) {
      startIcon = icon;
    });

    if (isHandcuffRegistered == true) {
      if (isHandcuffConnected == true) {
        if (handcuffStatus == HandcuffStatus.normal) {
          BitmapDescriptor.fromAssetImage(
                  ImageConfiguration.empty, "images/on_normal.png")
              .then(
            (icon) {
              handcuffIcon = icon;
            },
          );
        } else {
          BitmapDescriptor.fromAssetImage(
                  ImageConfiguration.empty, "images/on_runaway.png")
              .then(
            (icon) {
              handcuffIcon = icon;
            },
          );
        }
      } else {
        BitmapDescriptor.fromAssetImage(
                ImageConfiguration.empty, "images/off.png")
            .then(
          (icon) {
            handcuffIcon = icon;
          },
        );
      }
    }

    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "images/me.png")
        .then((icon) {
      policeIcon = icon;
    });
  }

  void _setCurrentZoomValue(CameraPosition position) {
    _currentZoomValue = position.zoom;
  }

  final int _duration = 10;
  final CountDownController _countDownController = CountDownController();
  bool isAlarmOn = false;

  // ***************************************************************************
  // ************************* MQTT ************************************
  // ***************************************************************************

  void mqttConnect() {
    var randomId = Random().nextInt(1000) + 1;
    manager = MQTTManager(
        host: "13.124.88.113",
        // host: "192.168.0.7",
        topic: "myTopic",
        identifier: 'CJS_HandcuffTest_$randomId',
        state: currentMqttAppState);
    manager.initializeMQTTClient();
    manager.receiveDataFromHandcuff = true;
    manager.connect();
  }

  @override
  void initState() {
    getCurrentLocation();
    // 수행 중 화면이 꺼지지 않도록 설정
    Wakelock.enable();
    super.initState();

    debugPrint("==== 01 initState()");
  }

  @override
  void dispose() {
    // 수행 중 화면이 꺼지지 않도록 한 설정을 해제
    Wakelock.disable();

    // 종료 시 location에서 더이상 LocationData를 받아오지 않도록 함
    locationSubscription.cancel();

    super.dispose();
  }

  // ***************************************************************************
  // ******************************* build *************************************
  // ***************************************************************************
  @override
  Widget build(BuildContext context) {
    currentMqttAppState = Provider.of<MQTTAppState>(context);

    // Keep a reference to the app state.
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   if (currentMqttAppState.getAppConnectionState ==
    //       MQTTAppConnectionState.disconnected) {
    //     debugPrint("run MQTT CONNECT!");
    //     mqttConnect();
    //   }
    // });

    handcuffTrackingPoints =
        List.from(currentMqttAppState.getHandcuffTrackingPoints);
    // handcuffTrackingPoints = currentMqttAppState.getHandcuffTrackingPoints;
    // if (handcuffTrackingPoints.isNotEmpty) {
    //   for (int i=0; i<handcuffTrackingPoints.length; i++) {
    //     handcuffTrackingPoints2[i] = handcuffTrackingPoints[i];
    //   }
    // }

    debugPrint("handcuffTrackingPoints = $handcuffTrackingPoints");
    debugPrint(
        "handcuff latitude = ${currentMqttAppState.receivedLastLatitude}");
    debugPrint(
        "handcuff longitude = ${currentMqttAppState.receivedLastLongitude}");
    // debugPrint("currentMqttAppState.getHandcuffTrackingPoints = ${currentMqttAppState.getHandcuffTrackingPoints}");

    isHandcuffRegistered = context.watch<HandcuffInfo>().isHandcuffRegistered;
    isHandcuffConnected = context.watch<HandcuffInfo>().isHandcuffConnected;
    handcuffStatus = context.watch<HandcuffInfo>().handcuffStatus;
    batteryLevel = context.watch<HandcuffInfo>().batteryLevel;
    // gpsStatus = context.watch<HandcuffInfo>().gpsStatus;
    gpsStatusFromMqtt = context.watch<MQTTAppState>().gpsStatus;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: Palette.whiteTextColor,
        ),
        centerTitle: true,
        title: Text(
          userId,
          style: const TextStyle(color: Palette.whiteTextColor),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _exitApp();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            child: Container(
              color: Palette.backgroundColor,
            ),
          ),
          currentLocation == null
              ? const Center(
                  child: Text("Loading..."),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                      zoom: 16.5),
                  polylines: {
                    // Polyline(
                    //   polylineId: const PolylineId("policeTracking"),
                    //   points: policeTrackingPoints,
                    //   color: Colors.brown.shade300,
                    //   width: 5,
                    // ),
                    Polyline(
                      polylineId: const PolylineId("handcuffTracking"),
                      points: handcuffTrackingPoints,
                      color: (handcuffStatus == HandcuffStatus.runAway)
                          ? Colors.redAccent
                          : Colors.lightBlue,
                      width: 7,
                    )
                  },
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    setState(() {
                      debugPrint('setState() in GoogleMap');
                      _controller.complete(controller);
                    });
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId("handcuffLocation"),
                      icon: handcuffIcon,
                      position: LatLng(currentMqttAppState.receivedLastLatitude,
                          currentMqttAppState.receivedLastLongitude),
                    ),
                    Marker(
                      markerId: const MarkerId("policeLocation"),
                      icon: policeIcon,
                      position: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                    ),
                    Marker(
                      markerId: const MarkerId("start"),
                      icon: startIcon,
                      position: LatLng(
                        currentMqttAppState.startLocation.latitude,
                        currentMqttAppState.startLocation.longitude,
                      ),
                    )
                  },
                  onTap: (cordinate) {
                    // _displayPositionOnTab(cordinate);
                  },
                  onCameraMove: _setCurrentZoomValue,
                ),

          // ON, 상, 마지막 위치 표시
          MapScreenStatus(),
          // 아래쪽 세개의 버튼
          Positioned(
            top: MediaQuery.of(context).size.height - 200,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _displayMyPosition();
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Center(
                        child: Text(
                          "ME",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!isAlarmOn) {
                        isAlarmOn = true;
                        _countDownController.start();
                      } else {
                        isAlarmOn = false;
                        _countDownController.reset();
                      }

                      print("Alarm ON at Handcuff!!");
                    },
                    child: CircularCountDownTimer(
                      duration: _duration,
                      initialDuration: 0,
                      controller: _countDownController,
                      height: 60,
                      width: 60,
                      ringColor: Colors.blue,
                      ringGradient: null,
                      fillColor: Colors.black,
                      fillGradient: null,
                      backgroundColor: Colors.black,
                      backgroundGradient: null,
                      strokeWidth: 6.0,
                      strokeCap: StrokeCap.round,
                      textStyle: const TextStyle(
                        fontSize: 15.0,
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                      ),
                      textFormat: CountdownTextFormat.S,
                      isReverse: true,
                      isReverseAnimation: false,
                      isTimerTextShown: true,
                      autoStart: false,
                      onStart: () {
                        debugPrint('Countdown Start!!!!');
                      },
                      onComplete: () {
                        debugPrint('Countdown End!!!!');
                      },
                      onChange: (String timeStamp) {
                        debugPrint('Countdown Changed $timeStamp');
                      },
                      timeFormatterFunction:
                          (defaultFormatterFunction, duration) {
                        if (duration.inSeconds == _duration ||
                            duration.inSeconds == 0) {
                          // return '\u{2795}'; // unicode emoji U+1F6B7
                          return 'ALARM';
                        } else {
                          return Function.apply(
                              defaultFormatterFunction, [duration]);
                        }
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _displayHandcuffPosition();
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Center(
                        child: Text(
                          "ON",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _displayMyPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      ),
    );
    focusedPosition = FocusedPosition.POLICE;
  }

  Future<void> _displayHandcuffPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(
        handcuffTrackingPoints.last,
      ),
    );
    focusedPosition = FocusedPosition.HANDCUFF;
  }

  // void _displayMyPosition() {
  //   focusedPosition = FocusedPosition.POLICE;
  // }

  // void _displayHandcuffPosition() {
  //   focusedPosition = FocusedPosition.HANDCUFF;
  // }

  Future _exitApp() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Palette.lightButtonColor,
            title: Text(
              '종료하시겠습니까?',
              style: GoogleFonts.notoSans(
                textStyle: const TextStyle(
                  color: Palette.darkTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  //아래 함수를 이용해서 앱을 종료 할 수 있다.
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                child: Text(
                  '끝내기',
                  style: GoogleFonts.notoSans(
                    textStyle: const TextStyle(
                      color: Palette.darkTextColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  '아니요',
                  style: GoogleFonts.notoSans(
                    textStyle: const TextStyle(
                      color: Palette.darkTextColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
