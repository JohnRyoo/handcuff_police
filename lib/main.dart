import 'package:flutter/material.dart';
import 'package:police/screens/login.dart';
import 'package:police/service/handcuffInfo.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const HandcuffPolice());
}

class HandcuffPolice extends StatelessWidget {
  const HandcuffPolice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HandcuffInfo(),
      child: MaterialApp(
        title: 'Smart Handcuff for Police',
        theme: ThemeData(
          primarySwatch: Colors.blue
        ),
        home: LoginScreen(),
      ),
    );
  }
}
