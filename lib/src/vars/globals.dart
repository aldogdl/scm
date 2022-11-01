import 'package:bitsdojo_window/bitsdojo_window.dart' show WindowButtonColors;
import 'package:flutter/material.dart' show FocusNode, Color, Size;

import '../entity/contacto_entity.dart';

class Globals {

  String ver = '1.4.5';
  Size sizeWin = const Size(0, 0);
  bool isLocalConn = false;
  String wifiName = '';
  String myIp = '';
  String ipHarbi = '';
  String portHarbi = '';
  Map<String, dynamic> ipDbs = {};
  ContactoEntity user = ContactoEntity();
  FocusNode focusMain = FocusNode();
  
  final double tamToolBar = 50;
  final double tamMiddle  = 300;
  final colorEnProgreso = const Color.fromARGB(255, 47, 180, 52);
  final sttBarrColorOn = const Color.fromARGB(255, 7, 151, 43);
  final sttBarrColorOff = const Color.fromARGB(255, 114, 27, 120);
  final sttBarrColorSt = const Color.fromARGB(255, 31, 81, 245);
  final borderColor = const Color.fromARGB(255, 0, 0, 0);
  final sidebarColor = const Color.fromARGB(255, 51, 51, 51);
  final middleColor = const Color.fromARGB(255, 37, 37, 38);
  final backgroundStartColor = const Color.fromARGB(255, 30, 30, 30);
  final backgroundEndColor = const Color.fromARGB(255, 51, 51, 51);
  final buttonColors = WindowButtonColors(
      iconNormal: const Color.fromARGB(255, 199, 199, 199),
      mouseOver: const Color.fromARGB(255, 63, 63, 63),
      mouseDown: const Color.fromARGB(255, 128, 83, 6),
      iconMouseOver: const Color.fromARGB(255, 199, 199, 199),
      iconMouseDown: const Color.fromARGB(255, 255, 255, 255)
  );
}