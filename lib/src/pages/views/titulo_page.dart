import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../../config/sng_manager.dart';
import '../../vars/globals.dart';
import '../../widgets/texto.dart';

class TituloPage extends StatelessWidget {

  final String titulo;
  final ValueChanged<void> onRefresh;
  TituloPage({
    Key? key,
    required this.titulo,
    required this.onRefresh
  }) : super(key: key);

  final Globals _globals = getSngOf<Globals>();
  
  @override
  Widget build(BuildContext context) {

    return Container(
      width: appWindow.size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: _globals.colorEnProgreso,
      child: Row(
        children: [
          Texto(
            txt: titulo,
            isBold: true, isCenter: true, txtC: Colors.black,
          ),
          const Spacer(),
          IconButton(
            padding: const EdgeInsets.all(0),
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            onPressed: () => onRefresh(null),
            icon: const Icon(Icons.refresh, size: 18, color: Colors.greenAccent)
          )
        ],
      ),
    );
  }
}