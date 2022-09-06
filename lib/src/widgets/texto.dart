import 'package:flutter/material.dart';
import 'my_tool_tip.dart';

class Texto extends StatelessWidget {

  final String txt;
  final double sz;
  final Color txtC;
  final bool isBold;
  final bool isCenter;
  final int width;
  const Texto({
    required this.txt,
    this.sz = 14.0,
    this.txtC = const Color.fromARGB(255, 158, 158, 158),
    this.isBold = false,
    this.isCenter = false,
    this.width = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String txtSlice = txt;
    bool wSlice = false;

    if(width != 0) {
      if(txtSlice.length > width) {
        txtSlice = txtSlice.substring(0, width);
        txtSlice = '$txtSlice...';
        wSlice = true;
      }
    }

    Widget t = Text(
      txtSlice,
      textScaleFactor: 1,
      textAlign: (isCenter) ? TextAlign.center : TextAlign.left,
      style: TextStyle(
        fontSize: sz,
        color: txtC,
        fontWeight: (isBold) ? FontWeight.bold : FontWeight.normal
      ),
    );
    
    return (wSlice) ? MyToolTip(msg: txt, child: t) : t;
  }
}