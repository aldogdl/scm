import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import 'texto.dart';
import 'titulo_seccion.dart';

class SinData extends StatelessWidget {

  final String msg;
  final String main;
  final bool isDark;
  final bool withTit;
  const SinData({
    Key? key,
    required this.msg,
    required this.main,
    this.isDark = true,
    this.withTit = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      constraints: BoxConstraints.expand(
        width: appWindow.size.width
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(withTit)
            ...[
              const TituloSeccion(titulo: 'Por el momento...'),
              const SizedBox(height: 8),
            ],
          Expanded(
            child: ListView(
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  size: 100,
                  color: (isDark)
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.3)
                ),
                // const SizedBox(height: 5),
                Texto(
                  txt: 'No hay $msg',
                  sz: 15, isCenter: true,
                ),
                Texto(
                  txt: main.toUpperCase(),
                  txtC: (isDark)
                  ? Colors.white
                  : Colors.grey,
                  sz: 17, isCenter: true, isBold: true,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}