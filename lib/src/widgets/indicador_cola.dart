import 'package:flutter/material.dart';

class IndicadorCola extends StatelessWidget {

  final String onOff;
  final Color colorOn;
  final Color colorOff;
  final double height;
  const IndicadorCola({
    Key? key,
    required this.onOff,
    required this.colorOn,
    required this.colorOff,
    this.height = 2
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Container(
      height: height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getColors(),
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )
      ),
    );
  }

  List<Color> _getColors() {
    final middle = (onOff == 'on') ? colorOn : colorOff;
    return [colorOff, middle, middle, colorOff];
  }
}