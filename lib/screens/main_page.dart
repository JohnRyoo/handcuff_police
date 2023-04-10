import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:police/config/palette.dart';
import 'package:police/screens/component/main/handcuff_add.dart';
import 'package:police/screens/component/main/main_page_status.dart';
import 'package:provider/provider.dart';

import '../mqtt/MQTTManager.dart';
import '../mqtt/state/MQTTAppState.dart';
import '../service/handcuffInfo.dart';
import 'handcuff.dart';
import 'login.dart';
import 'mqtt_screen.dart';

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({Key? key}) : super(key: key);

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  MQTTAppState currentMqttAppState = MQTTAppState();
  late MQTTManager manager;

  late bool isHandcuffRegistered;
  late bool isHandcuffConnected;
  late HandcuffStatus handcuffStatus;
  late BatteryLevel batteryLevel;
  // late GpsStatus gpsStatus;
  late GpsStatus gpsStatusFromMqtt;

  // bool isHandcuffRegistered = true; // 수갑 등록 여부
  // bool isHandcuffConnected = true; // 수갑 등록 후 수갑과의 연결 여부
  // GpsStatus gpsStatus = GpsStatus.disconnected; // 수갑 연결 후 GPS 연결
  //
  // BatteryLevel batteryLevel = BatteryLevel.high;
  // HandcuffStatus handcuffStatus = HandcuffStatus.normal;

  // 메인 진입 시 일단 MQTT로 수신 여부를 확인해 본다.
  // if 수신되는 게 없으면... on

  void mqttConnect(String topic) {
    var randomId = Random().nextInt(1000) + 1;
    manager = MQTTManager(
        host: "13.124.88.113",
        // host: "192.168.0.7",
        topic: topic,
        identifier: 'CJS_HandcuffTest_$randomId',
        state: currentMqttAppState);
    manager.initializeMQTTClient();
    manager.receiveDataFromHandcuff = true;
    manager.connect();
  }

  @override
  Widget build(BuildContext context) {
    String userId = 'police';
    String userName = '류호창';
    String department = '경찰서 강력반';

    currentMqttAppState = Provider.of<MQTTAppState>(context);
    debugPrint("Execute main_page build!!");

    isHandcuffRegistered = context.watch<HandcuffInfo>().isHandcuffRegistered;
    isHandcuffConnected = context.watch<HandcuffInfo>().isHandcuffConnected;
    handcuffStatus = context.watch<HandcuffInfo>().handcuffStatus;
    batteryLevel = context.watch<HandcuffInfo>().batteryLevel;
    // gpsStatus = context.watch<HandcuffInfo>().gpsStatus;
    gpsStatusFromMqtt = context.watch<MQTTAppState>().gpsStatus;

    debugPrint("gpsStatusFromMqtt = $gpsStatusFromMqtt");
    // Keep a reference to the app state.
    if (isHandcuffRegistered) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (currentMqttAppState.getAppConnectionState ==
            MQTTAppConnectionState.disconnected) {
          debugPrint("run MQTT CONNECT at main_page!!");
          // police ID로 정보가 들어오고 있는지 확인을 위해 연결
          mqttConnect(userId);
        }
      });
    }

    // Color nameColor = Palette.lightButtonColor;

    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        backgroundColor: Palette.backgroundColor,
        // 메인화면은 로그인 화면이 제거된 후 생성되므로 돌아갈 곳이 없음
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   icon: const Icon(Icons.arrow_back_ios),
        //   color: Palette.whiteTextColor,
        // ),
        centerTitle: true,
        title: Text(
          userId,
          style: const TextStyle(color: Palette.whiteTextColor),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // _exitApp();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Palette.backgroundColor,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              // 이름
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    '이름',
                    style: GoogleFonts.notoSans(
                      textStyle: const TextStyle(
                        color: Palette.whiteTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Text(
                    userName,
                    style: GoogleFonts.notoSans(
                      textStyle: const TextStyle(
                        color: Palette.whiteTextColor,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              // 부서
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    '부서',
                    style: GoogleFonts.notoSans(
                      textStyle: const TextStyle(
                        color: Palette.whiteTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Text(
                    department,
                    style: GoogleFonts.notoSans(
                      textStyle: const TextStyle(
                        color: Palette.whiteTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 70,
              ),

              MainPageStatus(),
              const SizedBox(
                height: 30,
              ),
              HandcuffAdd(),
            ],
          ),
        ),
      ),
    );
  }

  Future _deleteHandcuff() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Palette.lightButtonColor,
          title: Text(
            '등록된 수갑을 삭제하시겠습니까?',
            style: GoogleFonts.notoSans(
              textStyle: const TextStyle(
                color: Palette.darkTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  context.watch<HandcuffInfo>().isHandcuffRegistered = false;
                });
                Navigator.pop(context);
              },
              child: Text(
                '삭제',
                style: GoogleFonts.notoSans(
                  textStyle: const TextStyle(
                    color: Palette.darkTextColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                '취소',
                style: GoogleFonts.notoSans(
                  textStyle: const TextStyle(
                    color: Palette.darkTextColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future _exitApp() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Palette.lightButtonColor,
            title: Text(
              '종료하시겠습니까?',
              style: GoogleFonts.notoSans(
                textStyle: const TextStyle(
                  color: Palette.darkTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  //아래 함수를 이용해서 앱을 종료 할 수 있다.
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                child: Text(
                  '끝내기',
                  style: GoogleFonts.notoSans(
                    textStyle: const TextStyle(
                      color: Palette.darkTextColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  '아니요',
                  style: GoogleFonts.notoSans(
                    textStyle: const TextStyle(
                      color: Palette.darkTextColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  void _showToast(String toastMessage) {
    Fluttertoast.showToast(
      msg: toastMessage,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Palette.lightButtonColor,
      fontSize: 16,
      textColor: Palette.darkTextColor,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
