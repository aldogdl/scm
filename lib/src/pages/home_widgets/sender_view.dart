import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'sender/views/chk_conn.dart';
import 'sender/views/sender_process.dart';
import '../../providers/process_provider.dart';
import '../../providers/terminal_provider.dart';
import '../../widgets/texto.dart';
import '../../widgets/tile_contacts.dart';

class SenderView extends StatefulWidget {

  final bool isCheck;
  const SenderView({
    Key? key,
    this.isCheck = false
  }) : super(key: key);

  @override
  State<SenderView> createState() => _SenderViewState();
}

class _SenderViewState extends State<SenderView> {

  late final ProcessProvider _pprov;

  bool _isInit = false;
  final bool _stop = false;

  @override
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(widget.isCheck) {
        _pprov.isTest = true;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _pprov  = context.read<ProcessProvider>();
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 0.41,
      margin: const EdgeInsets.only(
        top: 10, right: 10, bottom: 8, left: 10
      ),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey.withOpacity(0.3),
        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            offset: Offset(1,1)
          )
        ]
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey.withOpacity(0.3),
          border: Border.all(color: const Color.fromARGB(255, 90, 90, 90)),
        ),
        child: Column(
          children: [
            _conectionAndPages(),
            const SizedBox(height: 8),
            Selector<ProcessProvider, int>(
              selector: (_, prov) => prov.receiverViewer,
              builder: (_, rec, child) {
                
                if(_pprov.receiverCurrent == null){
                  return child!;
                }
                if(_pprov.enProceso.id == 0){
                  return child!;
                }
                return _tileForSend();
              },
              child: const Center(
                child: Icon(
                  Icons.contact_mail_outlined,
                  size: 70, color: Color.fromARGB(255, 87, 87, 87)
                ),
              ),
            )
          ],
        )
      ),
    );
  }

  ///
  Widget _conectionAndPages() {

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.05,
      color: const Color.fromARGB(255, 34, 34, 34),
      child: LayoutBuilder(
        builder: (_, BoxConstraints constraints) {

          return Selector<ProcessProvider, int>(
            selector: (_, prov) => prov.systemIsOk,
            builder: (_, isOk, __) {

              return (isOk < 1000)
                ? ChkConn(
                    maxW: constraints.maxWidth,
                  )
                : _pagesProcess(constraints.maxWidth);
            },
          );
        },
      )
    );
  }

  ///
  Widget _pagesProcess(double maxWidth) {

    return FutureBuilder<bool>(
      future: _pprov.iniciarMonitoreo(context.read<TerminalProvider>()),
      initialData: false,
      builder: (_, AsyncSnapshot<bool> snap) {

        if(snap.connectionState == ConnectionState.done) {
          if(snap.data!) {
            _pprov.cleanProcess();
            return _viewerProgresoOfSend(maxWidth);
          }else{
            return _tileTitulo('EN ESPERA DE CAMPAÑAS');
          }
        }

        return _tileTitulo('SISTEMA CENTRAL DE MENSAJERÍA');
      },
    );
  }

  ///
  Widget _viewerProgresoOfSend(double maxWidth) {

    return Selector<ProcessProvider, String>(
      selector: (_, prov) => prov.currentFileReceiver,
      builder: (_, fileReceiver, child) {

        if(fileReceiver.isEmpty){ return child!; }

        if(_stop) {
          return _tileTitulo('STOP POR TI!...');
        }

        return SenderProcess(maxWidth: maxWidth);
      },
      child: _tileTitulo('SISTEMA CENTRAL DE MENSAJERÍA'),
    );
  }

  ///
  Widget _tileTitulo(String titulo) {

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Texto(
        txt: titulo,
        isCenter: true,
      ),
    );
  }

  ///
  Widget _tileForSend() {

    return TileContacts(
      idCamp: _pprov.receiverCurrent!.idCamp,
      target: _pprov.enProceso.target,
      idTarget: _pprov.enProceso.data['id'],
      curc: _pprov.receiverCurrent!.curc,
      nombre: _pprov.receiverCurrent!.nombre,
      title: '-> ${_pprov.receiverCurrent!.receiver.empresa}',
      subTi: _pprov.receiverCurrent!.receiver.celular,
      celular: _pprov.receiverCurrent!.receiver.celular,
      isCurrent: true,
    );  
  }

}