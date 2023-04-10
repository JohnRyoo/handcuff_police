import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:police/mqtt/state/MQTTAppState.dart';
import 'package:police/service/handcuffInfo.dart';
import 'package:provider/provider.dart';

import '../../../config/palette.dart';
import '../../map_screen.dart';

class MainPageStatus extends StatefulWidget {
  MainPageStatus({Key? key}) : super(key: key);

  @override
  State<MainPageStatus> createState() => _MainPageStatusState();
}

class _MainPageStatusState extends State<MainPageStatus> {
  late HandcuffInfo currentHandcuffInfo;
  // late bool isHandcuffRegistered;
  late GpsStatus gpsStatusFromMqtt;

  List<Handcuff> registeredHandcuffs = <Handcuff>[];


  @override
  void initState() {
    // Handcuff registeredHandcuff1 = Handcuff();
    // registeredHandcuff1.serialNumber = 'HC0001';
    // registeredHandcuff1.isHandcuffConnected = true;
    // registeredHandcuff1.batteryLevel = BatteryLevel.high;
    // registeredHandcuff1.gpsStatus = GpsStatus.connected;
    // registeredHandcuff1.handcuffStatus = HandcuffStatus.runAway;
    // registeredHandcuffs.add(registeredHandcuff1);
    //
    // Handcuff registeredHandcuff2 = Handcuff();
    // registeredHandcuff2.serialNumber = 'HC0002';
    // registeredHandcuff2.isHandcuffConnected = true;
    // registeredHandcuff2.batteryLevel = BatteryLevel.middle;
    // registeredHandcuff2.gpsStatus = GpsStatus.connecting;
    // registeredHandcuff2.handcuffStatus = HandcuffStatus.normal;
    // registeredHandcuffs.add(registeredHandcuff2);
    //
    // Handcuff registeredHandcuff3 = Handcuff();
    // registeredHandcuff3.serialNumber = 'HC0003';
    // registeredHandcuffs.add(registeredHandcuff3);

    // Handcuff registeredHandcuff4 = Handcuff();
    // registeredHandcuff4.serialNumber = 'HC0001';
    // registeredHandcuffs.add(registeredHandcuff4);
    //
    // Handcuff registeredHandcuff5 = Handcuff();
    // registeredHandcuff5.serialNumber = 'HC0002';
    // registeredHandcuffs.add(registeredHandcuff5);
    //
    // Handcuff registeredHandcuff6 = Handcuff();
    // registeredHandcuff6.serialNumber = 'HC0003';
    // registeredHandcuffs.add(registeredHandcuff6);
    //
    // Handcuff registeredHandcuff7 = Handcuff();
    // registeredHandcuff7.serialNumber = 'HC0001';
    // registeredHandcuffs.add(registeredHandcuff7);
    //
    // Handcuff registeredHandcuff8 = Handcuff();
    // registeredHandcuff8.serialNumber = 'HC0002';
    // registeredHandcuffs.add(registeredHandcuff8);
    //
    // Handcuff registeredHandcuff9 = Handcuff();
    // registeredHandcuff9.serialNumber = 'HC0003';
    // registeredHandcuffs.add(registeredHandcuff9);
  }

  // late int numberOfRegisteredHandcuff;

  @override
  Widget build(BuildContext context) {
    // isHandcuffRegistered = context.watch<HandcuffInfo>().isHandcuffRegistered;
    // isHandcuffConnected = context.watch<HandcuffInfo>().isHandcuffConnected;
    // handcuffStatus = context.watch<HandcuffInfo>().handcuffStatus;
    // batteryLevel = context.watch<HandcuffInfo>().batteryLevel;
    // // gpsStatus = context.watch<HandcuffInfo>().gpsStatus;

    // gpsStatusFromMqtt = context.watch<MQTTAppState>().gpsStatus;
    // debugPrint("gpsStatusFromMqtt = $gpsStatusFromMqtt at MainPageStatus");
    // numberOfRegisteredHandcuff =
    //     context.watch<HandcuffInfo>().numberOfRegisteredHandcuff;
    currentHandcuffInfo = Provider.of<HandcuffInfo>(context);
    registeredHandcuffs = context.watch<HandcuffInfo>().handcuffs;
    debugPrint("registeredHandcuffs = $registeredHandcuffs at MainPageStatus");

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: registeredHandcuffs.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            // key: Key(registeredHandcuffs[index].serialNumber),
            key: UniqueKey(),
            direction: DismissDirection.startToEnd,
            confirmDismiss: (direction) {
              return showDialog(
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
                          // setState(() {
                          //   // context.watch<HandcuffInfo>().isHandcuffRegistered = false;
                          // });
                          return Navigator.of(context).pop(true);
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
                          return Navigator.of(context).pop(false);
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
              return Future.value(false);
            },
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                setState(() {
                  // isFirst = false;
                  // registeredHandcuffs[index].mqttDisconnect();
                  currentHandcuffInfo.removeHandcuff(index);
                  debugPrint('registeredHandcuffs = $registeredHandcuffs');
                });
              }
            },
            background: Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              width: MediaQuery.of(context).size.width - 30,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.blueGrey[900],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      width: 30,
                    ),
                    const Icon(
                      Icons.delete,
                      size: 25,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Text(
                      '삭제',
                      style: GoogleFonts.notoSans(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              width: MediaQuery.of(context).size.width - 30,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: !registeredHandcuffs[index].isHandcuffConnected
                    ? Palette.darkButtonColor
                    : registeredHandcuffs[index].isHandcuffConnected &&
                            (registeredHandcuffs[index].handcuffStatus ==
                                HandcuffStatus.runAway)
                        ? Palette.emergencyColor
                        : Palette.lightButtonColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          registeredHandcuffs[index].serialNumber,
                          style: GoogleFonts.notoSans(
                            textStyle: TextStyle(
                              color: registeredHandcuffs[index].isHandcuffConnected
                                  ? Palette.darkTextColor
                                  : Palette.whiteTextColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          registeredHandcuffs[index].isHandcuffConnected
                              ? registeredHandcuffs[index].batteryLevel ==
                                      BatteryLevel.high
                                  ? '상'
                                  : registeredHandcuffs[index].batteryLevel ==
                                          BatteryLevel.middle
                                      ? '중'
                                      : registeredHandcuffs[index].batteryLevel ==
                                              BatteryLevel.low
                                          ? '하'
                                          : '-'
                              : '-',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(
                            textStyle: TextStyle(
                              color: registeredHandcuffs[index].isHandcuffConnected
                                  ? Palette.darkTextColor
                                  : Palette.whiteTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          registeredHandcuffs[index].isHandcuffConnected
                              ? registeredHandcuffs[index].handcuffStatus ==
                                      HandcuffStatus.runAway
                                  ? '도주'
                                  : '정상'
                              : '-',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(
                            textStyle: TextStyle(
                              color: registeredHandcuffs[index].isHandcuffConnected
                                  ? Palette.darkTextColor
                                  : Palette.whiteTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      TextButton(
                        onPressed: () {
                          if (registeredHandcuffs[index].isHandcuffConnected ||
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
                          !registeredHandcuffs[index].isHandcuffConnected ||
                                  // gpsStatusFromMqtt == GpsStatus.disconnected
                                  registeredHandcuffs[index].mqttAppState.gpsStatus ==
                                      GpsStatus.disconnected
                              ? '마지막 위치'
                              // : gpsStatusFromMqtt == GpsStatus.connected
                              : registeredHandcuffs[index].mqttAppState.gpsStatus ==
                                      GpsStatus.connected
                                  ? '위치 확인'
                                  : '위치확인중..',
                          style: GoogleFonts.notoSans(
                            textStyle: TextStyle(
                              color: registeredHandcuffs[index].isHandcuffConnected
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
