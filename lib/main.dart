import 'package:flutter/material.dart';
import 'package:police/screens/login.dart';

void main() {
  runApp(const HandcuffPolice());
}

class HandcuffPolice extends StatelessWidget {
  const HandcuffPolice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Handcuff for Police',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: LoginScreen(),
    );
  }
}
