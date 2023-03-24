import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:police/screens/component/map/map_screen_status.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import 'package:provider/provider.dart';
import '../config/palette.dart';
import '../mqtt/MQTTManager.dart';
import '../mqtt/state/MQTTAppState.dart';
import 'package:wakelock/wakelock.dart';

import '../service/handcuffInfo.dart';
import 'login.dart';

// enum SmartMenu { handcuffLocation, myPosition, logout }
//
// enum HandcuffMenu { deleteHandcuff, logout, exit }
//
// enum BatteryLevel { high, middle, low }
//
// enum HandcuffStatus { normal, runAway }
//
// enum GpsStatus { disconnected, connecting, connected }
class HandcuffOnMap extends StatefulWidget {
  const HandcuffOnMap({Key? key}) : super(key: key);

  @override
  State<HandcuffOnMap> createState() => _HandcuffOnMapState();
}

class _HandcuffOnMapState extends State<HandcuffOnMap> {
  // late MQTTAppState currentAppState = MQTTAppState();
  late MQTTAppState currentAppState;
  late MQTTManager manager;

  late bool isHandcuffRegistered;
  late bool isHandcuffConnected;
  late HandcuffStatus handcuffStatus;
  late BatteryLevel batteryLevel;
  late GpsStatus gpsStatus;

  // 어플리케이션에서 지도를 이동하기 위한 컨트롤러
  final Completer<GoogleMapController> _controller = Completer();

  late LatLng _latLng;

  // 내 위치
  Position? _currentPosition;
  StreamSubscription<Position>? positionStream;
  bool _publishMyCurrentLocation = false;

  // 수갑 위치
  late LatLng _currentHandcuffLocation;

  // bool isHandcuffConnected = true; // 수갑과의 연결 여부
  // BatteryLevel batteryLevel = BatteryLevel.middle;
  // HandcuffStatus handcuffStatus = HandcuffStatus.runAway;
  // GpsStatus gpsStatus = GpsStatus.disconnected; // 수갑 연결 후 GPS 연결

  late double _phoneWidth;
  late double _phoneHeight;

  @override
  void initState() {
    getCurrentLocation();
    // 수행 중 화면이 꺼지지 않도록 설정
    Wakelock.enable();
    // getPolyPoints();
    super.initState();
    print("==== 01 initState()");

    // listenToLocationChanges();
  }

  // void listenToLocationChanges() {
  //   const LocationSettings locationSettings = LocationSettings(
  //     accuracy: LocationAccuracy.best,
  //     distanceFilter: 100,
  //   );
  //
  //   debugPrint("==== 02 listenToLocationChanges() in initState()");
  //   positionStream =
  //       Geolocator.getPositionStream(locationSettings: locationSettings).listen(
  //     (Position? position) {
  //       debugPrint('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  //       debugPrint(position == null ? 'Unknown' : 'position = $position');
  //
  //       setState(() {
  //         if (position != null) {
  //           debugPrint(
  //               '>> listenToLocationChanges() >> setState >> current position = $position');
  //           _currentPosition = position;
  //
  //           // 서버로 조회된 내 위치를 전송
  //           if (_publishMyCurrentLocation == true &&
  //               currentAppState.getAppConnectionState ==
  //                   MQTTAppConnectionState.connected) {
  //             var publishingText =
  //                 '${_currentPosition!.latitude} ${_currentPosition!.longitude}';
  //             debugPrint('>> >> publishingText = $publishingText');
  //             manager.publish(publishingText);
  //           }
  //         }
  //       });
  //     },
  //   );
  // }

  // @override
  // void dispose() {
  //   // 수행 중 화면이 꺼지지 않도록 한 설정을 해제
  //   Wakelock.disable();
  //   super.dispose();
  //
  //   // positionStream?.cancel();
  // }

  String userId = 'ID_0001';

  // void _determineCurrentPosition() async {
  //   // Test if location services are enabled.
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     print('Location services are disabled.');
  //     return;
  //   }
  //
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       print('Location permissions are denied');
  //       return;
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     print(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //
  //     /// open app settings so that user changes permissions
  //     // await Geolocator.openAppSettings();
  //     // await Geolocator.openLocationSettings();
  //
  //     return;
  //   }
  //
  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //   Position position = await Geolocator.getCurrentPosition();
  //   print("Current Position $position =============");
  //   setState(() {
  //     _currentPosition = position;
  //   });
  // }

  LocationData? currentLocation;
  LocationData? startLocation;

  void getCurrentLocation() async {
    Location location = Location();

    // context.watch<HandcuffInfo>().gpsStatus = GpsStatus.connecting;

    location.getLocation().then(
      (location) {
        currentLocation = location;
        startLocation = location;
        debugPrint("First currentLocation = $currentLocation");
        // context.watch<HandcuffInfo>().gpsStatus = GpsStatus.disconnected;
        trackingPoints.add(
          LatLng(location.latitude as double, location.longitude as double),
        );
        setState(() {});
      },
    );

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen(
      (newLocation) {
        currentLocation = newLocation;

        trackingPoints.add(
          LatLng(
              newLocation.latitude as double, newLocation.longitude as double),
        );

        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                newLocation.latitude!,
                newLocation.longitude!,
              ),
              zoom: 14.5,
            ),
          ),
        );

        setState(() {});
      },
    );
  }

  // void _getCurrentLocation() async {
  //   Position position = await _determinePosition();
  //   print("==== 02 _getCurrentLocation()");
  //
  //   final GoogleMapController controller = await _controller.future;
  //   _latLng = LatLng(position.latitude, position.longitude);
  //   controller.animateCamera(CameraUpdate.newLatLng(_latLng));
  // }

  // Future<Position> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled.');
  //   }
  //
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //
  //   return await Geolocator.getCurrentPosition();
  // }

  final int _duration = 10;
  final CountDownController _countDownController = CountDownController();
  bool isAlarmOn = false;

  // List<LatLng> polylineCoordinates = [];
  List<LatLng> trackingPoints = [];

  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.0660055);

  void getPolyPoints() {
    List<LatLng> loc = [];

    if (trackingPoints.isNotEmpty) {
      for (var point in trackingPoints) {
        loc.add(
          LatLng(point.latitude, point.longitude),
        );
      }
    }
  }

  // void _getPolyPoints() async {
  //   PolylinePoints polylinePoints = PolylinePoints();
  //
  //   // LatLng startPoint = LatLng(
  //   //     startLocation!.latitude as double, startLocation!.longitude as double);
  //   // LatLng currentPoint = LatLng(currentLocation!.latitude as double,
  //   //     currentLocation!.longitude as double);
  //
  //   // debugPrint("startPoint = $startPoint");
  //   debugPrint("sourceLocation = $sourceLocation");
  //   debugPrint("destination = $destination");
  //   debugPrint("currentLocation in getPolyPoints = ${currentLocation}");
  //
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     "AIzaSyBJRyeCle74Hzx6WiWG0vtb_iZw-JNNQZY",
  //     // PointLatLng(startPoint.latitude, startPoint.longitude),
  //     // PointLatLng(currentLocation?.latitude as double,
  //     //     currentLocation?.longitude as double),
  //     PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
  //     PointLatLng(destination.latitude, destination.longitude),
  //   );
  //
  //   debugPrint("--- ${result.points.length}");
  //
  //   if (result.points.isNotEmpty) {
  //     for (var point in result.points) {
  //       polylineCoordinates.add(
  //         LatLng(point.latitude, point.longitude),
  //       );
  //     }
  //
  //     debugPrint("polylineCoordinates = $polylineCoordinates");
  //
  //     setState(() {});
  //   }
  // }

  // ***************************************************************************
  // ******************************* build *************************************
  // ***************************************************************************
  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;

    // _getCurrentLocation();
    // _determineCurrentPosition();

    // debugPrint('>> _publishMyCurrentLocation at builder = $_publishMyCurrentLocation');
    // if (_publishMyCurrentLocation == true &&
    //     currentAppState.getAppConnectionState ==
    //         MQTTAppConnectionState.connected) {
    //   debugPrint('>> >> call _publishJsonLocation at build');
    //   _publishJsonLocation();
    // }

    // debugPrint(">> 현재 위도 ${currentAppState.getLatitude}");
    // debugPrint(">> 현재 경도 ${currentAppState.getLongitude}");

    // _currentHandcuffLocation =
    //     LatLng(currentAppState.getLatitude, currentAppState.getLongitude);
    // if (currentAppState.getAppConnectionState ==
    //     MQTTAppConnectionState.connected) {
    //   addMarker(_currentHandcuffLocation);
    // }

    // debugPrint('_currentPosition == ${_currentPosition}');

    // if (currentLocation != null && isFirst == true) {
    //   startLocation = currentLocation;
    //   isFirst = false;
    // }

    _phoneHeight = MediaQuery.of(context).size.height;
    _phoneWidth = MediaQuery.of(context).size.width;

    debugPrint("trackingLocations = $trackingPoints");

    isHandcuffRegistered = context.watch<HandcuffInfo>().isHandcuffRegistered;
    isHandcuffConnected = context.watch<HandcuffInfo>().isHandcuffConnected;
    handcuffStatus = context.watch<HandcuffInfo>().handcuffStatus;
    batteryLevel = context.watch<HandcuffInfo>().batteryLevel;
    gpsStatus = context.watch<HandcuffInfo>().gpsStatus;

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
                      zoom: 14.5),
                  polylines: {
                    Polyline(
                      polylineId: PolylineId("route"),
                      points: trackingPoints,
                      color: (handcuffStatus == HandcuffStatus.runAway)
                          ? Colors.redAccent
                          : Colors.lightBlue,
                      width: 8,
                    )
                  },
                  mapType: MapType.normal,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    setState(() {
                      debugPrint('setState() in GoogleMap');
                      _controller.complete(controller);
                    });
                  },
                  // markers: markers.toSet(),
                  markers: {
                    Marker(
                      markerId: const MarkerId("currentLocation"),
                      position: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                    ),
                    Marker(
                      markerId: const MarkerId("start"),
                      position: LatLng(
                        startLocation!.latitude!,
                        startLocation!.longitude!,
                      ),
                    )
                  },
                  onTap: (cordinate) {
                    // _displayPositionOnTab(cordinate);
                  },
                ),

          // ON, 상, 마지막 위치 표시
          MapScreenStatus(),
          // 아래쪽 세개의 버튼
          Positioned(
            top: _phoneHeight - 200,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _displayMyPosition();
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
                      ringColor: Colors.grey,
                      ringGradient: null,
                      fillColor: Colors.black,
                      fillGradient: null,
                      backgroundColor: Colors.black,
                      backgroundGradient: null,
                      strokeWidth: 6.0,
                      strokeCap: StrokeCap.round,
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
                          return '\u{2795}'; // unicode emoji U+1F6B7
                        } else {
                          return Function.apply(
                              defaultFormatterFunction, [duration]);
                        }
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // _displayHandcuffPosition();
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

  // void selectedActionMenuItem(BuildContext context, item) {
  //   switch (item) ㅇ{
  //     case SmartMenu.handcuffLocation:
  //       print('SelectedActionMenuItem::_configureAndConnect');
  //       showToast("수갑 위치 받는 중!!!");
  //       _configureAndConnect();
  //       break;
  //     case SmartMenu.myPosition:
  //       print('SelectedActionMenuItem::_publishMyLocation');
  //       showToast("나의 위치 전송 중!!!");
  //       _sendConfigureAndConnect();
  //       _publishMyLocation();
  //       break;
  //     case SmartMenu.logout:
  //       print('SelectedActionMenuItem::로그아웃');
  //       break;
  //   }
  // }

  // String _distanceBetweenMeAndHandcuff() {
  //   if (_currentPosition == null) {
  //     return '0';
  //   }
  //
  //   double distanceInMeters = Geolocator.distanceBetween(
  //       _currentPosition!.latitude,
  //       _currentPosition!.longitude,
  //       _currentHandcuffLocation.latitude,
  //       _currentHandcuffLocation.longitude);
  //   var distance = distanceInMeters.round().toString();
  //   print(distance);
  //   return distance;
  // }
  //
  // void _publishMyLocation() {
  //   // showToast("내 위치 전송");
  //
  //   // listenToLocationChanges();
  //
  //   // toggling status
  //   if (_publishMyCurrentLocation == false) {
  //     _publishMyCurrentLocation = true;
  //     print('++++++++++++++++++++++++ publishMyCurrentLocation is TRUE');
  //   } else {
  //     _publishMyCurrentLocation = false;
  //     if (positionStream != null) {
  //       positionStream?.cancel();
  //     }
  //   }
  // }

  // void showToast(String toastMessage) {
  //   Fluttertoast.showToast(
  //       msg: toastMessage,
  //       gravity: ToastGravity.BOTTOM,
  //       backgroundColor: Colors.redAccent,
  //       fontSize: 20,
  //       textColor: Colors.white,
  //       toastLength: Toast.LENGTH_SHORT);
  // }

  // Future<void> _displayHandcuffPosition() async {
  //   final GoogleMapController controller = await _controller.future;
  //
  //   // _latLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
  //
  //   controller.animateCamera(CameraUpdate.newLatLng(_currentHandcuffLocation));
  //   print("현재 수갑 위치로 가기 =================== >> >> $_currentHandcuffLocation");
  // }

  Future<void> _displayMyPosition() async {
    final GoogleMapController controller = await _controller.future;
    _latLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    controller.animateCamera(CameraUpdate.newLatLng(_latLng));
    print("_displayMyPosition >> >> $_latLng");
  }

  // Future<void> _displayPositionOnTab(cordinate) async {
  //   final GoogleMapController controller = await _controller.future;
  //   _latLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
  //   controller.animateCamera(CameraUpdate.newLatLng(_latLng));
  //   print("-----------===== >> >> $_latLng");
  // }

  // void _configureAndConnect() {
  //   var randomId = Random().nextInt(1000) + 1;
  //   manager = MQTTManager(
  //       host: "13.124.88.113",
  //       // host: "192.168.0.7",
  //       topic: "myTopic",
  //       identifier: 'CJS_HandcuffTest_$randomId',
  //       state: currentAppState);
  //   manager.initializeMQTTClient();
  //   manager.receiveDataFromHandcuff = true;
  //   manager.connect();
  // }
  //
  // void _sendConfigureAndConnect() {
  //   var randomId = Random().nextInt(1000) + 1;
  //   manager = MQTTManager(
  //       host: "13.124.88.113",
  //       // host: "192.168.0.7",
  //       topic: "myTopic",
  //       identifier: 'CJS_HandcuffTest_$randomId',
  //       state: currentAppState);
  //   manager.initializeMQTTClient();
  //   manager.receiveDataFromHandcuff = false;
  //   manager.connect();
  // }
  //
  // void _disconnect() {
  //   manager.disconnect();
  // }
  //
  // void _publishJsonLocation() {
  //   String publishingText = '''
  //   {
  //     "message" : {
  //       "serialNumber" : "H0001",
  //       "latitude" : ${_currentPosition!.latitude.toString()},
  //       "longitude" : ${_currentPosition!.longitude.toString()}
  //      }
  //   }''';
  //   print(
  //       '============================ ============> publishingText = $publishingText');
  //   manager.publish(publishingText);
  // }
  //
  // void _publishLocation() {
  //   var publishingText = _currentPosition!.latitude.toString() +
  //       ' ' +
  //       _currentPosition!.longitude.toString();
  //
  //   print(
  //       '============================ ============> publishingText = $publishingText');
  //   manager.publish(publishingText);
  // }
  //
  // void _publishMessage(String text) {
  //   manager.publish(text);
  // }
  //
  // void _selectedActionMenuItem(BuildContext context, item) {
  //   switch (item) {
  //     case HandcuffMenu.logout:
  //       // 모든 페이지를 제거 후 지정한 페이지를 push
  //       Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(builder: (context) => const LoginScreen()),
  //           (route) => false);
  //       break;
  //     case HandcuffMenu.exit:
  //       _exitApp();
  //   }
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

  // void _showToast(String toastMessage) {
  //   Fluttertoast.showToast(
  //     msg: toastMessage,
  //     gravity: ToastGravity.BOTTOM,
  //     backgroundColor: Palette.lightButtonColor,
  //     fontSize: 16,
  //     textColor: Palette.darkTextColor,
  //     toastLength: Toast.LENGTH_SHORT,
  //   );
  // }
}

// enum _PositionItemType {
//   log,
//   position,
// }
//
// class _PositionItem {
//   _PositionItem(this.type, this.displayValue);
//
//   final _PositionItemType type;
//   final String displayValue;
// }
