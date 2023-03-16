import 'package:chat_lecture/mqtt/state/MQTTAppState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'map_screen.dart';

class HandcuffOnMapByMqtt extends StatelessWidget {
  const HandcuffOnMapByMqtt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Smart Handcuff MQTT',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ChangeNotifierProvider<MQTTAppState> (
          create: (_) => MQTTAppState(),
          child:HandcuffOnMap(),
        )
    );
  }
}