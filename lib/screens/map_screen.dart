import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:police/mqtt/MQTTManager.dart';
import 'package:police/screens/component/map/map_screen_status.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import '../config/palette.dart';
import 'package:wakelock/wakelock.dart';

import '../service/guardInfo.dart';
import '../service/handcuffInfo.dart';

enum FocusedPosition { police, handcuff }

class HandcuffOnMap extends StatefulWidget {
  const HandcuffOnMap({Key? key}) : super(key: key);

  @override
  State<HandcuffOnMap> createState() => _HandcuffOnMapState();
}

class _HandcuffOnMapState extends State<HandcuffOnMap> {
  final HandcuffInfo _handcuffInfo = Get.find();
  // final MQTTAppState _mqttAppState = Get.find();
  final GuardInfo _guardInfo = Get.find();

  late MQTTManager _mqttManager;

  // 어플리케이션에서 지도를 이동하기 위한 컨트롤러
  final Completer<GoogleMapController> _controller = Completer();

  late String userId;
  late String serialNumber;
  late String userIndex;

  double _currentZoomValue = 16.5;

  LocationData? currentLocation;
  LocationData? startLocation;

  BitmapDescriptor startIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor handcuffIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor policeIcon = BitmapDescriptor.defaultMarker;

  late StreamSubscription<LocationData> locationSubscription;

  FocusedPosition focusedPosition = FocusedPosition.police;

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "images/start.png")
        .then((icon) {
      startIcon = icon;
    });

    if (_handcuffInfo.getHandcuff(serialNumber).isHandcuffConnected) {
      if (_handcuffInfo.getHandcuff(serialNumber).handcuffStatus ==
          HandcuffStatus.normal) {
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

  void getCurrentLocation() async {
    Location location = Location();

    // 앱이 백그라운드에 있을 때도 location을 받을 수 있도록 enable
    location.enableBackgroundMode(enable: true);

    location.getLocation().then(
      (location) {
        currentLocation = location;
        // startLocation = location;
        debugPrint("First currentLocation = $currentLocation");

        _guardInfo.addTrackingPoints(
            LatLng(location.latitude as double, location.longitude as double));
        setState(() {});
      },
    );

    GoogleMapController googleMapController = await _controller.future;

    locationSubscription = location.onLocationChanged.listen(
      (newLocation) {
        currentLocation = newLocation;
        setCustomMarkerIcon();

        _guardInfo.addTrackingPoints(LatLng(
            newLocation.latitude as double, newLocation.longitude as double));

        debugPrint(
            '[map_screen] guardInfo.trackingPoints = $_guardInfo.trackingPoints');

        if (focusedPosition == FocusedPosition.police) {
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
                target: _handcuffInfo.getHandcuff(serialNumber).lastLocation,
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

  @override
  void initState() {
    getCurrentLocation();
    // 수행 중 화면이 꺼지지 않도록 설정
    Wakelock.enable();

    userId = _guardInfo.id;
    serialNumber = Get.arguments['serialNumber'];
    _mqttManager = Get.arguments['mqttManager'];
    userIndex = Get.arguments['index'].toString();

    super.initState();

    debugPrint("[map_screen] initState()");
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
                    if (_handcuffInfo.getHandcuff(serialNumber).gpsStatus == GpsStatus.connected)
                    // Polyline(
                    //   polylineId: const PolylineId("policeTracking"),
                    //   points: _guardInfo.trackingPoints,
                    //   color: Colors.brown.shade300,
                    //   width: 5,
                    // ),
                    Polyline(
                      polylineId: const PolylineId("handcuffTracking"),
                      points: _handcuffInfo
                          .getHandcuff(serialNumber)
                          .trackingPoints,
                      color: (_handcuffInfo
                                  .getHandcuff(serialNumber)
                                  .handcuffStatus ==
                              HandcuffStatus.runAway)
                          ? Colors.redAccent
                          : Colors.lightBlue,
                      width: 7,
                    )
                  },
                  zoomControlsEnabled: false,
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
                      position: _handcuffInfo
                          .getHandcuff(serialNumber).lastLocation
                    ),
                    Marker(
                      markerId: const MarkerId("policeLocation"),
                      icon: policeIcon,
                      position: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                    ),
                    // if (_handcuffInfo.getHandcuff(serialNumber).gpsStatus == GpsStatus.connected)
                    // Marker(
                    //   markerId: const MarkerId("start"),
                    //   icon: startIcon,
                    //   position: _handcuffInfo
                    //       .getHandcuff(serialNumber)
                    //       .trackingPoints
                    //       .first,
                    // )
                  },
                  onTap: (cordinate) {
                    // _displayPositionOnTab(cordinate);
                  },
                  onCameraMove: _setCurrentZoomValue,
                ),

          // ON, 상, 마지막 위치 표시
          MapScreenStatus(serialNumber: serialNumber, userIndex: userIndex),

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
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Center(
                        child: Text(
                          "내위치",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
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
                        _mqttManager.publishToHandcuff(serialNumber, '6 $serialNumber 1');
                      } else {
                        isAlarmOn = false;
                        _countDownController.reset();
                        _mqttManager.publishToHandcuff(serialNumber, '6 $serialNumber 0');
                      }

                      debugPrint("Alarm ON at Handcuff!!");
                    },
                    child: CircularCountDownTimer(
                      duration: _duration,
                      initialDuration: 0,
                      controller: _countDownController,
                      height: 59,
                      width: 59,
                      ringColor: Palette.lightButtonColor,
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
                        _mqttManager.publishToHandcuff(serialNumber, '6 $serialNumber 0');
                      },
                      onChange: (String timeStamp) {
                        debugPrint('Countdown Changed $timeStamp');
                      },
                      timeFormatterFunction:
                          (defaultFormatterFunction, duration) {
                        if (duration.inSeconds == _duration ||
                            duration.inSeconds == 0) {
                          // return '\u{2795}'; // unicode emoji U+1F6B7
                          return '알람';
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
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          userIndex.padLeft(2, '0'),
                          style: TextStyle(color: Colors.white, fontSize: 15),
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
    debugPrint('[map_screen] _displayMyPosition : _currentZoomValue = $_currentZoomValue');
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        _currentZoomValue,
      ),
    );
    focusedPosition = FocusedPosition.police;
  }

  Future<void> _displayHandcuffPosition() async {
    final GoogleMapController controller = await _controller.future;
    debugPrint('[map_screen] _displayHandcuffPosition : _currentZoomValue = $_currentZoomValue');
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        _handcuffInfo.getHandcuff(serialNumber).lastLocation,
        _currentZoomValue,
      ),
    );
    focusedPosition = FocusedPosition.handcuff;
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
