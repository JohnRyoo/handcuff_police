import 'package:flutter/material.dart';

class HandcuffWatchdog with ChangeNotifier {
  bool handcuffChanged = false;

  void setHandcuffChanged() {
    handcuffChanged = true;
    notifyListeners();
  }

  void setHandcuffClear() {
    handcuffChanged = false;
  }
}