import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:police/service/handcuffInfo.dart';
import '../../../config/palette.dart';
import '../../../mqtt/MQTTManager.dart';
import '../../map_screen.dart';

class MainPageStatus extends StatefulWidget {
  MainPageStatus({Key? key, required this.mqttManager}) : super(key: key);

  final MQTTManager mqttManager;

  @override
  State<MainPageStatus> createState() => _MainPageStatusState();
}

class _MainPageStatusState extends State<MainPageStatus> {
  final HandcuffInfo _handcuffInfo = Get.find();

  late GpsStatus gpsStatusFromMqtt;

  late RxMap<String, Handcuff> _handcuffsMap;

  late double height;

  late double width;

  @override
  Widget build(BuildContext context) {
    _handcuffsMap = _handcuffInfo.getHandcuffsMap();

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    debugPrint("[main_page_status] This is called when BACK is executed!!");

    return Obx(() => Column(
      children: [
        if (_handcuffInfo.getHandcuffsMap().isEmpty)
          const NoHandcuff(),
        if (_handcuffInfo.getHandcuffsMap().isNotEmpty)
          OneHandcuff(mqttManager: widget.mqttManager)
      ],
    ));
  }
}

class NoHandcuff extends StatelessWidget {
  const NoHandcuff({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class OneHandcuff extends StatelessWidget {
  OneHandcuff({Key? key, required this.mqttManager}) : super(key: key);

  final MQTTManager mqttManager;

  final HandcuffInfo _handcuffInfo = Get.find();

  late bool isHandcuffConnected;
  late HandcuffStatus handcuffStatus;
  late BatteryLevel batteryLevel;
  late GpsStatus gpsStatus;

  @override
  Widget build(BuildContext context) {
    // Handcuff handcuff = _handcuffInfo.getHandcuffsMap().values.toList().first;
    Handcuff handcuff = _handcuffInfo.getFirstHandcuff();

    return GetBuilder<HandcuffInfo>(
        init: HandcuffInfo(),
        builder: (_) => Container(
          width: MediaQuery.of(context).size.width - 30,
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: !handcuff.isHandcuffConnected
                ? Palette.darkButtonColor
                : handcuff.isHandcuffConnected &&
                        (handcuff.handcuffStatus == HandcuffStatus.runAway)
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
                    handcuff.isHandcuffConnected ? 'ON' : 'OFF',
                    style: GoogleFonts.notoSans(
                      textStyle: TextStyle(
                        color: !handcuff.isHandcuffConnected
                            ? Palette.whiteTextColor
                            : Palette.darkTextColor,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Text(
                    handcuff.isHandcuffConnected
                        ? handcuff.batteryLevel == BatteryLevel.high
                            ? '상'
                            : handcuff.batteryLevel == BatteryLevel.middle
                                ? '중'
                                : handcuff.batteryLevel == BatteryLevel.low
                                    ? '하'
                                    : '-'
                        : '-',
                    style: GoogleFonts.notoSans(
                      textStyle: TextStyle(
                        color: handcuff.isHandcuffConnected
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
                      debugPrint('isLastLocation = ${handcuff.isLastLocation}');
                      if (handcuff.isLastLocation) {
                        Get.toNamed("/map", arguments: {
                          'serialNumber': handcuff.serialNumber,
                          'mqttManager': mqttManager,
                          'index': 1, // 경찰용 지도에는 index가 무의미함
                        });
                      }
                    },
                    child: Text(
                      !handcuff.isHandcuffConnected ||
                              handcuff.gpsStatus == GpsStatus.disconnected
                          ? '마지막 위치'
                          : handcuff.gpsStatus == GpsStatus.connected
                              ? '위치 확인'
                              : '위치확인중..',
                      style: GoogleFonts.notoSans(
                        textStyle: TextStyle(
                          color: handcuff.isHandcuffConnected
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
            ],
          ),
        ));
  }
}
