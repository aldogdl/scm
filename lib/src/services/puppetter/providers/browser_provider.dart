import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:puppeteer/puppeteer.dart';

class BrowserProvider extends ChangeNotifier { 

  Browser? browser;
  Page? pagewa;
  String targetId   = '';
  bool isChecking = false;
  
  ///
  String _titleCurrent = '';
  String get titleCurrent => _titleCurrent;
  set titleCurrent(String msg) {
    _titleCurrent =  msg;
    notifyListeners();
  }

  ///
  bool _isOk = false;
  bool get isOkCp => _isOk;
  set isOkCp(bool isOkv) {
    _isOk =  isOkv;
    notifyListeners();
  }

  ///
  void cerrarSesion() {
    _isOk = false;
    browser = null;
    pagewa = null;
    targetId = '';
    _titleCurrent = '';
  }
}