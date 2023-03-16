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
  double latitude;
  double longitude;

  LocationMessage({
    required this.latitude,
    required this.longitude
  });

  factory LocationMessage.fromJson(Map<String, dynamic> parsedJson){
    return LocationMessage(
        latitude: parsedJson['latitude'],
        longitude : parsedJson['longitude']
    );
  }
}