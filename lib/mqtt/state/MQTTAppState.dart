import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:police/service/handcuffInfo.dart';
import '../../service/guardInfo.dart';
import '../../service/handcuff_data.dart';
import 'package:get/get.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState extends GetxController {
  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.disconnected;

  late HandcuffInfo _handcuffInfo;
  late GuardInfo _guardInfo;

  MQTTAppState() {
    _handcuffInfo = Get.find();
    _guardInfo = Get.find();
  }

  String _command = '';
  String _receivedSerialNumber = '';
  double _receivedLatitude = 0.0;
  double _receivedLongitude = 0.0;
  String _batteryLevel = '';
  String _handcuffStatus = '';
  String _receivedPowerStatus = '0';

  void setReceivedText(String receivedString) {
    debugPrint('[MQTTAppState] receivedString with $receivedString');

    List<String> handcuffData = receivedString.split(' ');
    debugPrint('[MQTTAppState] handcuffData = $handcuffData');

    _command = handcuffData[0];
    _receivedSerialNumber = handcuffData[1];

    if (_handcuffInfo.isAlreadyRegistered(_receivedSerialNumber)) {
      switch (_command) {
        case '1': // power on
          if (handcuffData.length != 3) break;

          _receivedPowerStatus = handcuffData[2];

          if (_receivedPowerStatus == '1') {
            _handcuffInfo.setPowerMode(_receivedSerialNumber, true);
          } else {
            _handcuffInfo.setPowerMode(_receivedSerialNumber, false);
          }

          break;
        case '2': // MQTT data
          if (handcuffData.length != 6) break;

          // _handcuffInfo.checkConnection(_receivedSerialNumber); // 수갑과 연동 중임을 확인
          _handcuffInfo.checkEachConnection(_handcuffInfo
              .getHandcuffsMap()
              .keys
              .toList()
              .indexOf(_receivedSerialNumber));
          _receivedSerialNumber = handcuffData[1];
          _receivedLatitude = double.parse(handcuffData[2]);
          _receivedLongitude = double.parse(handcuffData[3]);

          _handcuffInfo.setPowerMode(_receivedSerialNumber, true);

          if (_receivedLatitude.abs() == 0.abs()) {
            _handcuffInfo.setGpsStatus(
                _receivedSerialNumber, GpsStatus.connecting);
            debugPrint("gpsStatus = GpsStatus.connecting");
          } else {
            _handcuffInfo.getHandcuff(_receivedSerialNumber).addTrackingPoints(
                LatLng(_receivedLatitude, _receivedLongitude));
            _handcuffInfo.setGpsStatus(
                _receivedSerialNumber, GpsStatus.connected);
            debugPrint("[MQTTAppState] gpsStatus = GpsStatus.connected");
          }
          debugPrint(
              "[MQTTAppState] _handcuffInfo.getHandcuff($_receivedSerialNumber).trackingPoints = "
              "${_handcuffInfo.getHandcuff(_receivedSerialNumber).trackingPoints}");

          _batteryLevel = handcuffData[4];

          switch (_batteryLevel) {
            case '1':
              _handcuffInfo.setBatteryLevel(
                  _receivedSerialNumber, BatteryLevel.low);
              break;
            case '2':
              _handcuffInfo.setBatteryLevel(
                  _receivedSerialNumber, BatteryLevel.middle);
              break;
            case '3':
              _handcuffInfo.setBatteryLevel(
                  _receivedSerialNumber, BatteryLevel.high);
              break;
            default:
              _handcuffInfo.setBatteryLevel(
                  _receivedSerialNumber, BatteryLevel.unknown);
          }

          _handcuffStatus = handcuffData[5];
          switch (_handcuffStatus) {
            case '0':
              _handcuffInfo.setHandcuffStatus(
                  _receivedSerialNumber, HandcuffStatus.normal);
              break;
            case '1':
              _handcuffInfo.setHandcuffStatus(
                  _receivedSerialNumber, HandcuffStatus.runAway);
              break;
            default:
              _handcuffInfo.setHandcuffStatus(
                  _receivedSerialNumber, HandcuffStatus.normal);
          }

          _handcuffInfo.getNumberOfConnectedHandcuffs();

          // notifyListeners();
          update();
          break;
        default:
      }
    } else {
      debugPrint('[MQTTAppState] No processing for received MQTT data.');
    }
  }

  void setReceivedJsonString(String jsonString) {
    debugPrint('=======================================================');
    debugPrint('setReceivedJsonString with $jsonString');

    final jsonResponse = jsonDecode(jsonString);
    HandcuffData handcuffData = HandcuffData.fromJson(jsonResponse);

    _receivedSerialNumber = handcuffData.locationMessage.serialNumber;
    _receivedLatitude = handcuffData.locationMessage.latitude;
    _receivedLongitude = handcuffData.locationMessage.longitude;

    // _handcuffInfo.setBatteryLevel('aaaaaaa', BatteryLevel.low);
    // _handcuffInfo.setHandcuffStatus('aaaaaaa', HandcuffStatus.runAway);

    if (_receivedLatitude.abs() == 0.abs()) {
      _handcuffInfo.setGpsStatus(_receivedSerialNumber, GpsStatus.connecting);
      debugPrint("gpsStatus = GpsStatus.connecting");
    } else {
      _handcuffInfo
          .getHandcuff(_receivedSerialNumber)
          .addTrackingPoints(LatLng(_receivedLatitude, _receivedLongitude));
      _handcuffInfo.setGpsStatus(_receivedSerialNumber, GpsStatus.connected);
      debugPrint("gpsStatus = GpsStatus.connected");
    }

    debugPrint(
        "_handcuffInfo.getHandcuff($_receivedSerialNumber).trackingPoints = "
        "${_handcuffInfo.getHandcuff(_receivedSerialNumber).trackingPoints}");

    // notifyListeners();
    update();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;

    debugPrint('[MQTTAppState] state = $state');
    if (state == MQTTAppConnectionState.connected) {
      _guardInfo.isConnected.value = true;
    } else if (state == MQTTAppConnectionState.disconnected) {
      _guardInfo.isConnected.value = false;
    }

    debugPrint(
        '_guardInfo.isConnected.value = ${_guardInfo.isConnected.value}');
    update();
  }

  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;
}
