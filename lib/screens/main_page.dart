import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:police/config/palette.dart';
import 'package:police/screens/component/main/main_page_status.dart';
import 'package:police/service/guardInfo.dart';
import '../mqtt/MQTTManager.dart';
import '../mqtt/state/MQTTAppState.dart';
import '../service/handcuffInfo.dart';

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({Key? key}) : super(key: key);

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  final HandcuffInfo _handcuffInfo = Get.find();
  final MQTTAppState mqttAppState = Get.find();
  final GuardInfo guardInfo = Get.find();

  int maxHandcuffs = 1;
  late MQTTManager manager;
  late RxMap<String, Handcuff> _handcuffsMap;

  late String userId;

  String userName = '김정식';
  String department = '안양경찰서 강력반';

  void mqttConnect(String topic) {
    var randomId = Random().nextInt(1000) + 1;
    manager = MQTTManager(
        host: "13.124.88.113",
        // host: "192.168.0.7",
        topic: topic,
        identifier: 'CJS_HandcuffTest_$randomId',
        state: mqttAppState);
    manager.initializeMQTTClient();
    manager.connect();
  }

  @override
  void initState() {
    userId = guardInfo.id;

    debugPrint("run MQTT CONNECT for guard at main_page!!");
    mqttConnect(userId);
  }

  @override
  Widget build(BuildContext context) {

    debugPrint("Execute main_page build!!!!!!");

    _handcuffsMap = _handcuffInfo.getHandcuffsMap();
    debugPrint('_handcuffs Length = ${_handcuffsMap.length}');

    debugPrint('handcuff list = $_handcuffInfo.getHandcuffsList()');

    double boxSize() {
      debugPrint(
          '[main_page] guardInfo.isConnected.isTrue = ${guardInfo.isConnected.value}!');
      if (guardInfo.isConnected.isTrue) {
        debugPrint(
            '[main_page] guardInfo.isConnected.isTrue = ${guardInfo.isConnected.value}!');
        _handcuffInfo.getHandcuffsList().forEach((handcuff) {
          if (!handcuff.isSubscribed) {
            debugPrint('[main_page] Subscribe $handcuff.serialNumber');
            manager.subscribe(handcuff.serialNumber);
          }
        });
      }

      return 5.0;
    }

    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        backgroundColor: Palette.backgroundColor,
        centerTitle: true,
        title: Text(
          userId,
          style: const TextStyle(color: Palette.whiteTextColor),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _exitApp();
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            // 이름
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 50,
                ),
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
                const SizedBox(
                  width: 170,
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 50,
                ),
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
                const SizedBox(
                  width: 145,
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

            MainPageStatus(mqttManager: manager),

            const SizedBox(
              height: 30,
            ),

            Obx(
              () => SizedBox(
                height: 60,
                child: Column(
                  children: [
                    // 수갑 등록 최대 갯수 이하인 경우 등록 버튼을 보여줌
                    if (_handcuffInfo.getNumberOfHandcuffs() < maxHandcuffs)
                      SizedBox(
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed('/handcuff', arguments: manager);
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
                    if (_handcuffInfo.getNumberOfHandcuffs() >= maxHandcuffs)
                      SizedBox(
                        child: GestureDetector(
                          onTap: () {
                            _deleteHandcuff();

                          },
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
                      ),
                  ],
                ),
              ),
            ),

            // Guard의 connection이 되면 바로 등록된 수갑의 subscribe을 진행
            Obx(() => SizedBox(
                  width: guardInfo.isConnected.isTrue ? boxSize() : boxSize(),
                )),
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

  Future _deleteHandcuff() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Palette.lightButtonColor,
            title: Text(
              '삭제하시겠습까?',
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
                  Get.back();
                  setState(() {
                    _handcuffInfo.removeHandcuff(_handcuffsMap.keys.elementAt(0));
                    debugPrint('_handcuffsMap = $_handcuffsMap');
                  });
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
                  //Navigator.pop(context);
                  Get.back();
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
