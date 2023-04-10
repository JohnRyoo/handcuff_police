import 'package:flutter/material.dart';
import 'package:police/screens/login.dart';
import 'package:police/service/handcuffInfo.dart';
import 'package:police/service/handcuff_watchdog.dart';
import 'package:provider/provider.dart';

import 'mqtt/state/MQTTAppState.dart';

void main() {
  runApp(const HandcuffPolice());
}

class HandcuffPolice extends StatelessWidget {
  const HandcuffPolice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HandcuffInfo()),
        // ChangeNotifierProvider(create: (context) => Handcuff()),
        ChangeNotifierProvider(create: (context) => HandcuffWatchdog()),
        ChangeNotifierProvider(create: (context) => MQTTAppState()),
      ],
      child: MaterialApp(
        title: 'Smart Handcuff for Police',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginScreen(),
      ),
    );
  }
}
