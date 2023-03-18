import 'dart:async';
import 'dart:math';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:provider/provider.dart';
import '../config/palette.dart';
import '../mqtt/MQTTManager.dart';
import '../mqtt/state/MQTTAppState.dart';
import 'package:wakelock/wakelock.dart';

import 'login.dart';

enum SmartMenu { handcuffLocation, myPosition, logout }

enum HandcuffMenu { deleteHandcuff, logout, exit }
enum BatteryLevel { high, middle, low }
enum HandcuffStatus { normal, runAway }
enum GpsStatus { disconnected, connecting, connected }


class HandcuffOnMap extends StatefulWidget {
  const HandcuffOnMap({Key? key}) : super(key: key);

  @override
  State<HandcuffOnMap> createState() => _HandcuffOnMapState();
}

class _HandcuffOnMapState extends State<HandcuffOnMap> {
  // late MQTTAppState currentAppState = MQTTAppState();
  late MQTTAppState currentAppState;
  late MQTTManager manager;

  // 어플리케이션에서 지도를 이동하기 위한 컨트롤러
  // late GoogleMapController _controller;
  Completer<GoogleMapController> _controller = Completer();

  // 지도가 시작될 때 첫 번째 위치
  final CameraPosition _initialPosition =
  const CameraPosition(target: LatLng(37.3927, 126.9741), zoom: 18);

  // 지도 클릭 시 표시할 장소에 대한 마커 목록
  final List<Marker> markers = [];
  late LatLng _latLng;

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "image/red_dot_14.png")
        .then(
          (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  addMarker(cordinate) {
    int id = Random().nextInt(1000);

    setState(() {
      markers.add(Marker(
        markerId: MarkerId(id.toString()),
        position: cordinate,
        // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        icon: markerIcon,
        // alpha: 0.5,
      ));
    });
  }

  // 내 위치
  Position? _currentPosition;
  StreamSubscription<Position>? positionStream;
  bool _publishMyCurrentLocation = false;

  // 수갑 위치
  late LatLng _currentHandcuffLocation;

  bool isHandcuffConnected = true; // 수갑과의 연결 여부
  BatteryLevel batteryLevel = BatteryLevel.middle;
  HandcuffStatus handcuffStatus = HandcuffStatus.runAway;
  GpsStatus gpsStatus = GpsStatus.disconnected; // 수갑 연결 후 GPS 연결

  late double _phoneWidth;
  late double _phoneHeight;

  @override
  void initState() {
    // 수행 중 화면이 꺼지지 않도록 설정
    Wakelock.enable();

    addCustomIcon();
    super.initState();
    print("==== 01 initState()");

    listenToLocationChanges();
  }

  @override
  void dispose() {
    // 수행 중 화면이 꺼지지 않도록 한 설정을 해제
    Wakelock.disable();
    super.dispose();

    positionStream?.cancel();
  }

  String userId = 'ID_0001';

  void _determineCurrentPosition() async {
    // Test if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      print('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print(
          'Location permissions are permanently denied, we cannot request permissions.');

      /// open app settings so that user changes permissions
      // await Geolocator.openAppSettings();
      // await Geolocator.openLocationSettings();

      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    print("Current Position $position =============");
    setState(() {
      _currentPosition = position;
    });
  }

  void _getCurrentLocation() async {
    Position position = await _determinePosition();
    print("==== 02 _getCurrentLocation()");

    final GoogleMapController controller = await _controller.future;
    _latLng = LatLng(position.latitude, position.longitude);
    controller.animateCamera(CameraUpdate.newLatLng(_latLng));
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;

    // _getCurrentLocation();
    _determineCurrentPosition();

    print(
        '>>>>>>>>>>>>>>>>>>>>>>>>>> _publishMyCurrentLocation = $_publishMyCurrentLocation');
    if (_publishMyCurrentLocation == true &&
        currentAppState.getAppConnectionState ==
            MQTTAppConnectionState.connected) {
      print('>> >> >> >> >> build >> call _publishJsonLocation');
      _publishJsonLocation();
    }

    print(
        "============= ======================== =========================== " +
            currentAppState.getLatitude.toString());
    print("============= ======================== ===================== " +
        currentAppState.getLongitude.toString());
    _currentHandcuffLocation =
        LatLng(currentAppState.getLatitude, currentAppState.getLongitude);
    if (currentAppState.getAppConnectionState ==
        MQTTAppConnectionState.connected) {
      addMarker(_currentHandcuffLocation);
    }

    _phoneHeight = MediaQuery.of(context).size.height;
    _phoneWidth = MediaQuery.of(context).size.width;

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
          // PopupMenuButton(
          //     icon: const Icon(
          //       Icons.menu,
          //       color: Palette.whiteTextColor,
          //     ),
          //     color: Palette.lightButtonColor,
          //     onSelected: (item) => _selectedActionMenuItem(context, item),
          //     itemBuilder: (context) =>
          //     [
          //       PopupMenuItem<HandcuffMenu>(
          //           value: HandcuffMenu.logout,
          //           child: Text(
          //             "로그아웃",
          //             style: GoogleFonts.notoSans(
          //               textStyle: const TextStyle(
          //                 color: Palette.darkTextColor,
          //                 fontSize: 16,
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //           )),
          //       PopupMenuItem<HandcuffMenu>(
          //           value: HandcuffMenu.exit,
          //           child: Text(
          //             "앱 종료",
          //             style: GoogleFonts.notoSans(
          //               textStyle: const TextStyle(
          //                 color: Palette.darkTextColor,
          //                 fontSize: 16,
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //           ))
          //     ]),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            // initialCameraPosition: CameraPosition(target: LatLng(currentAppState.getLatitude, currentAppState.getLongitude), zoom: 13),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _controller.complete(controller);
              });
            },
            markers: markers.toSet(),

            onTap: (cordinate) {
              _displayPositionOnTab(cordinate);
            },
          ),

          // ON, 상, 마지막 위치 표시
          Positioned(
            top: 20,
            child: Container(
              width: _phoneWidth - 40,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              // decoration: BoxDecoration(
              //   color: Colors.orange,
              //   borderRadius: BorderRadius.circular(7.0),
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.black.withOpacity(0.3),
              //       blurRadius: 15,
              //       spreadRadius: 5,
              //     ),
              //   ],
              // ),
              decoration: BoxDecoration(
                color: (handcuffStatus == HandcuffStatus.runAway)
                    ? Palette.emergencyColor
                    : Palette.lightButtonColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    isHandcuffConnected ? 'ON' : 'OFF',
                    style: GoogleFonts.notoSans(
                      textStyle: TextStyle(
                        color: isHandcuffConnected
                            ? Palette.darkTextColor
                            : Palette.whiteTextColor,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Text(
                    !isHandcuffConnected
                        ? '-'
                        : batteryLevel == BatteryLevel.high
                        ? '상 '
                        : batteryLevel == BatteryLevel.middle
                        ? '중'
                        : batteryLevel == BatteryLevel.low
                        ? '하'
                        : '-',
                    style: GoogleFonts.notoSans(
                      textStyle: TextStyle(
                        color: isHandcuffConnected
                            ? Palette.darkTextColor
                            : Palette.whiteTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                    },
                    child: Text(
                      !isHandcuffConnected ||
                          gpsStatus == GpsStatus.disconnected
                          ? '마지막 위치'
                          : gpsStatus == GpsStatus.connected
                          ? '위치확인'
                          : '위치확인중...',
                      style: GoogleFonts.notoSans(
                        textStyle: TextStyle(
                          color: isHandcuffConnected
                              ? Palette.darkTextColor
                              : Palette.whiteTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
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

      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment:
            Alignment(Alignment.bottomLeft.x + 0.4, Alignment.bottomLeft.y - 0.02),
            child: FloatingActionButton(
              heroTag: "btn1",
              // onPressed: listenToLocationChanges,
              onPressed: _displayMyPosition,
              tooltip: '나의 위치로 가기',
              backgroundColor: Colors.black,
              // child: const Icon(Icons.add_location, color: Colors.white,),
              child: const Text("ME", style: TextStyle(color: Colors.white, fontSize: 16),),
            ),
          ),

          Align(
            alignment:
              Alignment(Alignment.center.x, Alignment.bottomCenter.y - 0.02),
            child: FloatingActionButton(
              heroTag: "btn2",
              onPressed: _displayHandcuffPosition,
              tooltip: '수갑 알람 울리기',
              // child: const Icon(Icons.handshake),
              backgroundColor: Colors.black,
              child: const Icon(Icons.alarm_on, color: Colors.white,),
            ),
          ),

          Align(
            alignment: Alignment(Alignment.bottomRight.x -0.4, Alignment.bottomRight.y - 0.02),
            child: FloatingActionButton(
              heroTag: "btn3",
              onPressed: _displayHandcuffPosition,
              tooltip: '수갑 위치로 가기',
              backgroundColor: Colors.black,
              child: const Text("ON", style: TextStyle(color: Colors.white, fontSize: 16),),
            ),
          )
        ],
      ),
    );
  }

  void SelectedActionMenuItem(BuildContext context, item) {
    switch (item) {
      case SmartMenu.handcuffLocation:
        print('SelectedActionMenuItem::_configureAndConnect');
        showToast("수갑 위치 받는 중!!!");
        _configureAndConnect();
        break;
      case SmartMenu.myPosition:
        print('SelectedActionMenuItem::_publishMyLocation');
        showToast("나의 위치 전송 중!!!");
        _sendConfigureAndConnect();
        _publishMyLocation();
        break;
      case SmartMenu.logout:
        print('SelectedActionMenuItem::로그아웃');
        break;
    }
  }

  String _distanceBetweenMeAndHandcuff() {
    if (_currentPosition == null) {
      return '0';
    }

    double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _currentHandcuffLocation.latitude,
        _currentHandcuffLocation.longitude);
    var distance = distanceInMeters.round().toString();
    print(distance);
    return distance;
  }

  void _publishMyLocation() {
    // showToast("내 위치 전송");

    // listenToLocationChanges();

    // toggling status
    if (_publishMyCurrentLocation == false) {
      _publishMyCurrentLocation = true;
      print('++++++++++++++++++++++++ publishMyCurrentLocation is TRUE');
    } else {
      _publishMyCurrentLocation = false;
      if (positionStream != null) {
        positionStream?.cancel();
      }
    }
  }

  void showToast(String toastMessage) {
    Fluttertoast.showToast(
        msg: toastMessage,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        fontSize: 20,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT);
  }

  void listenToLocationChanges() {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 100,
    );

    print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
              (Position? position) {
            print(position == null ? 'Unknown' : '$position');

            setState(() {
              if (position != null) {
                print(
                    '>> >> >> >> >> listenToLocationChanges(): setState current poistion = $position');
                _currentPosition = position;

                if (_publishMyCurrentLocation == true &&
                    currentAppState.getAppConnectionState ==
                        MQTTAppConnectionState.connected) {
                  var publishingText = _currentPosition!.latitude.toString() +
                      ' ' +
                      _currentPosition!.longitude.toString();
                  print('>> >> >> >> >> publishingText = $publishingText');
                  manager.publish(publishingText);
                }
              }
              ;
            });
          },
        );
  }

  Future<void> _displayHandcuffPosition() async {
    final GoogleMapController controller = await _controller.future;

    // _latLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    controller.animateCamera(CameraUpdate.newLatLng(_currentHandcuffLocation));
    print("현재 수갑 위치로 가기 =================== >> >> $_currentHandcuffLocation");
  }

  Future<void> _displayMyPosition() async {
    final GoogleMapController controller = await _controller.future;
    _latLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    controller.animateCamera(CameraUpdate.newLatLng(_latLng));
    print("_displayMyPosition >> >> $_latLng");
  }

  Future<void> _displayPositionOnTab(cordinate) async {
    final GoogleMapController controller = await _controller.future;
    _latLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    controller.animateCamera(CameraUpdate.newLatLng(_latLng));
    print("-----------===== >> >> $_latLng");
  }

  void _configureAndConnect() {
    var randomId = Random().nextInt(1000) + 1;
    manager = MQTTManager(
        host: "13.124.88.113",
        // host: "192.168.0.7",
        topic: "myTopic",
        identifier: 'CJS_HandcuffTest_$randomId',
        state: currentAppState);
    manager.initializeMQTTClient();
    manager.receiveDataFromHandcuff = true;
    manager.connect();
  }

  void _sendConfigureAndConnect() {
    var randomId = Random().nextInt(1000) + 1;
    manager = MQTTManager(
        host: "13.124.88.113",
        // host: "192.168.0.7",
        topic: "myTopic",
        identifier: 'CJS_HandcuffTest_$randomId',
        state: currentAppState);
    manager.initializeMQTTClient();
    manager.receiveDataFromHandcuff = false;
    manager.connect();
  }

  void _disconnect() {
    manager.disconnect();
  }

  void _publishJsonLocation() {
    String publishingText = '''
    {
      "message" : {
        "serialNumber" : "H0001",
        "latitude" : ${_currentPosition!.latitude.toString()},
        "longitude" : ${_currentPosition!.longitude.toString()}
       }
    }''';
    print(
        '============================ ============> publishingText = $publishingText');
    manager.publish(publishingText);
  }

  void _publishLocation() {
    var publishingText = _currentPosition!.latitude.toString() +
        ' ' +
        _currentPosition!.longitude.toString();

    print(
        '============================ ============> publishingText = $publishingText');
    manager.publish(publishingText);
  }

  void _publishMessage(String text) {
    manager.publish(text);
  }

  void _selectedActionMenuItem(BuildContext context, item) {
    switch (item) {
      case HandcuffMenu.logout:
      // 모든 페이지를 제거 후 지정한 페이지를 push
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false);
        break;
      case HandcuffMenu.exit:
        _exitApp();
    }
  }

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

  void _showToast(String toastMessage) {
    Fluttertoast.showToast(
      msg: toastMessage,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Palette.lightButtonColor,
      fontSize: 16,
      textColor: Palette.darkTextColor,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}

enum _PositionItemType {
  log,
  position,
}

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}
