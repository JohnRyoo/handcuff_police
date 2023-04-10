import 'dart:convert';

class HandcuffData {
  LocationMessage locationMessage;

  HandcuffData({
    required this.locationMessage
  });

  factory HandcuffData.fromJson(Map<String, dynamic> parsedJson){
    return HandcuffData(
        locationMessage: LocationMessage.fromJson(parsedJson['message'])
    );
  }
}

class LocationMessage {
  String serialNumber;
  double latitude;
  double longitude;

  LocationMessage({
    required this.serialNumber,
    required this.latitude,
    required this.longitude
  });

  factory LocationMessage.fromJson(Map<String, dynamic> parsedJson){
    return LocationMessage(
        serialNumber: parsedJson['serialNumber'],
        latitude: parsedJson['latitude'],
        longitude : parsedJson['longitude']
    );
  }
}