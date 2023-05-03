import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:police/mqtt/state/MQTTAppState.dart';
import 'package:police/screens/handcuff.dart';
import 'package:police/screens/login.dart';
import 'package:police/screens/main_page.dart';
import 'package:police/screens/map_screen.dart';
import 'package:police/screens/signup.dart';
import 'package:police/service/guardInfo.dart';
import 'package:police/service/handcuffInfo.dart';

void main() {
  runApp(const HandcuffPolice());
}

class HandcuffPolice extends StatelessWidget {
  const HandcuffPolice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Get.put(HandcuffInfo());
    Get.put(GuardInfo());
    Get.put(MQTTAppState());

    return GetMaterialApp(
      title: 'Smart Handcuff for Police',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: "/",
      getPages: [
        GetPage(name: "/", page: () => LoginScreen()),
        GetPage(name: "/signup", page: () => SignupScreen()),
        GetPage(name: "/mainpage", page: () => MainPageScreen()),
        GetPage(name: "/handcuff", page: () => HandcuffScreen()),
        GetPage(name: "/map", page: () => HandcuffOnMap()),
      ],
    );
  }
}
