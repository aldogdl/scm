import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/puppetter/browser_conn.dart';
import '../../../services/puppetter/providers/browser_provider.dart';
import '../../../services/puppetter/repository/puppe_repository.dart';
import '../../../widgets/texto.dart';


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

  final pupEm = PuppeRepository();
  final _connBrow = ValueNotifier<String>('Presiona <Iniciar CHROME>');
  Timer? timer;
  bool _isloading = false;
  bool _isConnect = false;
  bool _isInit = false;
  late BrowserProvider bprov;

  @override
  void dispose() {
    if(timer != null) {
      timer!.cancel();
    }
    _connBrow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      bprov = context.read<BrowserProvider>();
      if(bprov.browser != null) {
        if(bprov.browser!.isConnected) {
          _isConnect = true;
        }
      }
    }

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
          onPressed: () async => await _lanzarBrowser(),
          icon: const Icon(Icons.not_started_outlined),
          label: const Texto(txt: 'Iniciar CHROME',)
        ),
        const SizedBox(height: 20),
        const Texto(
          txt: 'OBSERVACIONES', isCenter: true, txtC: Colors.amber,
        ),
        const Divider(height: 10, color: Colors.green),
        ... _observaciones(),
        const Spacer(),
        const SizedBox(height: 10),

        if(_isloading)
          const SizedBox(
            width: 15, height: 15,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: (_isConnect)
          ? () {
            _isloading = false;
            widget.onNext(null);
          }
          : null,
          child: Texto(
            txt: (_isConnect)
            ? 'SIGUIENTE' : 'EN ESPERA', txtC: Colors.white,
          )
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<String>(
          valueListenable: _connBrow,
          builder: (_, val, __) {

            Color color = (val.startsWith('[X]')) ? Colors.orange : Colors.grey;

            return Texto(
              txt: val, sz: 13,
              txtC: color,
            );
          }
        )
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
  Future<void> _lanzarBrowser() async {

    _connBrow.value = 'Espera un Momento por favor';
    setState(() { _isloading = true; });

    bprov.browser = await BrowserConn.lanzar();
    if(BrowserConn.typeErr.isNotEmpty) {
      timer = Timer.periodic(const Duration(milliseconds: 5000), _probBrow);
    }
  }

  ///
  void _probBrow(_) async {

    if(timer!.tick >= 5) {
      timer!.cancel();
      _connBrow.value = '[X] Inténtalo nuevamente.';
      return;
    }

    _connBrow.value = 'No. de revisión ${timer!.tick}/5';
    bprov.browser = await BrowserConn.tryConnect();
    if(bprov.browser != null) {
      final metadata = await pupEm.getListTargets();
      if(metadata.isNotEmpty) {
        timer!.cancel();
        if(mounted) {
          setState(() {
            _isloading = false;
            _isConnect = true;
          });
        }
      }
    }

  }
}