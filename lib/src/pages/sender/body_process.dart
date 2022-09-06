import 'package:flutter/material.dart';

class BodyProcess extends StatelessWidget {

  final double incProgress;
  final Color color;
  final Widget child;
  const BodyProcess({
    Key? key,
    required this.incProgress,
    required this.color,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(
                width: incProgress, color: color
              )
            ),
            Positioned.fill(
              top: 8,
              child: child
            )
          ],
        )
      )
    );
  }
}