import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/palette.dart';
import '../../../mqtt/state/MQTTAppState.dart';
import '../../../service/guardInfo.dart';
import '../../../service/handcuffInfo.dart';

class MapScreenStatus extends StatelessWidget {
  MapScreenStatus(
      {Key? key, required this.serialNumber, required this.userIndex})
      : super(key: key);

  final String serialNumber;
  final String userIndex;

  final HandcuffInfo _handcuffInfo = Get.find();
  final MQTTAppState _mqttAppState = Get.find();
  final GuardInfo _guardInfo = Get.find();

  late bool isHandcuffConnected;
  late HandcuffStatus handcuffStatus;
  late BatteryLevel batteryLevel;
  late GpsStatus gpsStatus;

  @override
  Widget build(BuildContext context) {
    Handcuff handcuff = _handcuffInfo.getHandcuff(serialNumber);
    isHandcuffConnected = handcuff.isHandcuffConnected;
    handcuffStatus = handcuff.handcuffStatus;
    batteryLevel = handcuff.batteryLevel;
    gpsStatus = handcuff.gpsStatus;

    return Positioned(
      top: 20,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: !isHandcuffConnected
              ? Colors.black
              : (handcuffStatus == HandcuffStatus.runAway)
                  ? Palette.emergencyColor
                  : Palette.lightButtonColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Text(
            //   isHandcuffConnected ? 'ON' : 'OFF',
            //   style: GoogleFonts.notoSans(
            //     textStyle: TextStyle(
            //       color: isHandcuffConnected
            //           ? Palette.darkTextColor
            //           : Palette.whiteTextColor,
            //       fontSize: 36,
            //       fontWeight: FontWeight.w800,
            //       height: 1.4,
            //     ),
            //   ),
            // ),
            Text(
              userIndex.toString().padLeft(2, '0'),
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
              isHandcuffConnected
                  ? handcuffStatus ==
                  HandcuffStatus.runAway
                  ? '도주'
                  : '정상'
                  : '-',
              textAlign: TextAlign.center,
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
              !isHandcuffConnected || gpsStatus == GpsStatus.disconnected
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
      ),
    );
  }
}
