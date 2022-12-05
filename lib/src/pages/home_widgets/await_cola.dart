import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'cola_barr_div.dart';
import '../../entity/proceso_entity.dart';
import '../../entity/scm_entity.dart';
import '../../providers/process_provider.dart';
import '../../services/get_content_files.dart';
import '../../vars/scroll_config.dart';
import '../../widgets/indicador_cola.dart';
import '../../widgets/tile_await_camp.dart';

class AwaitCola extends StatefulWidget {

  const AwaitCola({Key? key}) : super(key: key);

  @override
  State<AwaitCola> createState() => _AwaitColaState();
}

class _AwaitColaState extends State<AwaitCola> {

  final ScrollController _ctrScrollAwait = ScrollController();
  final _curcsNoSend = ValueNotifier<int>(0);
  final _repintLst = ValueNotifier<int>(-1);

  late ProcessProvider _proc;
  bool _isInit = false;
  List<ScmEntity> _lstAwait = [];
  int _cantLast = 0;
  
  @override
  void dispose() {
    _ctrScrollAwait.dispose();
    _curcsNoSend.dispose();
    _repintLst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _proc = context.read<ProcessProvider>();
      _proc.setTituloColaBarr = 'Cargando...';
    }
    
    return Selector<ProcessProvider, ScmEntity?>(
      selector: (_, prov) => prov.receiverCurrent, 
      builder: (_, recCur, child) {

        if(_proc.currentFileProcess.isEmpty) { return child!; }

        _hidratarReceptores();
        return ValueListenableBuilder(
          valueListenable: _repintLst,
          builder: (_, repint, __) {
            if(_lstAwait.isEmpty){ return child!; }
            return _body();
          },
        );
        // return FutureBuilder(
        //   future: _hidratarReceptores(),
        //   builder: (_, AsyncSnapshot snap) {
            
        //     return (_lstAwait.isNotEmpty) ? _body() : _sinData();
        //   }
        // );
      },
      child: _sinData(),
    );
  }

  ///
  Widget _body() {

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 3, horizontal: 10
      ),
      width: appWindow.size.width,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(5)
      ),
      child: Column(
        children: [
          _indicador(),
          Expanded(
            child: _buildLst(),
          ),
          const ColaBarrDiv()
        ],
      )
    );
  }

  ///
  Widget _sinData() => const SizedBox();

  ///
  Widget _indicador() {

    return Selector<ProcessProvider, ProcesoEntity>(
      selector: (_, provi) => provi.enProceso,
      builder: (_, trigger, __) {
        
        String onOff = 'on';
        if(trigger.noSend.length != _cantLast) {
          onOff = 'off';
        }

        return IndicadorCola(
          onOff: onOff,
          colorOn: const Color.fromARGB(255, 54, 74, 252),
          colorOff: Colors.white.withOpacity(0.05)
        );
      },
    );
  }

  ///
  Widget _buildLst() {

    const child = SizedBox();

    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: Scrollbar(
        controller: _ctrScrollAwait,
        thumbVisibility: true,
        radius: const Radius.circular(3),
        child: ListView.builder(
          padding: const EdgeInsets.only(right: 15, left: 5, top: 8),
          shrinkWrap: true,
          controller: _ctrScrollAwait,
          itemCount: _lstAwait.length,
          itemBuilder: (_, int i) {

            if(_proc.receiverCurrent != null) {
              if(_proc.receiverCurrent!.idReceiver == _lstAwait[i].idReceiver) {
                return child;
              }
            }
            
            return TileAwaitCamp(
              index: i+1,
              receiver: _lstAwait[i],
              childCheck: _childCheck(_lstAwait[i]),
            );
          }
        )
      )
    );
  }

  ///
  Widget _childCheck(ScmEntity receiver) {

    return ValueListenableBuilder<int>(
      valueListenable: _curcsNoSend,
      builder: (_, val, __) {

        return Checkbox(
          checkColor: Colors.white.withOpacity(0.5),
          visualDensity: VisualDensity.compact,
          side: const BorderSide(color: Colors.grey),
          fillColor: MaterialStateProperty.all(
            Colors.white.withOpacity(0.1)
          ),
          key: Key('${receiver.idReceiver}'),
          value: !_proc.curcsNoSend.contains(
            receiver.curc
          ),
          onChanged: (val) {

            val = (val == null) ? false : val;
            if(val) {
              // Esta seleccionado el check, se envia
              _proc.curcsNoSend.remove(receiver.curc);
              _curcsNoSend.value = _proc.curcsNoSend.length;
            }else{
              if(!_proc.curcsNoSend.contains(receiver.curc)) {
                _proc.curcsNoSend.add(receiver.curc);
              }
              _curcsNoSend.value = _proc.curcsNoSend.length;
            }
          }
        );

      }
    );
  }


  // ----------------CONTROLADOR--------------------

  /// Recuperamos los mensajes de la campaña actual
  Future<void> _hidratarReceptores() async {

    List<ScmEntity> newLstAwait = [];
    final msgs = _proc.enProceso.noSend;
    if(msgs.isNotEmpty) {

      final path = _proc.enProceso.pathReceivers;

      for (var i = 0; i < msgs.length; i++) {
        
        if(msgs[i] != _proc.currentFileReceiver) {
          final recep = await GetContentFile.getMsgToMap('$path${msgs[i]}');
          newLstAwait.add(ScmEntity()..fromProvider(recep));
        }
      }
      
      _cantLast = msgs.length;
      Future.microtask((){
        _lstAwait = List<ScmEntity>.from(newLstAwait);
        _proc.tituloColaBarr = '${_proc.enProceso.noSend.length} Receptore(s).';
        _repintLst.value = _proc.enProceso.noSend.length;
        newLstAwait = [];
      });
    }else{
      _lstAwait = [];
      _repintLst.value = -1;
    }
  }

}