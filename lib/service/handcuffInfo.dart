import 'package:flutter/cupertino.dart';

enum HandcuffMenu { deleteHandcuff, logout, exit }
enum BatteryLevel { high, middle, low }
enum GpsStatus { disconnected, connecting, connected }
enum HandcuffStatus { normal, runAway }

class HandcuffInfo with ChangeNotifier {
  String _serialNumber = '';

  bool _isHandcuffRegistered = false;
  bool _isHandcuffConnected = true; // 수갑 등록 후 수갑과의 연결 여부
  GpsStatus _gpsStatus = GpsStatus.disconnected; // 수갑 연결 후 GPS 연결
  BatteryLevel _batteryLevel = BatteryLevel.high;
  HandcuffStatus _handcuffStatus = HandcuffStatus.runAway;

  String get serialNumber => _serialNumber;

  set serialNumber(String value) {
    _serialNumber = value;
  }

  bool get isHandcuffRegistered => _isHandcuffRegistered;

  set isHandcuffRegistered(bool value) {
    _isHandcuffRegistered = value;
    notifyListeners();
  }

  bool get isHandcuffConnected => _isHandcuffConnected;

  set isHandcuffConnected(bool value) {
    _isHandcuffConnected = value;
    notifyListeners();
  }

  GpsStatus get gpsStatus => _gpsStatus;

  set gpsStatus(GpsStatus value) {
    _gpsStatus = value;
    notifyListeners();
  }

  BatteryLevel get batteryLevel => _batteryLevel;

  set batteryLevel(BatteryLevel value) {
    _batteryLevel = value;
    notifyListeners();
  }

  HandcuffStatus get handcuffStatus => _handcuffStatus;

  set handcuffStatus(HandcuffStatus value) {
    _handcuffStatus = value;
    notifyListeners();
  }
}