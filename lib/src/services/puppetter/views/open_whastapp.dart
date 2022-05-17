import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widgets/texto.dart';
import '../browser_conn.dart';
import '../providers/browser_provider.dart';

class OpenWhastapp extends StatefulWidget {

  final ValueChanged<void> onNext;
  const OpenWhastapp({
    Key? key,
    required this.onNext
  }) : super(key: key);

  @override
  State<OpenWhastapp> createState() => _OpenWhastappState();
}

class _OpenWhastappState extends State<OpenWhastapp> {

  bool _isloading = false;
  
  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Icon(Icons.contact_support_outlined, size: 70, color: Colors.blue.withOpacity(0.3)),
        const Texto(txt: '¿Iniciar WhatsApp?', isBold: true, sz: 15, isCenter: true),
        const Divider(height: 5, color: Colors.green),
        const Texto(
          txt: 'Asegurate que el navegador este en abierto y '
          'conectado a tu SCM', isCenter: true,
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () async {
            setState(() { _isloading = true; });
            await BrowserConn.initWhatsapp();
          },
          icon: const Icon(Icons.contact_support_outlined),
          label: const Texto(txt: 'Iniciar WhatsApp')
        ),
        const SizedBox(height: 20),
        const Texto(
          txt: 'OBSERVACIONES', isCenter: true, txtC: Colors.amber,
        ),
        const Divider(height: 10, color: Colors.green),
        const Texto(
          txt: '1.- Inicializaremos Whatsapp, '
          'espera a que aparezca el QR inicial o la lista de '
          'contactos competamente.',
          isCenter: false, txtC: Color.fromARGB(255, 202, 202, 202), sz: 13,
        ),
        const SizedBox(height: 7),
        const Texto(
          txt: '2.- Leé el código QR para inicializar la aplicación y por favor, '
          'espera a visualizar correctamente la lista de CONTACTOS.',
          isCenter: false, txtC: Color.fromARGB(255, 202, 202, 202), sz: 13,
        ),
        const SizedBox(height: 7),
        const Texto(
          txt: '3.- No prosigas con el siguiente paso si no logras visualizar '
          'la caja de texto donde escribes los mensaje.',
          isCenter: false, txtC: Color.fromARGB(255, 202, 202, 202), sz: 13,
        ),
        const Spacer(),
        const SizedBox(height: 10),
        if(_isloading)
          Selector<BrowserProvider, String>(
            selector: (_, prov) => prov.titleCurrent,
            builder: (_, title, __) {
              if(title.isEmpty) {
                return const SizedBox(
                  width: 30, height: 30,
                  child: CircularProgressIndicator(),
                );
              }
              return const SizedBox();
            }
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: (context.watch<BrowserProvider>().titleCurrent.isNotEmpty)
          ? () {
            _isloading = false;
            widget.onNext(null);
          }
          : null,
          child: Texto(
            txt: (context.watch<BrowserProvider>().titleCurrent.isNotEmpty)
            ? 'SIGUIENTE' : 'EN ESPERA', txtC: Colors.white,
          )
        ),
        const SizedBox(height: 10),
        Texto(
          txt: 'PiB: ${context.watch<BrowserProvider>().pib}', txtC: Colors.white,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}