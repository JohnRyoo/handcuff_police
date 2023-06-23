import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HandcuffMenu { deleteHandcuff, logout, exit }

enum BatteryLevel { high, middle, low, unknown }

enum GpsStatus { disconnected, connecting, connected }

enum HandcuffStatus { normal, runAway }

const String brokerAddress = "13.124.88.113";

class HandcuffInfo extends GetxController {
  final RxMap<String, Handcuff> _handcuffs = <String, Handcuff>{}.obs;
  RxInt numberOfHandcuffs = 0.obs;
  RxInt numberOfConnectedHandcuffs = 0.obs;

  void makeHandcuffsFromPref() async {
    var key = "SerialNumberList";
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> serialNumberList = pref.getStringList(key) ?? [];

    for (var serialNumber in serialNumberList) {
      Handcuff handcuff = Handcuff(serialNumber: serialNumber);
      _handcuffs[serialNumber] = handcuff;
      numberOfHandcuffs++;
    }
  }

  HandcuffInfo() {
    makeHandcuffsFromPref();
  }

  int getNumberOfHandcuffs() {
    return _handcuffs.length;
  }

  RxInt getNumberOfConnectedHandcuffs() {
    numberOfConnectedHandcuffs.value = 0;
    getHandcuffsList().forEach((handcuff) {
      debugPrint(
          '[handcuffInfo] serialnumber = ${handcuff.serialNumber} handcuff.gpsStatus = ${handcuff.gpsStatus.toString()} ');
      if (handcuff.gpsStatus == GpsStatus.connected) {
        numberOfConnectedHandcuffs++;
      }
    });

    debugPrint(
        '[handcuffInfo] numberOfConnectedHandcuffs = $numberOfConnectedHandcuffs');

    return numberOfConnectedHandcuffs;
  }

  RxMap<String, Handcuff> getHandcuffsMap() {
    return _handcuffs;
  }

  List<Handcuff> getHandcuffsList() {
    return _handcuffs.values.toList();
  }

  bool isAlreadyRegistered(String serialNumber) {
    return _handcuffs.keys.contains(serialNumber);
  }

  Handcuff getHandcuff(String serialNumber) {
    return _handcuffs[serialNumber]!;
  }

  Handcuff getFirstHandcuff() {
    return getHandcuffsList().first;
  }

  void addHandcuff(String serialNumber) {
    Handcuff handcuff = Handcuff(serialNumber: serialNumber);
    _handcuffs[serialNumber] = handcuff;
    numberOfHandcuffs++;

    debugPrint('_handcuffs is added => $_handcuffs');

    // 임시로 pref에 저장
    saveSerialNumberAtPref(serialNumber);

    // update();
  }

  void removeHandcuff(String serialNumber) {
    _handcuffs.remove(serialNumber);
    numberOfHandcuffs--;

    debugPrint('_handcuffs is removed => $_handcuffs');

    // 임시로 저장된 pref에서 제거
    removeSerialNumberAtPref(serialNumber);

    // update();
  }

  Future<void> saveSerialNumberAtPref(String serialNumber) async {
    var key = "SerialNumberList";
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> serialNumberList = pref.getStringList(key) ?? [];
    serialNumberList.add(serialNumber);

    debugPrint('saved SerialNumber list at pref = $serialNumberList');

    pref.setStringList(key, serialNumberList);
  }

  Future<void> removeSerialNumberAtPref(String serialNumber) async {
    var key = "SerialNumberList";
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> serialNumberList = pref.getStringList(key) ?? [];
    serialNumberList.remove(serialNumber);

    debugPrint('removed SerialNumber list at pref = $serialNumberList');

    pref.setStringList(key, serialNumberList);
  }

  void setBatteryLevel(String serialNumber, BatteryLevel batteryLevel) {
    _handcuffs[serialNumber]!.batteryLevel = batteryLevel;

    update();
  }

  void setHandcuffStatus(String serialNumber, HandcuffStatus handcuffStatus) {
    _handcuffs[serialNumber]!.handcuffStatus = handcuffStatus;

    update();
  }

  void setGpsStatus(String serialNumber, GpsStatus gpsStatus) {
    _handcuffs[serialNumber]!.gpsStatus = gpsStatus;

    update();
  }

  void setPowerMode(String serialNumber, bool power) {
    _handcuffs[serialNumber]!.isHandcuffConnected = power;

    update();
  }
}

class Handcuff {
  late String _serialNumber;
  bool _isSubscribed = false;
  bool _isHandcuffConnected = false; // 수갑 등록 후 수갑에서 ON 메시지가 온 경우
  GpsStatus _gpsStatus = GpsStatus.disconnected; // 수갑 연결 후 GPS 연결
  BatteryLevel _batteryLevel = BatteryLevel.unknown;
  HandcuffStatus _handcuffStatus = HandcuffStatus.normal;
  late LatLng _lastLocation;
  bool _isLastLocation = false;

  List<LatLng> _trackingPoints = []; // MQTT를 통해 수신된 수갑의 좌표를 저장

  // Handcuff({required String serialNumber}) : _serialNumber = serialNumber;

  Handcuff({required String serialNumber}) {
    _serialNumber = serialNumber;
    getSavedLastLocation(serialNumber);
  }

  // DB 사용 전 preference를 이용하여 마지막 위치를 임시 저장
  Future<void> saveLastLocation(LatLng point) async {
    var key = _serialNumber;
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setStringList(
        key, [point.latitude.toString(), point.longitude.toString()]);
    _isLastLocation = true;
  }

  void getSavedLastLocation(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String>? point = pref.getStringList(key) ?? []; // null 인 경우 []

    debugPrint('[handcuffInfo] point = $point');

    if (point.length == 0) {
      _lastLocation = LatLng(0.0, 0.0);
      _isLastLocation = false;
      debugPrint('[handcuffInfo] _isLastLocation = $_isLastLocation');
    } else {
      _lastLocation = LatLng(double.parse(point![0]), double.parse(point![1]));
      _isLastLocation = true;
      debugPrint('[handcuffInfo] _isLastLocation = $_isLastLocation');
    }
  }

  void addTrackingPoints(LatLng point) {
    _trackingPoints.add(point);

    // 마지막 저장된 위치를 지정하고 저장함
    _lastLocation = point;
    saveLastLocation(point);
  }

  String get serialNumber => _serialNumber;

  set serialNumber(String value) {
    _serialNumber = value;
  }

  bool get isSubscribed => _isSubscribed;

  set isSubscribed(bool value) {
    _isSubscribed = value;
  }

  bool get isHandcuffConnected => _isHandcuffConnected;

  set isHandcuffConnected(bool value) {
    _isHandcuffConnected = value;
  }

  GpsStatus get gpsStatus => _gpsStatus;

  set gpsStatus(GpsStatus value) {
    _gpsStatus = value;
  }

  BatteryLevel get batteryLevel => _batteryLevel;

  set batteryLevel(BatteryLevel value) {
    _batteryLevel = value;
  }

  HandcuffStatus get handcuffStatus => _handcuffStatus;

  set handcuffStatus(HandcuffStatus value) {
    _handcuffStatus = value;
  }

  List<LatLng> get trackingPoints => _trackingPoints;

  set trackingPoints(List<LatLng> value) {
    _trackingPoints = value;
  }

  LatLng get lastLocation => _lastLocation;

  set lastLocation(LatLng value) {
    _lastLocation = value;
  }

  bool get isLastLocation => _isLastLocation;

  set isLastLocation(bool value) {
    _isLastLocation = value;
  }
}
