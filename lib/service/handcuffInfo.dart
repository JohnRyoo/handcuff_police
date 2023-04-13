import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:police/mqtt/MQTTManager.dart';
import 'package:police/mqtt/state/MQTTAppState.dart';
// import 'package:police/service/handcuff_watchdog.dart';

enum HandcuffMenu { deleteHandcuff, logout, exit }

enum BatteryLevel { high, middle, low }

enum GpsStatus { disconnected, connecting, connected }

enum HandcuffStatus { normal, runAway }

const String brokerAddress = "13.124.88.113";

class HandcuffInfo with ChangeNotifier {
  final List<Handcuff> handcuffs = <Handcuff>[];
  MQTTAppState mqttAppState = MQTTAppState();

  // final HandcuffWatchdog handcuffWatchdog = HandcuffWatchdog();

  // final List<MQTTManager> mqttManagers = <MQTTManager>[];
  // final List<MQTTAppState> mqttAppStates = <MQTTAppState>[];

  // int _numberOfRegisteredHandcuff = 0;
  //
  // int get numberOfRegisteredHandcuff => _numberOfRegisteredHandcuff;
  //
  // set numberOfRegisteredHandcuff(int value) {
  //   _numberOfRegisteredHandcuff = value;
  //   notifyListeners();
  // }

  void addHandcuff(String serialNumber) {
    // Handcuff handcuff = Handcuff(watchdog:handcuffWatchdog);
    Handcuff handcuff = Handcuff(mqttAppState: mqttAppState);

    handcuff.serialNumber = serialNumber;
    handcuff.mqttConnect();
    handcuff.isHandcuffRegistered = true;

    handcuffs.add(handcuff);

    // MQTTAppState mqttAppState = MQTTAppState();
    // mqttAppStates.add(mqttAppState);
    //
    // var randomId = Random().nextInt(1000) + 1;
    // MQTTManager mqttManager = MQTTManager(
    //     host: brokerAddress,
    //     topic: serialNumber,
    //     identifier: 'CPH_$randomId', // CPH : CJS_Prison_Handcuff
    //     state: mqttAppState);
    // mqttManager.initializeMQTTClient();
    // mqttManager.receiveDataFromHandcuff = true;
    // mqttManager.connect();
    // mqttManagers.add(mqttManager);

    notifyListeners();
  }

  void removeHandcuff(int index) {
    handcuffs[index].mqttDisconnect();
    handcuffs.removeAt(index);

    notifyListeners();
  }
}

class Handcuff {
  // final HandcuffWatchdog _handcuffWatchdog;
  //
  // Handcuff({required HandcuffWatchdog watchdog})
  //     : _handcuffWatchdog = watchdog;

  final MQTTAppState _mqttAppState;
  Handcuff({required MQTTAppState mqttAppState})
      : _mqttAppState = mqttAppState;

  String serialNumber = '';
  late MQTTManager mqttManager;
  final MQTTAppState mqttAppState = MQTTAppState();

  void mqttConnect() {
    var randomId = Random().nextInt(1000) + 1;
    mqttManager = MQTTManager(
        host: brokerAddress,
        topic: serialNumber,
        identifier: 'CPH_$randomId', // CPH : CJS_Prison_Handcuff
        state: mqttAppState);
    mqttManager.initializeMQTTClient();
    mqttManager.receiveDataFromHandcuff = true;
    mqttManager.connect();
  }

  void mqttDisconnect() {
    mqttManager.disconnect();
  }

  bool _isHandcuffRegistered = false;
  bool _isHandcuffConnected = true; // 수갑 등록 후 수갑에서 ON 메시지가 온 경우
  GpsStatus _gpsStatus = GpsStatus.disconnected; // 수갑 연결 후 GPS 연결
  BatteryLevel _batteryLevel = BatteryLevel.high;
  HandcuffStatus _handcuffStatus = HandcuffStatus.normal;

  bool get isHandcuffRegistered => _isHandcuffRegistered;

  set isHandcuffRegistered(bool value) {
    _isHandcuffRegistered = value;
    // notifyListeners();
  }

  bool get isHandcuffConnected => _isHandcuffConnected;

  set isHandcuffConnected(bool value) {
    _isHandcuffConnected = value;
    // notifyListeners();
  }

  GpsStatus get gpsStatus => _gpsStatus;

  set gpsStatus(GpsStatus value) {
    _gpsStatus = value;
    // notifyListeners();
  }

  BatteryLevel get batteryLevel => _batteryLevel;

  set batteryLevel(BatteryLevel value) {
    _batteryLevel = value;
    // notifyListeners();
  }

  HandcuffStatus get handcuffStatus => _handcuffStatus;

  set handcuffStatus(HandcuffStatus value) {
    _handcuffStatus = value;
    // notifyListeners();
  }
}
