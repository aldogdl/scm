import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widgets/texto.dart';
import '../browser_conn.dart';
import '../providers/browser_provider.dart';

class OpenBrowser extends StatefulWidget {

  final ValueChanged<void> onNext;
  const OpenBrowser({
    Key? key,
    required this.onNext
  }) : super(key: key);

  @override
  State<OpenBrowser> createState() => _OpenBrowserState();
}

class _OpenBrowserState extends State<OpenBrowser> {

  bool _isloading = false;

  @override
  Widget build(BuildContext context) {

    return Column(

      children: [
        Icon(Icons.public, size: 70, color: Colors.blue.withOpacity(0.3)),
        const Texto(txt: '¿El navegador CHROME está Abierto?', isBold: true, sz: 15, isCenter: true),
        const Divider(height: 5, color: Colors.green),
        const Texto(
          txt: 'Asegurate que el navegador este abierto y '
          'conectado a tu SCM', isCenter: true,
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () async {
            setState(() { _isloading = true; });
            context.read<BrowserProvider>().msgs = '';
            Future.delayed(const Duration(milliseconds:  1000), () async {
              await BrowserConn.lanzar(context.read<BrowserProvider>());
            });
          },
          icon: const Icon(Icons.not_started_outlined),
          label: const Texto(txt: 'Iniciar CHROME',)
        ),
        const SizedBox(height: 20),
        const Texto(
          txt: 'OBSERVACIONES', isCenter: true, txtC: Colors.amber,
        ),
        const Divider(height: 10, color: Colors.green),
        if((context.watch<BrowserProvider>().msgs != 'ERRCONX'))
          ... _observaciones()
        else
          _showErro(),
        const Spacer(),
        const SizedBox(height: 10),
        if(_isloading)
          Selector<BrowserProvider, int>(
            selector: (_, prov) => prov.pib,
            builder: (_, intp, __) {
              if(intp == 0) {
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
          onPressed: (context.watch<BrowserProvider>().pib != 0)
          ? () {
            _isloading = false;
            widget.onNext(null);
          }
          : null,
          child: Texto(
            txt: (context.watch<BrowserProvider>().pib != 0)
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

  ///
  List<Widget> _observaciones() {

    return [
      const Texto(
          txt: '1.- El arranque puede durar considerables minutos si '
          'previamente no fué iniciado el sistema, ya que se descarga '
          'un navegador en tu directorio local.',
          isCenter: false, txtC: Color.fromARGB(255, 202, 202, 202), sz: 13,
        ),
        const SizedBox(height: 10),
        const Texto(
          txt: '2.- Espera a que el navegador se visualice completamente en '
          'pantalla para proseguir con el siguiente paso de inicialización '
          'del sistema.',
          isCenter: false, txtC: Color.fromARGB(255, 202, 202, 202), sz: 13,
        ),
    ];
  }

  ///
  Widget _showErro() {

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.red.withOpacity(0.3),
        border: Border.all(
          color: Colors.red.withOpacity(0.7)
        ),
      ),
      child: const Texto(
        txt: 'Lo sentimos, el sistema detectó un conectividad nula '
        'con el navegador y el SCM no puede repararlo automáticamente. '
        'POR FAVOR, CIERRA MANUALMENTE EL NAVEGADOR E INICIA DE NUEVO.',
        isCenter: true,
        txtC: Color.fromARGB(255, 202, 202, 202), sz: 13,
      ),
    );
  }

}