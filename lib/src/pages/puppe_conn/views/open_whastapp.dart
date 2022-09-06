import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/puppetter/browser_conn.dart';
import '../../../services/puppetter/providers/browser_provider.dart';
import '../../../services/puppetter/repository/puppe_repository.dart';
import '../../../services/puppetter/vars_puppe.dart';
import '../../../widgets/texto.dart';

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

  final pupEm = PuppeRepository();
  final _connWa = ValueNotifier<String>('Presiona <Iniciar WhatsApp>');
  Timer? timer;
  bool _isloading = false;
  bool _isInit = false;
  late BrowserProvider bprov;

  @override
  void dispose() {
    if(timer != null) {
      timer!.cancel();
    }
    _connWa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      bprov = context.read<BrowserProvider>();
      BrowserConn.typeErr = '';
    }

    return Column(
      children: [
        Icon(Icons.contact_support_outlined, size: 70, color: Colors.blue.withOpacity(0.3)),
        const Texto(txt: '¿Iniciar WhatsApp?', isBold: true, sz: 15, isCenter: true),
        const Divider(height: 5, color: Colors.green),
        const Texto(
          txt: 'Asegurate que el navegador este abierto y '
          'conectado a tu SCM', isCenter: true,
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () async => _openPage(),
          icon: const Icon(Icons.contact_support_outlined),
          label: const Texto(txt: 'Iniciar WhatsApp')
        ),
        const SizedBox(height: 20),
        ... _observaciones(),
        const Spacer(),
        const SizedBox(height: 10),
        if(_isloading)
          Selector<BrowserProvider, String>(
            selector: (_, prov) => prov.titleCurrent,
            builder: (_, title, __) {
              if(title.isEmpty) {
                return const SizedBox(
                  width: 15, height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
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
        ValueListenableBuilder<String>(
          valueListenable: _connWa,
          builder: (_, val, __) {

            Color color = (val.startsWith('[X]')) ? Colors.orange : Colors.grey;
            
            return Texto(
              txt: val, sz: 13,
              txtC: color,
            );
          }
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  ///
  void _openPage() async {

    final bprov = context.read<BrowserProvider>();

    if(bprov.browser != null) {
      _connWa.value = 'Espera un Momento por favor';
      setState(() { _isloading = true; });

      final firstPage = await bprov.browser!.pages;
      if(firstPage.isNotEmpty) {
        final res = await BrowserConn.tryLunchWhatsapp(firstPage.first);
        if(BrowserConn.typeErr.isNotEmpty) {
          timer = Timer.periodic(const Duration(milliseconds: 8000), _checkConnection);
        }else{

          if(res.toLowerCase().contains(pageWhatsapp.toLowerCase())) {
            bprov.titleCurrent = res;
            timer!.cancel();
            if(mounted) {
              setState(() {
                _isloading = false;
              });
            }
          }else{
            timer = Timer.periodic(const Duration(milliseconds: 8000), _checkConnection);
          }
        }
      }
    }
  }

  ///
  List<Widget> _observaciones() {

    return [
      const Texto(
        txt: 'OBSERVACIONES', isCenter: true, txtC: Colors.amber,
      ),
      const Divider(height: 10, color: Colors.green),
      const SizedBox(height: 7),
      const Texto(
        txt: '1.- Leé el código QR para inicializar y/o '
        'espera a visualizar correctamente la lista de contactos.',
        isCenter: false, txtC: Color.fromARGB(255, 202, 202, 202), sz: 13,
      ),
      const SizedBox(height: 7),
      const Texto(
        txt: '>> Entra a cualquier CHAT y revisar lo siguiente:',
        isCenter: false, txtC: Color.fromARGB(255, 202, 202, 202), sz: 13,
      ),
      const SizedBox(height: 7),
      const Texto(
        txt: 'a).- Es importante que logres ver '
        'la caja de texto donde escribes los mensaje.',
        isCenter: false, txtC: Color.fromARGB(255, 202, 202, 202), sz: 13,
      ),
      const SizedBox(height: 7),
      const Texto(
        txt: 'b).- No continues, si no logras ver claramente '
        'la barra de Título del Chat.',
        isCenter: false, txtC: Color.fromARGB(255, 202, 202, 202), sz: 13,
      ),
    ];
  }

  ///
  void _checkConnection(_) async {
    
    _connWa.value = 'No. de revisión ${timer!.tick}';

    if(bprov.browser != null) {
      final metadata = await pupEm.getListTargets();
      if(metadata.isNotEmpty) {
        
        final hasWs = metadata.where(
          (e) => e['url'].toString().toLowerCase() == uriWhatsapp.toLowerCase()
        );
        if(hasWs.isNotEmpty) {
          bprov.targetId = '${hasWs.first['id']}';
          bprov.titleCurrent = '${hasWs.first['title']}';
          bprov.pagewa = await BrowserConn.getPageByIdTarget(
            bprov.browser!, bprov.targetId
          );
          if(bprov.pagewa != null) {
            timer!.cancel();
            if(mounted) {
              setState(() {
                _isloading = false;
              });
            }
          }
        }
      }
    }
  }

}