import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:police/screens/main_page.dart';
import 'package:police/screens/signup.dart';

import '../config/palette.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late double _phoneWidth;
  late double _phoneHeight;

  final _formKey = GlobalKey<FormState>();

  String userId = '';
  String userPassword = '';

  @override
  Widget build(BuildContext context) {
    _phoneHeight = MediaQuery.of(context).size.height;
    _phoneWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: GestureDetector (
        onTap: () {
          FocusScope.of(context).unfocus(); // 키보드 사라지게..
        },
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
                  style: const TextStyle(color: Color(0xffa0a0a0)),
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
            // 로그인
            Positioned(
              top: 500,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MainPageScreen();
                    }));
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
            ),
            // 회원가입 버튼
            Positioned(
              top: 570,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SignupScreen();
                    }));
                  },
                  child: Container(
                    width: 320,
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
        ),
      ),
    );
  }
}
