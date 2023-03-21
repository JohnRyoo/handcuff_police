import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../config/palette.dart';
import '../../../service/handcuffInfo.dart';
import '../../handcuff.dart';

class HandcuffAdd extends StatefulWidget {
  const HandcuffAdd({Key? key}) : super(key: key);

  @override
  State<HandcuffAdd> createState() => _HandcuffAddState();
}

class _HandcuffAddState extends State<HandcuffAdd> {
  late bool _isHandcuffRegistered;

  @override
  Widget build(BuildContext context) {
    _isHandcuffRegistered = context.watch<HandcuffInfo>().isHandcuffRegistered;

    print("_HandcuffAddState : " + _isHandcuffRegistered.toString());

    if (!_isHandcuffRegistered) {
      return SizedBox(
        child: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return HandcuffScreen();
            }));
          },
          child: Container(
            padding: const EdgeInsets.all(0),
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Color(0xff00e693),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
    } else {
      // 수갑 삭제 버튼
      return SizedBox(
        child: GestureDetector(
          onTap: () {
            _deleteHandcuff();
          },
          child: Container(
            padding: const EdgeInsets.all(0),
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Palette.darkButtonColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.clear,
                color: Palette.darkTextColor,
              ),
            ),
          ),
        ),
      );
    }
    ;
  }

  Future _deleteHandcuff() async {
    return await showDialog(
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
                context.read<HandcuffInfo>().isHandcuffRegistered = false;
                Navigator.pop(context);
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
                Navigator.pop(context);
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
  }
}
