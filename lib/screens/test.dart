import 'package:flutter/material.dart';

class ScreenTest extends StatefulWidget {
  const ScreenTest({Key? key}) : super(key: key);

  @override
  State<ScreenTest> createState() => _ScreenTestState();
}

class _ScreenTestState extends State<ScreenTest> {
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
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  color: Colors.yellowAccent,
                ),
                Container(
                  height: 100,
                  color: Colors.white,
                ),
                Container(
                  height: 100,
                  color: Colors.blue,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 100,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
    );
  }
}
