import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GuardInfo extends GetxController {
  String _id = '';
  String _password = '';
  RxBool _isConnected = false.obs;
  RxBool _isSubscribed = false.obs;
  RxList<LatLng> _trackingPoints = <LatLng>[].obs; // 교도관 핸드폰의 GPS 좌표

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  RxBool get isConnected => _isConnected;

  set isConnected(RxBool value) {
    _isConnected = value;
  }

  RxBool get isSubscribed => _isSubscribed;

  set isSubscribed(RxBool value) {
    _isSubscribed = value;
  }

  RxList<LatLng> get trackingPoints => _trackingPoints;

  set trackingPoints(RxList<LatLng> value) {
    _trackingPoints = value;
  }

  void addTrackingPoints(LatLng gpsPoint) {
    _trackingPoints.add(gpsPoint);
    update();
  }

  LatLng getLastTrackingPoint() {
    return _trackingPoints.last;
  }
}