import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../../../pages/sender/sender_view.dart';
import '../../../widgets/texto.dart';

class CheckStatus extends StatefulWidget {

  final ValueChanged<void> onNext;
  const CheckStatus({
    Key? key,
    required this.onNext
  }) : super(key: key);

  @override
  State<CheckStatus> createState() => _CheckStatusState();
}

class _CheckStatusState extends State<CheckStatus> {
  
  bool _isInit = false;
  List<String> checkings = [];

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      checkings = _getTaskChecking();
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.done_all_outlined, size: 20, color: Colors.blue.withOpacity(0.3)),
            const SizedBox(width: 10),
            const Texto(txt: 'Checar el SISTEMA', isBold: true, sz: 15, isCenter: true),
          ],
        ),
        const Divider(height: 5, color: Colors.green),
        const Texto(
          txt: 'Presiona cada acción listada en la parte inferior '
          'y revisa que cada una esté en condiciones de optimas.',
          isCenter: true,
        ),
        const SizedBox(height: 10),
        const Texto(
          txt: 'ACCIONES AUTOMÁTICAS', isCenter: true, txtC: Colors.amber,
        ),
        const Divider(height: 10, color: Colors.green),
        Container(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10
          ),
          constraints: BoxConstraints.expand(
            height: appWindow.size.height * 0.22
          ),
          color: Colors.black.withOpacity(0.3),
          child: ListView.builder(
            itemCount: checkings.length,
            itemBuilder: (_, inx) => _tileTask(inx)
          ),
        ),
        const SizedBox(height: 10),
        const SenderView(isCheck: true)
      ],
    );
  }

  ///
  List<String> _getTaskChecking() {
    return [
      'Detectando Caja de Búsqueda',
      'Escribiendo nombre del Contacto',
      'Entrando al Chat del Contactos',
      'Revisando caja y escribiendo Msg.',
      'Revisando Mensajes',
      'Enviar mensaje de Bienvenida'
    ];
  }

  ///
  Widget _tileTask(int inx) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.done, size: 15, color: Colors.orange),
          const SizedBox(width: 5),
          Texto(
            txt: checkings[inx],
            isCenter: false, txtC: const Color.fromARGB(255, 202, 202, 202), sz: 13,
          )
        ],
      ),
    );
  }

}