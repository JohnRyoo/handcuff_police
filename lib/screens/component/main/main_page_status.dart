import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:police/mqtt/state/MQTTAppState.dart';
import 'package:police/service/handcuffInfo.dart';
import 'package:provider/provider.dart';

import '../../../config/palette.dart';
import '../../map_screen.dart';
import '../../mqtt_screen.dart';

class MainPageStatus extends StatelessWidget {
  MainPageStatus({Key? key}) : super(key: key);

  late bool isHandcuffRegistered;
  late bool isHandcuffConnected;
  late HandcuffStatus handcuffStatus;
  late BatteryLevel batteryLevel;
  // late GpsStatus gpsStatus;
  late GpsStatus gpsStatusFromMqtt;

  @override
  Widget build(BuildContext context) {
    isHandcuffRegistered = context.watch<HandcuffInfo>().isHandcuffRegistered;
    isHandcuffConnected = context.watch<HandcuffInfo>().isHandcuffConnected;
    handcuffStatus = context.watch<HandcuffInfo>().handcuffStatus;
    batteryLevel = context.watch<HandcuffInfo>().batteryLevel;
    // gpsStatus = context.watch<HandcuffInfo>().gpsStatus;

    gpsStatusFromMqtt = context.watch<MQTTAppState>().gpsStatus;
    debugPrint("gpsStatusFromMqtt = $gpsStatusFromMqtt at MainPageStatus");


    // 수갑이 등록되지 않은 경우
    if (!isHandcuffRegistered) {
      return Container(
        width: MediaQuery.of(context).size.width - 30,
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xffa0a0a0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'empty',
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
      );
    }
    // 수갑이 등록된 경우
    else {
      return Container(
        width: MediaQuery.of(context).size.width - 30,
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
                          ? Palette.whiteTextColor
                          : Palette.darkTextColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                    ),
                  ),
                ),
                Text(
                  isHandcuffConnected
                      ? batteryLevel == BatteryLevel.high
                          ? '상'
                          : batteryLevel == BatteryLevel.middle
                              ? '중'
                              : batteryLevel == BatteryLevel.low
                                  ? '하'
                                  : '-'
                      : '-',
                  style: GoogleFonts.notoSans(
                    textStyle: TextStyle(
                      color: !isHandcuffConnected
                          ? Palette.darkTextColor
                          : Palette.whiteTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (isHandcuffConnected ||
                        gpsStatusFromMqtt == GpsStatus.disconnected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const HandcuffOnMap();
                          },
                        ),
                      );
                    }
                  },
                  child: Text(
                    !isHandcuffConnected || gpsStatusFromMqtt == GpsStatus.disconnected
                        ? '마지막 위치'
                        : gpsStatusFromMqtt == GpsStatus.connected
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
                ),
              ],
            ),
            Container(
              height: 330,
              width: MediaQuery.of(context).size.width - 50,
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
      );
    }
  }
}
