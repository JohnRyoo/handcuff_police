import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../service/handcuff_data.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier {
  MQTTAppConnectionState _appConnectionState = MQTTAppConnectionState.disconnected;
  String _receivedText = '';
  String _historyText = '';

  double _receivedLastLatitude = 0.0;

  double get receivedLastLatitude => _receivedLastLatitude;
  double _receivedLastLongitude = 0.0;

  LatLng _startLocation = const LatLng(0.0, 0.0);

  List<LatLng> _handcuffTrackingPoints = []; // MQTT를 통해 수신된 수갑의 좌표를 저장


  // void setReceivedText(String text) {
  //   _receivedText = text;
  //   _historyText = _historyText + '\n' + _receivedText;
  //
  //   print('Received Text ==> $text');
  //
  //   _latitude = double.tryParse(_receivedText.split(' ')[0])!;
  //   _longitude = double.tryParse(_receivedText.split(' ')[1])!;
  //
  //
  //   print('_latitude == == > $_latitude');
  //   print('_longitude == == > $_longitude');
  //   notifyListeners();
  // }

  void setReceivedJsonString(String jsonString) {

    debugPrint('setReceivedJsonString with $jsonString');

    final jsonResponse = jsonDecode(jsonString);
    HandcuffData handcuffData = HandcuffData.fromJson(jsonResponse);

    _receivedLastLatitude = handcuffData.locationMessage.latitude;
    _receivedLastLongitude = handcuffData.locationMessage.longitude;

    _handcuffTrackingPoints.add(LatLng(_receivedLastLatitude, _receivedLastLongitude));
    _startLocation = _handcuffTrackingPoints[0];

    debugPrint("handcuffTrackingPoints = $_handcuffTrackingPoints");

    notifyListeners();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;

  LatLng get startLocation => _startLocation;
  List<LatLng> get getHandcuffTrackingPoints => _handcuffTrackingPoints;

  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;

  double get receivedLastLongitude => _receivedLastLongitude;
}