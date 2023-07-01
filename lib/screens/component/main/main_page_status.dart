import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:police/service/guardInfo.dart';
import 'package:police/service/handcuffInfo.dart';
import '../../../config/palette.dart';
import '../../../mqtt/MQTTManager.dart';
import '../../../restapi/RestClient.dart';
import '../../map_screen.dart';

class MainPageStatus extends StatefulWidget {
  const MainPageStatus({Key? key, required this.mqttManager}) : super(key: key);

  final MQTTManager mqttManager;

  @override
  State<MainPageStatus> createState() => _MainPageStatusState();
}

class _MainPageStatusState extends State<MainPageStatus> {
  final HandcuffInfo _handcuffInfo = Get.find();
  final GuardInfo _guardInfo = Get.find();

  late GpsStatus gpsStatusFromMqtt;
  late RxMap<String, Handcuff> _handcuffsMap;

  late RestClient restClient;

  @override
  void initState() {
    Dio dio = Dio();
    restClient = RestClient(dio);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _handcuffsMap = _handcuffInfo.getHandcuffsMap();

    return Obx(() => Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _handcuffsMap.length,
            itemBuilder: (BuildContext context, int index) {
              String key = _handcuffsMap.keys.elementAt(index);
              return Dismissible(
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
                                return Get.back(result: true);
                                // return Navigator.of(context).pop(true);
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
                                return Get.back(result: false);
                                // return Navigator.of(context).pop(false);
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
                    // return Future.value(false);
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      DeleteHandcuffRequest deleteHandcuffRequest =
                          DeleteHandcuffRequest(
                              user_id: _guardInfo.id, handcuff_id: key);
                      restClient
                          .deleteHandcuff(deleteHandcuffRequest)
                          .then((value) {
                        if (value.success != null && value.success == true) {
                          _handcuffInfo.removeHandcuff(key);
                          debugPrint(
                              '[main_page_status] _handcuffsMap = $_handcuffsMap');
                        } else {
                          debugPrint('EXCEPTION ***********');
                        }
                      }).catchError((Object obj) {
                        setState(() {

                        });
                        debugPrint('EXCEPTION =========');
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                            '삭제에 실패했습니다.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.blue,
                        ));
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
                            width: 80,
                          ),
                          const Icon(
                            Icons.delete,
                            size: 25,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            width: 100,
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
                  child: GetBuilder<HandcuffInfo>(
                    builder: (controller) {
                      return Container(
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        width: MediaQuery.of(context).size.width - 30,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: !_handcuffsMap[key]!.isHandcuffConnected
                              ? Palette.darkButtonColor
                              : _handcuffsMap[key]!.isHandcuffConnected &&
                                      (_handcuffsMap[key]!.handcuffStatus ==
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
                                  width: 60,
                                  child: Text(
                                    (index + 1).toString().padLeft(2, '0'),
                                    style: GoogleFonts.notoSans(
                                      textStyle: TextStyle(
                                        color: _handcuffsMap[key]!
                                                .isHandcuffConnected
                                            ? Palette.darkTextColor
                                            : Palette.whiteTextColor,
                                        fontSize: 35,
                                        fontWeight: FontWeight.w800,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    _handcuffsMap[key]!.isHandcuffConnected
                                        ? _handcuffsMap[key]!.batteryLevel ==
                                                BatteryLevel.high
                                            ? '상'
                                            : _handcuffsMap[key]!
                                                        .batteryLevel ==
                                                    BatteryLevel.middle
                                                ? '중'
                                                : _handcuffsMap[key]!
                                                            .batteryLevel ==
                                                        BatteryLevel.low
                                                    ? '하'
                                                    : '-'
                                        : '-',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.notoSans(
                                      textStyle: TextStyle(
                                        color: _handcuffsMap[key]!
                                                .isHandcuffConnected
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
                                  width: 30,
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    _handcuffsMap[key]!.isHandcuffConnected
                                        ? _handcuffsMap[key]!.handcuffStatus ==
                                                HandcuffStatus.runAway
                                            ? '도주'
                                            : '정상'
                                        : '-',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.notoSans(
                                      textStyle: TextStyle(
                                        color: _handcuffsMap[key]!
                                                .isHandcuffConnected
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
                                  width: 30,
                                ),
                                TextButton(
                                  onPressed: () {
                                    debugPrint(
                                        'isLastLocation = ${_handcuffsMap[key]!.isLastLocation}');
                                    // debugPrint('isHandcuffConnected = ${_handcuffsMap[key]!.isHandcuffConnected}');
                                    if (_handcuffsMap[key]!.isLastLocation) {
                                      // if (_handcuffsMap[key]!
                                      //         .isHandcuffConnected) {
                                      //   Get.toNamed("/map",
                                      //       arguments: _handcuffsMap[key]!
                                      //           .serialNumber);
                                      // }
                                      Get.toNamed("/map", arguments: {
                                        'serialNumber':
                                            _handcuffsMap[key]!.serialNumber,
                                        'mqttManager': widget.mqttManager,
                                        'index': index + 1,
                                      });
                                    }
                                  },
                                  child: Text(
                                    !_handcuffsMap[key]!.isHandcuffConnected ||
                                            _handcuffsMap[key]!.gpsStatus ==
                                                GpsStatus.disconnected
                                        ? '마지막 위치'
                                        : _handcuffsMap[key]!.gpsStatus ==
                                                GpsStatus.connected
                                            ? '위치 확인'
                                            : '위치확인중..',
                                    style: GoogleFonts.notoSans(
                                      textStyle: TextStyle(
                                        color: _handcuffsMap[key]!
                                                .isHandcuffConnected
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
                      );
                    },
                  ));
            },
          ),
        ));
  }
}
