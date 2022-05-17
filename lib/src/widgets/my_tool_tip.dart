import 'package:flutter/material.dart';

class MyToolTip extends StatelessWidget {

  final Widget child;
  final String msg;
  const MyToolTip({
    required this.msg,
    required this.child,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Tooltip(
      waitDuration: const Duration(milliseconds: 500),
      message: msg,
        decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          width: 0.7,
          color: Colors.grey
        ),
        borderRadius: BorderRadius.circular(3)
      ),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      textStyle: TextStyle(
        color: Colors.grey[200],
        fontWeight: FontWeight.normal,
        fontSize: 12
      ),
      child: child
    );
  }
}