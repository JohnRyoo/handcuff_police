import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:police/config/palette.dart';

import 'handcuff.dart';
import 'login.dart';

enum HandcuffMenu { deleteHandcuff, logout, exit }

enum BatteryLevel { high, middle, low }

enum GpsStatus { disconnected, connecting, connected }

enum HandcuffStatus { normal, runAway }

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({Key? key}) : super(key: key);

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  late double _phoneWidth;
  late double _phoneHeight;

  bool isHandcuffRegistered = true; // 수갑 등록 여부
  bool isHandcuffConnected = true; // 수갑 등록 후 수갑과의 연결 여부
  GpsStatus gpsStatus = GpsStatus.disconnected; // 수갑 연결 후 GPS 연결

  BatteryLevel batteryLevel = BatteryLevel.high;
  HandcuffStatus handcuffStatus = HandcuffStatus.normal;

  @override
  Widget build(BuildContext context) {
    _phoneHeight = MediaQuery.of(context).size.height;
    _phoneWidth = MediaQuery.of(context).size.width;

    String userId = 'ID_0001';
    String userName = '류호창';
    String department = '경찰서 강력반';

    // Color nameColor = Palette.lightButtonColor;

    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        backgroundColor: Palette.backgroundColor,
        iconTheme: const IconThemeData(
          color: Palette.whiteTextColor,
        ),
        centerTitle: true,
        title: Text(
          userId,
          style: const TextStyle(color: Palette.whiteTextColor),
        ),
        actions: [
          PopupMenuButton(
              icon: const Icon(
                Icons.menu,
                color: Palette.whiteTextColor,
              ),
              color: Palette.lightButtonColor,
              onSelected: (item) => _selectedActionMenuItem(context, item),
              itemBuilder: (context) => [
                    PopupMenuItem<HandcuffMenu>(
                      value: HandcuffMenu.deleteHandcuff,
                      child: Text(
                        "수갑 삭제",
                        style: GoogleFonts.notoSans(
                          textStyle: const TextStyle(
                            color: Palette.darkTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    PopupMenuItem<HandcuffMenu>(
                        value: HandcuffMenu.logout,
                        child: Text(
                          "로그아웃",
                          style: GoogleFonts.notoSans(
                            textStyle: const TextStyle(
                              color: Palette.darkTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )),
                    PopupMenuItem<HandcuffMenu>(
                        value: HandcuffMenu.exit,
                        child: Text(
                          "앱 종료",
                          style: GoogleFonts.notoSans(
                            textStyle: const TextStyle(
                              color: Palette.darkTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                  ]),
        ],
      ),
      body: Container(
        height: _phoneHeight,
        width: _phoneWidth,
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
              // 수갑 박스
              // 수갑이 등록되지 않은 상태의 화면
              if (!isHandcuffRegistered)
                Container(
                  width: _phoneWidth - 30,
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xffa0a0a0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'empty..',
                        style: GoogleFonts.notoSans(
                          textStyle: const TextStyle(
                            color: Color(0xffa0a0a0),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // 수갑이 등록된 화면
              if (isHandcuffRegistered)
                Container(
                  width: _phoneWidth - 30,
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: !isHandcuffConnected
                        ? Palette.darkButtonColor
                        : isHandcuffConnected &&
                                (handcuffStatus == HandcuffStatus.runAway)
                            ? Palette.emergencyColor
                            : Palette.lightButtonColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            isHandcuffConnected ? 'ON' : 'OFF',
                            style: GoogleFonts.notoSans(
                              textStyle: TextStyle(
                                color: isHandcuffConnected
                                    ? Palette.darkTextColor
                                    : Palette.whiteTextColor,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                              ),
                            ),
                          ),
                          Text(
                            !isHandcuffConnected
                                ? '-'
                                : batteryLevel == BatteryLevel.high
                                    ? '상 '
                                    : batteryLevel == BatteryLevel.middle
                                        ? '중'
                                        : batteryLevel == BatteryLevel.low
                                            ? '하'
                                            : '-',
                            style: GoogleFonts.notoSans(
                              textStyle: TextStyle(
                                color: isHandcuffConnected
                                    ? Palette.darkTextColor
                                    : Palette.whiteTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                              ),
                            ),
                          ),
                          Text(
                            !isHandcuffConnected ||
                                    gpsStatus == GpsStatus.disconnected
                                ? '마지막 위치'
                                : gpsStatus == GpsStatus.connected
                                    ? '위치확인'
                                    : '위치확인중...',
                            style: GoogleFonts.notoSans(
                              textStyle: TextStyle(
                                color: isHandcuffConnected
                                    ? Palette.darkTextColor
                                    : Palette.whiteTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 330,
                        width: _phoneWidth - 50,
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.black,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/handcuff.png',
                              width: 270,
                              fit: BoxFit.fill,
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(
                      //   height: 10,
                      // )
                    ],
                  ),
                ),
              const SizedBox(
                height: 30,
              ),
              // 수갑 추가 버튼
              if (!isHandcuffRegistered)
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
              if (isHandcuffRegistered)
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
                )
            ],
          ),
        ),
      ),
    );
  }

  void _selectedActionMenuItem(BuildContext context, item) {
    switch (item) {
      case HandcuffMenu.deleteHandcuff:
        _showToast("등록된 수갑 삭제");

        // 수갑 삭제 추가
        setState(() {
          isHandcuffRegistered = false;
        });
        break;
      case HandcuffMenu.logout:
        // 모든 페이지를 제거 후 지정한 페이지를 push
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false);
        break;
      case HandcuffMenu.exit:
        _exitApp();
    }
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
      fontSize: 20,
      textColor: Palette.lightTextColor,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
