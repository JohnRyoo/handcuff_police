import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/palette.dart';
import 'login.dart';

enum HandcuffMenu { deleteHandcuff, logout, exit }

class HandcuffScreen extends StatefulWidget {
  const HandcuffScreen({Key? key}) : super(key: key);

  @override
  State<HandcuffScreen> createState() => _HandcuffScreenState();
}

class _HandcuffScreenState extends State<HandcuffScreen> {
  late double _phoneWidth;
  late double _phoneHeight;

  final _formKey = GlobalKey<FormState>();

  String serialNumber = '';
  String serialNumberConfirm = '';
  TextEditingController serialNumberController = TextEditingController();
  TextEditingController serialNumberConfirmController = TextEditingController();

  String userId = 'ID_0001';

  late double originalHeight;

  void _validationCheck() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    _phoneHeight = MediaQuery.of(context).size.height;
    _phoneWidth = MediaQuery.of(context).size.width;

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

      // resizeToAvoidBottomInset: false,
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
              top: _phoneHeight - 40,
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

            // 수갑, 수갑번호, 수갑번호확인, 등록하기
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
                        width: _phoneWidth - 40,
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
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                '입력값을 확인해주세요!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              backgroundColor: Colors.blue,
                            ));
                          }
                        },
                        child: Container(
                          width: _phoneWidth - 40,
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


  void _selectedActionMenuItem(BuildContext context, item) {
    switch (item) {
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
      fontSize: 16,
      textColor: Palette.darkTextColor,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
