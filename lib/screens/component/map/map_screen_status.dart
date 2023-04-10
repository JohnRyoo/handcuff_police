import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../config/palette.dart';
import '../../../mqtt/state/MQTTAppState.dart';
import '../../../service/handcuffInfo.dart';

class MapScreenStatus extends StatelessWidget {
  MapScreenStatus({Key? key}) : super(key: key);

  late bool isHandcuffRegistered;
  late bool isHandcuffConnected;
  late HandcuffStatus handcuffStatus;
  late BatteryLevel batteryLevel;
  // late GpsStatus gpsStatus;
  late GpsStatus gpsStatusFromMqtt;
  @override
  Widget build(BuildContext context) {
    // isHandcuffRegistered = context.watch<HandcuffInfo>().isHandcuffRegistered;
    // isHandcuffConnected = context.watch<HandcuffInfo>().isHandcuffConnected;
    // handcuffStatus = context.watch<HandcuffInfo>().handcuffStatus;
    // batteryLevel = context.watch<HandcuffInfo>().batteryLevel;
    // // gpsStatus = context.watch<HandcuffInfo>().gpsStatus;
    gpsStatusFromMqtt = context.watch<MQTTAppState>().gpsStatus;

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
            TextButton(
              onPressed: () {},
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
      ),
    );
  }
}
