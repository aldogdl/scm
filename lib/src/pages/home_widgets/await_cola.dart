import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import 'cola_barr_div.dart';
import '../../entity/contacts_entity.dart';
import '../../entity/scm_entity.dart';
import '../../entity/scm_file.dart';
import '../../providers/process_provider.dart';
import '../../services/get_content_files.dart';
import '../../vars/scroll_config.dart';
import '../../widgets/my_tool_tip.dart';
import '../../widgets/sin_data.dart';
import '../../widgets/texto.dart';

class AwaitCola extends StatefulWidget {

  const AwaitCola({Key? key}) : super(key: key);

  @override
  State<AwaitCola> createState() => _AwaitColaState();
}

class _AwaitColaState extends State<AwaitCola> {

  final ScrollController _ctrScrollAwait = ScrollController();
  final ScrollController _ctrScrollTray = ScrollController();
  
  final ScmFile _fileS = ScmFile();
  late ProcessProvider _proc;

  /// El id del receiver que esta en proceso actualmente
  int _idCurrenProc = -1;
  bool _isInit = false;

  @override
  void dispose() {
    _ctrScrollAwait.dispose();
    _ctrScrollTray.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _proc = context.read<ProcessProvider>();
      _proc.receiverCurrentClean = ScmEntity();
      _proc.cleanReceiversCola();
      _idCurrenProc = -1;
      _proc.setTituloColaBarr = 'Cargando...';
    }
    
    return Container(
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsets.symmetric(
        vertical: 3, horizontal: 10
      ),
      constraints: BoxConstraints.expand(
        width: appWindow.size.width,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(5)
      ),
      child: Column(
        children: [
          Expanded(
            child: Selector<ProcessProvider, List<ScmEntity>>(
              selector: (_, provi) => provi.receiversCola,
              builder: (_, lst, child) {
                
                if(lst.isEmpty) { return child!; }

                return ScrollConfiguration(
                  behavior: MyCustomScrollBehavior(),
                  child: Scrollbar(
                    controller: _ctrScrollAwait,
                    isAlwaysShown: true,
                    radius: const Radius.circular(3),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(right: 15, left: 10),
                      shrinkWrap: true,
                      controller: _ctrScrollAwait,
                      itemCount: lst.length,
                      itemBuilder: (_, int i) {

                        return (lst[i].receiver.id == 0)
                        ? _streamLoadEnAwait(i)
                        : _tileReceiver(lst[i]);
                      }
                    )
                  )
                );
              },
              child: const SinData(
                msg: '', main: 'nada en Cola', isDark: false,
                withTit: false
              ),
            ),
          ),
          const ColaBarrDiv()
        ],
      ),
    );
  }

  /// El diseño para el receptor dentro de la cola
  Widget _tileReceiver(ScmEntity receiver) {

    return Column(
      children: [
        Row(
          children: [
            if(receiver.receiver.id == _idCurrenProc)
              const SizedBox(
                width: 15, height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                )
              )
            else
              SizedBox(
                width: 20, height: 15,
                child: Checkbox(
                  checkColor: Colors.white.withOpacity(0.5),
                  visualDensity: VisualDensity.compact,
                  side: const BorderSide(color: Colors.grey),
                  fillColor: MaterialStateProperty.all(
                    Colors.white.withOpacity(0.1)
                  ),
                  key: Key('${receiver.idReceiver}'),
                  value: !receiver.forceNotSend,
                  onChanged: (val) {
                    val = (val == null) ? false : val;
                    val = !val;
                    setState(() {
                      receiver.forceNotSend = val ?? false;
                    });
                  }
                ),
              ),
            const SizedBox(width: 8),
            MyToolTip(
              msg: '-> ${receiver.receiver.nombre}',
              child: Texto(
                txt: receiver.receiver.empresa,
                txtC: const Color.fromARGB(255, 149, 151, 243)
              )
            ),
            if(receiver.receiver.id == _proc.idCurrenProcesando)
              ...[
                const Spacer(),
                Texto(
                  txt: (context.watch<ProcessProvider>().isPause)
                    ? 'En Pausa' : 'Enviando...', sz: 12,
                  txtC: const Color.fromARGB(255, 145, 255, 0)
                )
              ]
          ],
        ),
        Divider(color: Colors.grey.withOpacity(0.5),)
      ],
    );
  }

  ///
  Widget _streamLoadEnAwait(int index) {

    return StreamBuilder<Map<String, dynamic>>(
      stream: _getDataAwait(index),
      initialData: const <String, dynamic>{'index':0, 'msg':'Buscando'},
      builder: (_, snap) {

        if(snap.data!['msg'] != 'ok') {
          return _tileReceiverLoad(index, snap.data!['msg']);
        }else{
          _checarArranque();
          return _tileReceiver(_proc.receiversCola[index]);
        }
      },
    );
  }

  ///
  Widget _tileReceiverLoad(int index, String msg) {

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 25, height: 18,
              child: Checkbox(
                checkColor: Colors.black.withOpacity(0.7),
                visualDensity: VisualDensity.compact,
                side: const BorderSide(color: Colors.grey),
                fillColor: MaterialStateProperty.all(Colors.white),
                value: true,
                onChanged: (val) {}
              ),
            ),
            _emptyAwait(msg, largo: 0.65, alto: 18)
          ],
        ),
        Divider(color: Colors.grey.withOpacity(0.5))
      ],
    );
  }

  /// El holder contenedor
  Widget _emptyAwait(String msg, {
    required double largo,
    double alto = 14,
  }) {

    double op = (alto == 18) ? 0.5 : 0.3;

    return Shimmer(
      color: Colors.grey.withOpacity(op),
      direction: const ShimmerDirection.fromLTRB(),
      child: Container(
        width: appWindow.size.width * largo,
        height: alto,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: Colors.grey.withOpacity(op)
        ),
        child: Center(
          child: Texto(
            txt: msg, sz: 10, txtC: const Color.fromARGB(255, 206, 206, 206)
          )
        ),
      ),
    );
  }


  // ----------------CONTROLADOR--------------------

  /// Aqui es donde el stream hace la recuperacion de receptores
  Stream<Map<String, dynamic>> _getDataAwait(int i) async* {

    yield {'index': i, 'msg': 'Busco ID ${_proc.receiversCola[i].idReceiver}'};
    await Future.delayed(const Duration(milliseconds: 500));
    final pathCtc = await GetContentFile.getPathOfContacto(_proc.receiversCola[i].idReceiver);
    
    final receiver = ContactEntity()..fromJson(
      await GetContentFile.getMsgToMap(pathCtc)
    );

    yield {'index': i, 'msg': 'Busco Archivo'};
    await Future.delayed(const Duration(milliseconds: 500));
    
    var fileContent = await GetContentFile.getContentByFileAndFolder(
      fileName: _proc.receiversCola[i].nFile, folder: FoldStt.wait
    );

    if(fileContent.isEmpty) {
      // Probamos con el sufijo de -main-
      String fileN = _proc.receiversCola[i].nFile;
      fileN = fileN.replaceFirst(_fileS.suf, _fileS.sufM);
      fileContent = await GetContentFile.getContentByFileAndFolder(
        fileName: fileN, folder: FoldStt.wait
      );
      if(fileContent.isNotEmpty) {
        _proc.receiversCola[i].nFile = fileN;
      }
    }
    
    if(receiver.id != 0 && fileContent.isNotEmpty) {
      _proc.receiversCola[i].receiver.fromJson(receiver.toReceiver());
      yield {'index': i, 'msg': 'ok'};
    }else{
      yield {'index': i, 'msg': 'No Archivo'};
    }
  }

  ///
  void _checarArranque() {

    if(_idCurrenProc == -1) {

      final arranque = _proc.receiversCola.firstWhere(
        (element) => element.nFile.contains(_fileS.sufM),
        orElse: () => ScmEntity()
      );

      if(arranque.receiver.id != 0) {
        _idCurrenProc = arranque.idReceiver;
        Future.delayed(const Duration(milliseconds: 200), (){
          _proc.receiverCurrent = arranque;
        });
      }
    }
  }

}