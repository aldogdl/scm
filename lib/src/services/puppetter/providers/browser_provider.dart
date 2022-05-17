import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:puppeteer/puppeteer.dart';

class BrowserProvider extends ChangeNotifier { 

  Browser? browser;
  Page? pagewa;
  
  ///
  String _titleCurrent = '';
  String get titleCurrent => _titleCurrent;
  set titleCurrent(String msg) {
    _titleCurrent =  msg;
    notifyListeners();
  }

  ///
  String _msgs = '';
  String get msgs => _msgs;
  set msgs(String msg) {
    _msgs =  msg;
    notifyListeners();
  }

  ///
  int _pib = 0;
  int get pib => _pib;
  set pib(int pibv) {
    _pib =  pibv;
    notifyListeners();
  }

  ///
  bool _isOk = false;
  bool get isOk => _isOk;
  set isOk(bool isOkv) {
    _isOk =  isOkv;
    notifyListeners();
  }

}