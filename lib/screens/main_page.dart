import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:police/config/palette.dart';

import 'handcuff.dart';

enum RssiType { high, middle, low }

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
  GpsStatus gpsStatus = GpsStatus.connected; // 수갑 연결 후 GPS 연결

  RssiType rssiType = RssiType.high;
  HandcuffStatus handcuffStatus = HandcuffStatus.runAway;

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
          IconButton(
            onPressed: () {},
            color: Palette.whiteTextColor,
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: Container(
        height: _phoneHeight,
        width: _phoneWidth,
        decoration: const BoxDecoration(
          color: Palette.backgroundColor,
        ),
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
                  color: isHandcuffConnected &&
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
                              : rssiType == RssiType.high
                                  ? '상 '
                                  : rssiType == RssiType.middle
                                      ? '중'
                                      : rssiType == RssiType.low
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
                          !isHandcuffConnected
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
                      margin: const EdgeInsets.fromLTRB(10,0,10,10),
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
              Positioned(
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
              Positioned(
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
    );
  }
}
