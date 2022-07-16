import 'package:flutter/material.dart' show Size;

class BrowserSng {

  int browserPid = 0;
  String wsEndpoint = '0';
  final int port = 9222;
  final String fldPupp = 'puppeteer';
  final String pageWhatsapp = 'WhatsApp';
  final String uriWhatsapp = 'https://web.whatsapp.com/';

  List<String> getArgs(Size tamScreen) {

    var va = tamScreen.width * 0.27;
    final poss = int.parse(va.toStringAsFixed(0));
    va = tamScreen.width * 0.73;
    final width = int.parse(va.toStringAsFixed(0));
    final alto = tamScreen.height - 118;    
    final height = int.parse(alto.toStringAsFixed(0));

    return [
      '--remote-debugging-port=$port',
      '--window-position=$poss,0',
      '--window-size=$width${"x"}$height'
    ];
  }
}