import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    _phoneHeight = MediaQuery.of(context).size.height;
    _phoneWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
            height: _phoneHeight,
            width: _phoneWidth,
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // HANDCUFFS OPERATOR
                Positioned(
                    top: 111,
                    child: SizedBox(
                      width: _phoneWidth,
                      height: 66,
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
                    )),
                // 아이디 입력
                Positioned(
                  top: 290,
                  child: SizedBox(
                    width: 320,
                    height: 60,
                    child: TextFormField(
                      style: const TextStyle(color: Palette.darkButtonColor),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Palette.darkButtonColor,
                        prefixIcon: Icon(
                          Icons.account_circle,
                          color: Palette.whiteTextColor,
                        ),
                        enabledBorder: OutlineInputBorder(
                          // borderSide: BorderSide(color: Color(0xffa0a0a0)),
                          borderRadius: BorderRadius.all(
                            Radius.circular(35.0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          // borderSide: BorderSide(color: Color(0xffa0a0a0)),
                          borderRadius: BorderRadius.all(
                            Radius.circular(35.0),
                          ),
                        ),
                        hintText: '아이디',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Palette.whiteTextColor,
                        ),
                        // contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                ),
                // 비밀번호 입력
                Positioned(
                  top: 360,
                  child: SizedBox(
                    width: 320,
                    height: 60,
                    child: TextFormField(
                      style: const TextStyle(color: Color(0xffa0a0a0)),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Palette.darkButtonColor,
                        prefixIcon: Icon(
                          Icons.password,
                          color: Palette.whiteTextColor,
                        ),
                        enabledBorder: OutlineInputBorder(
                          // borderSide: BorderSide(color: Color(0xffa0a0a0)),
                          borderRadius: BorderRadius.all(
                            Radius.circular(35.0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          // borderSide: BorderSide(color: Color(0xffa0a0a0)),
                          borderRadius: BorderRadius.all(
                            Radius.circular(35.0),
                          ),
                        ),
                        hintText: '비밀번호',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Palette.whiteTextColor,
                        ),
                        // contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                ),
                // 비밀번호 입력 확인
                Positioned(
                  top: 430,
                  child: SizedBox(
                    width: 320,
                    height: 60,
                    child: TextFormField(
                      style: const TextStyle(color: Color(0xffa0a0a0)),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Palette.darkButtonColor,
                        prefixIcon: Icon(
                          Icons.password,
                          color: Palette.whiteTextColor,
                        ),
                        enabledBorder: OutlineInputBorder(
                          // borderSide: BorderSide(color: Color(0xffa0a0a0)),
                          borderRadius: BorderRadius.all(
                            Radius.circular(35.0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          // borderSide: BorderSide(color: Color(0xffa0a0a0)),
                          borderRadius: BorderRadius.all(
                            Radius.circular(35.0),
                          ),
                        ),
                        hintText: '비밀번호확인',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Palette.whiteTextColor,
                        ),
                        // contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                ),
                // 이름 입력
                Positioned(
                  top: 500,
                  child: SizedBox(
                    width: 320,
                    height: 60,
                    child: TextFormField(
                      style: const TextStyle(color: Color(0xffa0a0a0)),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Palette.darkButtonColor,
                        prefixIcon: Icon(
                          Icons.account_box,
                          color: Palette.whiteTextColor,
                        ),
                        enabledBorder: OutlineInputBorder(
                          // borderSide: BorderSide(color: Color(0xffa0a0a0)),
                          borderRadius: BorderRadius.all(
                            Radius.circular(35.0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          // borderSide: BorderSide(color: Color(0xffa0a0a0)),
                          borderRadius: BorderRadius.all(
                            Radius.circular(35.0),
                          ),
                        ),
                        hintText: '이름',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Palette.whiteTextColor,
                        ),
                        // contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                ),
                // 근무지 입력
                Positioned(
                  top: 570,
                  child: SizedBox(
                    width: 320,
                    height: 60,
                    child: TextFormField(
                      style: const TextStyle(color: Palette.whiteTextColor),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Palette.darkButtonColor,
                        prefixIcon: Icon(
                          Icons.work,
                          color: Color(0xffa0a0a0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          // borderSide: BorderSide(color: Color(0xffa0a0a0)),
                          borderRadius: BorderRadius.all(
                            Radius.circular(35.0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          // borderSide: BorderSide(color: Color(0xffa0a0a0)),
                          borderRadius: BorderRadius.all(
                            Radius.circular(35.0),
                          ),
                        ),
                        hintText: '근무처,부서',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Palette.whiteTextColor,
                        ),
                        // contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                ),
                // 가입하기 버튼
                Positioned(
                  top: 640,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 320,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Palette.lightButtonColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Center(
                            child: Text(
                              '가입하기',
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
                ),
                // Copyright
                Positioned(
                  top: 769,
                  child: Align(
                    child: SizedBox(
                      width: _phoneWidth,
                      height: 17,
                      child: Text(
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
                    ),
                  ),
                ),
              ],
            )));
  }
}
