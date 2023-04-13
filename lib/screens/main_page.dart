import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  // 경찰 본인의 정보를 송수신하기 위한 Broker 연결
  MQTTAppState myMqttAppState = MQTTAppState();
  late MQTTManager myMqttManager;

  // 재소자 수갑에 대한 정보 관리
  late HandcuffInfo currentHandcuffInfo;

  // late bool isHandcuffRegistered;
  // late bool isHandcuffConnected;
  // late HandcuffStatus handcuffStatus;
  // late BatteryLevel batteryLevel;
  //
  // // late GpsStatus gpsStatus;
  // late GpsStatus gpsStatusFromMqtt;
  // late int numberOfRegisteredHandcuff;

  // bool isHandcuffRegistered = true; // 수갑 등록 여부
  // bool isHandcuffConnected = true; // 수갑 등록 후 수갑과의 연결 여부
  // GpsStatus gpsStatus = GpsStatus.disconnected; // 수갑 연결 후 GPS 연결
  //
  // BatteryLevel batteryLevel = BatteryLevel.high;
  // HandcuffStatus handcuffStatus = HandcuffStatus.normal;

  @override
  void initState() {
    // 경찰 자신의 스마트폰 위치를 전송하기 위한 Borker와의 연결
    var randomId = Random().nextInt(1000) + 1;
    myMqttManager = MQTTManager(
        host: "13.124.88.113",
        topic: 'PI0001',
        identifier: 'CPH_$randomId',
        state: myMqttAppState);
    myMqttManager.initializeMQTTClient();
    myMqttManager.receiveDataFromHandcuff = true;
    myMqttManager.connect();
  }

  @override
  void dispose() {
    // Borker와의 연결 해제
    myMqttManager.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    String userId = 'PI0001';
    String userName = '류호창';
    String department = '경찰서 강력반';

    const int maxHandcuffs = 3;
    debugPrint("Execute main_page build!!");

    myMqttAppState = Provider.of<MQTTAppState>(context);
    currentHandcuffInfo = Provider.of<HandcuffInfo>(context);

    debugPrint(
        "currentHandcuffInfo.handcuffs.length = ${currentHandcuffInfo.handcuffs.length}");

    // isHandcuffRegistered = context.watch<HandcuffInfo>().isHandcuffRegistered;
    // isHandcuffConnected = context.watch<HandcuffInfo>().isHandcuffConnected;
    // handcuffStatus = context.watch<HandcuffInfo>().handcuffStatus;
    // batteryLevel = context.watch<HandcuffInfo>().batteryLevel;
    // // gpsStatus = context.watch<HandcuffInfo>().gpsStatus;
    // gpsStatusFromMqtt = context.watch<MQTTAppState>().gpsStatus;
    // numberOfRegisteredHandcuff = context.watch<HandcuffInfo>().numberOfRegisteredHandcuff;

    List<LatLng> currentLocationList =
        context.watch<MQTTAppState>().getHandcuffTrackingPoints;
    // LatLng startLocation = context.watch<MQTTAppState>().startLocation;
    debugPrint("currentLocationList = $currentLocationList");

    // 경찰 자신의 스마트폰 위치를 전송하기 위한 Borker와의 연결
    // if (context
    //     .watch<HandcuffInfo>()
    //     .handcuffs
    //     .isNotEmpty) {
    //   WidgetsBinding.instance!.addPostFrameCallback((_) {
    //     if (myMqttAppState.getAppConnectionState ==
    //         MQTTAppConnectionState.disconnected) {
    //       debugPrint("MQTT CONNECT with $userId at main_page!!");
    //       // police ID로 우선 브로커와 연결
    //       mqttConnect(userId);
    //     }
    //   });
    // }

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
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Container(
              height: 130,
              width: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Palette.darkButtonColor,
              ),
              child: Center(
                child: Text.rich(TextSpan(
                    text: currentHandcuffInfo.handcuffs.length
                        .toString()
                        .padLeft(2, '0'),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 60,
                        color: Palette.whiteTextColor),
                    children: <TextSpan>[
                      TextSpan(
                        // TODO : 전체 갯수에 대해 확인 후 수정할 것
                        text: '/${maxHandcuffs.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 30,
                          color: Palette.whiteTextColor,
                        ),
                      ),
                    ])),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            MainPageStatus(),
            const SizedBox(
              height: 30,
            ),

            // 수갑 등록 최대 갯수 이하인 경우 등록 버튼을 보여줌
            if (currentHandcuffInfo.handcuffs.length < maxHandcuffs)
              SizedBox(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return HandcuffScreen();
                    }));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Color(0xff00e693),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

            // 등록된 수갑의 갯수가 최대치를 넘어가면 등록버튼을 disable
            if (currentHandcuffInfo.handcuffs.length >= maxHandcuffs)
              SizedBox(
                child: Container(
                  padding: const EdgeInsets.all(0),
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Palette.darkButtonColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.clear,
                      color: Palette.darkTextColor,
                    ),
                  ),
                ),
              ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
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
