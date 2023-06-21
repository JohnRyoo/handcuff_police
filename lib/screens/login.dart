import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:police/service/guardInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/palette.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  GuardInfo guardInfo = Get.find();

  String userId = '';
  String userPassword = '';

  void _validationCheck() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 키보드 사라지게..
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
              top: MediaQuery.of(context).size.height - 40,
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
            Positioned(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 110,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        'HANDCUFFS\nOPERATOR',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSans(
                          textStyle: const TextStyle(
                            color: Palette.headTextColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 110,
                    ),

                    // 아이디, 비밀번호 입력
                    SizedBox(
                      // width: _phoneWidth,
                      child: Column(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // 아이디
                                  TextFormField(
                                    key: const ValueKey(1),
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 4) {
                                        return '아이디에 최소 4자 이상을 입력하세요.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      userId = value!;
                                    },
                                    onChanged: (value) {
                                      userId = value;
                                    },
                                    style: const TextStyle(
                                        color: Palette.whiteTextColor),
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Palette.darkButtonColor,
                                      prefixIcon: Icon(
                                        Icons.account_circle,
                                        color: Palette.whiteTextColor,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        // borderSide: BorderSide(
                                        //   color: Colors.red,
                                        // ),
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
                                      hintText: '아이디',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.whiteTextColor,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),
                                  // 비밀 번호
                                  TextFormField(
                                    key: const ValueKey(2),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 6) {
                                        return "비밀번호는 최소 7자리 이상입니다.";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      userPassword = value!;
                                    },
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    style: const TextStyle(
                                        color: Palette.whiteTextColor),
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Palette.darkButtonColor,
                                      prefixIcon: Icon(
                                        Icons.password,
                                        color: Palette.whiteTextColor,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        // borderSide: BorderSide(
                                        //   color: Colors.red,
                                        // ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      hintText: '비밀번호',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.whiteTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 90,
                    ),

                    // 로그인 버튼
                    Container(
                      // width: _phoneWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: GestureDetector(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(builder: (context) {
                            //     return MainPageScreen();
                            //   }),
                            // );
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            List<String>? handcuffList =
                                pref.getStringList("HandcuffList") ?? []; // null 인 경우 []

                            guardInfo.id = userId;
                            Get.offNamed("/mainpage", arguments: userId);
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
                          height: 60,
                          decoration: BoxDecoration(
                            color: Palette.lightButtonColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Center(
                              child: Text(
                                '로그인',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.notoSans(
                                    textStyle: const TextStyle(
                                  color: Palette.darkTextColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  height: 1.4,
                                )),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // 회원가입 버튼
                    Container(
                      // width: _phoneWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) {
                          //   return SignupScreen();
                          // }));
                          Get.toNamed("/signup");
                        },
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Palette.lightButtonColor),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Center(
                              child: Text(
                                '회원가입',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.notoSans(
                                    textStyle: const TextStyle(
                                  color: Palette.lightTextColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  height: 1.4,
                                )),
                              ),
                            ),
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
          ],
        ),
      ),
      // floatingActionButton: Stack(children: <Widget>[
      //   Align(
      //     alignment: Alignment.bottomCenter,
      //     child: FloatingActionButton(
      //       onPressed: () {
      //         print("progress bar... ");
      //       },
      //       child: Container(
      //         color: Colors.black,
      //         child: GFProgressBar(
      //           padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
      //           percentage: 0.6,
      //           width: 70,
      //           radius: 65,
      //           type: GFProgressType.circular,
      //           backgroundColor: Colors.red,
      //           progressBarColor: Colors.white,
      //           child: const Text(
      //             '90',
      //             textAlign: TextAlign.center,
      //             style: TextStyle(fontSize: 16, color: Colors.white),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ]),
    );
  }
}
