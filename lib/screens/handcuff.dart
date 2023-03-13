import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:police/screens/signup.dart';
import 'package:police/screens/test.dart';

class HandcuffScreen extends StatefulWidget {
  const HandcuffScreen({Key? key}) : super(key: key);

  @override
  State<HandcuffScreen> createState() => _HandcuffScreenState();
}

class _HandcuffScreenState extends State<HandcuffScreen> {
  late double _phoneWidth;
  late double _phoneHeight;

  @override
  Widget build(BuildContext context) {
    _phoneHeight = MediaQuery.of(context).size.height;
    _phoneWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.center,
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
                    color: const Color(0x19ffffff),
                  ),
                  child: Image.asset('images/handcuff.png'),
                ),
                const SizedBox(
                  height: 80,
                ),
                // 수갑 번호
                SizedBox(
                  height: 60,
                  width: _phoneWidth - 40,
                  child: TextFormField(
                    style: const TextStyle(color: Color(0xffa0a0a0)),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0x19ffffff),
                      prefixIcon: Icon(
                        Icons.numbers,
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
                      hintText: '수갑번호',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xffa0a0a0),
                      ),
                      // contentPadding: EdgeInsets.all(10.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // 수갑 번호 확인
                SizedBox(
                  height: 60,
                  width: _phoneWidth - 40,
                  child: TextFormField(
                    style: const TextStyle(color: Color(0xffa0a0a0)),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0x19ffffff),
                      prefixIcon: Icon(
                        Icons.check,
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
                      hintText: '수갑번호확인',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xffa0a0a0),
                      ),
                      // contentPadding: EdgeInsets.all(10.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
                // 등록하기 버튼
                GestureDetector(
                  onTap: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) {
                    //       return const ScreenTest();
                    //     }));
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: _phoneWidth - 40,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xff00e693),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Center(
                        child: Text(
                          '등록하기',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(
                              textStyle: const TextStyle(
                                color: Color(0xff333333),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: Text(
                  'Copyright © TERRAONE Corp. All Rights Reserved.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                      textStyle: const TextStyle(
                        color: Color(0xffa0a0a0),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      )),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
