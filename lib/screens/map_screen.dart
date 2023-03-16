import 'dart:async';
import 'dart:math';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:provider/provider.dart';
import '../mqtt/MQTTManager.dart';
import '../mqtt/state/MQTTAppState.dart';
import 'package:wakelock/wakelock.dart';

enum SmartMenu { handcuffLocation, myPosition, logout }

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
    print(
        "============= ======================== ===================== " +
            currentAppState.getLongitude.toString());
    _currentHandcuffLocation =
        LatLng(currentAppState.getLatitude, currentAppState.getLongitude);
    if (currentAppState.getAppConnectionState ==
        MQTTAppConnectionState.connected) {
      addMarker(_currentHandcuffLocation);
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text('스마트 경찰수갑 위치'),
          backgroundColor: Colors.blue,
          actions: [
            PopupMenuButton(
              color: Colors.white,
              onSelected: (item) => SelectedActionMenuItem(context, item),
              itemBuilder: (context) => [
                PopupMenuItem<SmartMenu>(
                  value: SmartMenu.handcuffLocation,
                  child: Text(
                    "수갑 위치 받기",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                PopupMenuItem<SmartMenu>(
                  value: SmartMenu.myPosition,
                  child: Text(
                    "내 위치 보내기",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                // PopupMenuDivider(),
                PopupMenuItem<SmartMenu>(
                    value: SmartMenu.logout,
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text("Logout"),
                      ],
                    )),
              ],
            ),
          ]),
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
          Container(
            // width: 100,
            height: 60,
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(7.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      (_currentPosition != null)
                          ? "나의 위치:  위도 ${_currentPosition!.latitude
                          .toStringAsPrecision(6)}  경도 ${_currentPosition!.longitude.toStringAsPrecision(6)}"
                          : "나의 위치: 찾고 있는 중입니다...",
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      (_currentHandcuffLocation != null)
                          ? "수갑 위치:  위도 ${_currentHandcuffLocation.latitude.toStringAsPrecision(6)}  경도 ${_currentHandcuffLocation.longitude
                          .toStringAsPrecision(6)}"
                          : "수갑 위치: 찾고 있는 중입니다...",
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Text(
                  "" + _distanceBetweenMeAndHandcuff() + " m",
                  style: TextStyle(
                      letterSpacing: 1.0, color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment:
            Alignment(Alignment.bottomLeft.x + 0.2, Alignment.bottomLeft.y),
            child: FloatingActionButton(
              heroTag: "btn1",
              // onPressed: listenToLocationChanges,
              onPressed: _displayMyPosition,
              tooltip: '나의 위치로 가기',
              child: const Icon(Icons.add_location),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: "btn2",
              onPressed: _displayHandcuffPosition,
              tooltip: '수갑 위치로 가기',
              child: const Icon(Icons.handshake),
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
    print('============================ ============> publishingText = $publishingText');
    manager.publish(publishingText);
  }

  void _publishLocation() {
    var publishingText = _currentPosition!.latitude.toString() +
        ' ' +
        _currentPosition!.longitude.toString();

    print('============================ ============> publishingText = $publishingText');
    manager.publish(publishingText);
  }

  void _publishMessage(String text) {
    manager.publish(text);
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
