import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:police/mqtt/MQTTManager.dart';
import 'package:police/service/guardInfo.dart';

import '../config/palette.dart';
import '../mqtt/state/MQTTAppState.dart';
import '../service/handcuffInfo.dart';

class HandcuffScreen extends StatefulWidget {
  const HandcuffScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HandcuffScreen> createState() => _HandcuffScreenState();
}

class _HandcuffScreenState extends State<HandcuffScreen> {
  final _formKey = GlobalKey<FormState>();

  final HandcuffInfo _handcuffInfo = Get.find();
  final MQTTAppState _mqttAppState = Get.find();
  final GuardInfo _guardInfo = Get.find();

  final MQTTManager _mqttManager = Get.arguments;

  String serialNumber = '';
  String serialNumberConfirm = '';
  TextEditingController serialNumberController = TextEditingController();
  TextEditingController serialNumberConfirmController = TextEditingController();

  // String userId = Get.arguments;

  late double originalHeight;

  void _validationCheck() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Palette.backgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: Palette.whiteTextColor,
        ),
        // iconTheme: const IconThemeData(
        //   color: Palette.whiteTextColor,
        // ),
        centerTitle: true,
        title: Text(
          _guardInfo.id,
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

      // resizeToAvoidBottomInset: false,
      // todo: 키보드가 올라오거나 내려감에 의해 이벤트가 발생하는 것을 방지하기 위해
      //  resizeToAvoidBottomInset를 지정해도 계속되는 것은
      //  mediaquery도 영향을 받아서 이다.
      //  이를 해결하기 위해서는 sizer package를 이용하여 해결해야 한다.
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // inset 영향으로 Copyright가 올라오는 것을 막기위해 전체 크기의 container를 바닥에 깐다.
            Positioned(
              child: Container(
                color: Palette.backgroundColor,
              ),
            ),

            // copyright
            Positioned(
              top: MediaQuery.of(context).size.height - 120,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Copyright © TERRAONE Corp. All Rights Reserved.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(
                          textStyle: const TextStyle(
                        color: Palette.whiteTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      )),
                    ),
                  ],
                ),
              ),
            ),

            // 수갑이미지, 수갑번호, 수갑번호확인, 등록하기
            Positioned(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 80,
                      ),

                      // 수갑 이미지
                      Container(
                        height: 130,
                        width: MediaQuery.of(context).size.width - 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Palette.darkButtonColor,
                        ),
                        child: Image.asset('images/handcuff.png'),
                      ),
                      const SizedBox(
                        height: 80,
                      ),

                      SizedBox(
                        child: Column(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Form(
                                key: _formKey,
                                child: Column(children: [
                                  // 수갑 번호
                                  TextFormField(
                                    key: const ValueKey(1),
                                    controller: serialNumberController,
                                    keyboardType: TextInputType.text,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "수갑번호를 입력하세요.";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      serialNumber = value!;
                                    },
                                    onChanged: (value) {
                                      serialNumber = value;
                                    },
                                    style: const TextStyle(
                                        color: Palette.whiteTextColor),
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Palette.darkButtonColor,
                                      prefixIcon: Icon(
                                        Icons.numbers,
                                        color: Palette.whiteTextColor,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      hintText: '수갑번호',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.whiteTextColor,
                                      ),
                                      // contentPadding: EdgeInsets.all(10.0),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  // 수갑번호 확인
                                  TextFormField(
                                    key: const ValueKey(2),
                                    controller: serialNumberConfirmController,
                                    keyboardType: TextInputType.text,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "수갑번호 확인을 입력하세요.";
                                      }

                                      if (serialNumberController.text !=
                                          serialNumberConfirmController.text) {
                                        return "수갑번호가 일치하지 않습니다.";
                                      }

                                      return null;
                                    },
                                    onSaved: (value) {
                                      serialNumberConfirm = value!;
                                    },
                                    onChanged: (value) {
                                      serialNumberConfirm = value;
                                    },
                                    style: const TextStyle(
                                        color: Palette.whiteTextColor),
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Palette.darkButtonColor,
                                      prefixIcon: Icon(
                                        Icons.check,
                                        color: Palette.whiteTextColor,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      hintText: '수갑번호확인',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.whiteTextColor,
                                      ),
                                      // contentPadding: EdgeInsets.all(10.0),
                                    ),
                                  ),
                                ]),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                      // 등록하기 버튼
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            // 임시 수갑 정보 추가
                            _handcuffInfo.addHandcuff(serialNumber);
                            // 등록된 수갑의 serial 번호로 subscription
                            _mqttManager.subscribe(serialNumber);
                            Get.back();
                          } else {
                            // ScaffoldMessenger.of(context)
                            //     .showSnackBar(const SnackBar(
                            //   content: Text(
                            //     '입력값을 확인해주세요!',
                            //     textAlign: TextAlign.center,
                            //     style: TextStyle(
                            //       color: Colors.black,
                            //     ),
                            //   ),
                            //   backgroundColor: Colors.blue,
                            // ));
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width - 40,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Palette.lightButtonColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Center(
                              child: Text('등록하기',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.notoSans(
                                    textStyle: const TextStyle(
                                        color: Palette.darkTextColor),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    height: 1.4,
                                  )),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
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
}
