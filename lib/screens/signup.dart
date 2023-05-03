import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/palette.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late double _phoneWidth;
  late double _phoneHeight;

  final _formKey = GlobalKey<FormState>();

  String userId = '';
  String userPassword = '';
  String userPasswordConfirm = '';
  TextEditingController userPasswordController = TextEditingController();
  TextEditingController userPasswordConfirmController = TextEditingController();

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

            Positioned(
                child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 110,
                    ),

                    // HANDCUFFS OPERATOR
                    SizedBox(
                      width: _phoneWidth,
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

                    // 아이디, 비밀번호, 비밀번호 확인
                    SizedBox(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
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

                                  // 비밀번호
                                  TextFormField(
                                    key: const ValueKey(2),
                                    controller: userPasswordController,
                                    keyboardType: TextInputType.text,
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

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  // 비밀번호 확인
                                  TextFormField(
                                    controller: userPasswordConfirmController,
                                    key: const ValueKey(3),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "비밀번호 확인을 입력하세요.";
                                      }
                                      if (userPasswordController.text !=
                                          userPasswordConfirmController.text) {
                                        return "비밀번호가 일치하지 않습니다.";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      userPasswordConfirm = value!;
                                    },
                                    onChanged: (value) {
                                      userPasswordConfirm = value;
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
                                      hintText: '비밀번호 확인',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.whiteTextColor,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 70,
                    ),

                    // 등록하기 버튼
                    Container(
                      // width: _phoneWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) {
                            //     return MainPageScreen();
                            //   }),
                            // );
                            // Navigator.pop(context);
                            Get.back();
                          } else {
                            // ScaffoldMessenger.of(context)
                            //     .showSnackBar(const SnackBar(
                            //   content: Text(
                            //     '입력값을 확인해주세요!',
                            //     textAlign: TextAlign.center,
                            //     style: TextStyle(
                            //       color: Colors.white,
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
                                '등록하기',
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
                      height: 20,
                    ),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
