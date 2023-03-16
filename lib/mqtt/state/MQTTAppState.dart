import 'dart:convert';

import 'package:flutter/material.dart';

import '../../service/handcuff_data.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier{
  MQTTAppConnectionState _appConnectionState = MQTTAppConnectionState.disconnected;
  String _receivedText = '';
  String _historyText = '';
  // the location of Terraone Headoffice
  double _latitude = 37.3927;
  double _longitude = 126.9741;

  void setReceivedText(String text) {
    _receivedText = text;
    _historyText = _historyText + '\n' + _receivedText;

    print('Received Text ==> $text');

    _latitude = double.tryParse(_receivedText.split(' ')[0])!;
    _longitude = double.tryParse(_receivedText.split(' ')[1])!;


    print('_latitude == == > $_latitude');
    print('_longitude == == > $_longitude');
    notifyListeners();
  }

  void setReceivedJsonString(String jsonString) {

    print('Received Text ==> $jsonString');

    final jsonResponse = jsonDecode(jsonString);
    HandcuffData handcuffData = HandcuffData.fromJson(jsonResponse);

    _latitude = handcuffData.locationMessage.latitude;
    _longitude = handcuffData.locationMessage.longitude;

    print('_latitude form JSON == == > $_latitude');
    print('_longitude form JSON == == > $_longitude');
    notifyListeners();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;
  double get getLatitude => _latitude;
  double get getLongitude => _longitude;

  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;

}