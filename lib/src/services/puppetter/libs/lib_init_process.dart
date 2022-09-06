import 'dart:math' show Random;
import 'package:flutter/material.dart' show ValueChanged;

import 'task_shared.dart';
import '../vars_puppe.dart';
import '../../../providers/process_provider.dart';
import '../../../providers/terminal_provider.dart';
import '../../../repository/to_server.dart';
import '../../../services/puppetter/libs/vars_init_process.dart';

class LibInitProcess {

  final TerminalProvider console;
  final ProcessProvider pprov;
  final ValueChanged<void> incProgress;
  final ValueChanged<String> onFinish;
  LibInitProcess({
    required this.incProgress,
    required this.pprov,
    required this.console,
    required this.onFinish,
  });

  InitProcessT _procMaster = InitProcessT.hasProcess;
  List<String> _msg = [];
  String curcInterno = '';
  String nameInterno = '';
  final String _ae = 'Analizando Error!!';

  ///
  Stream<String> make() async* {

    String res = '';

    res = await _isTest();
    curcInterno = pprov.curcProcess;
    nameInterno = pprov.nombreProcess;

    if(res == 'ok') {
      yield 'TESTER::>${pprov.curcProcess}';
      await _sleep(time: 1000);
    }

    await tituloSecc(console, 'initProcess >> $curcInterno');
    await _sleep(time: 500);

    _procMaster = InitProcessT.hasProcess;
    yield task;
    await _sleep();

    res = await _hasProcess();
    if(res != 'ok') {
      yield _ae;
      yield await _getErr(res, 'hasProcess');
      return;
    }
    addP();

    _procMaster = InitProcessT.buildReg;
    yield task;
    await _sleep();
    res = await _buildReg();
    if(res != 'ok') {
      yield _ae;
      yield await _getErr(res, 'buildReg');
      return;
    }
    addP();

    _procMaster = InitProcessT.getMsg;
    yield task;
    await _sleep();
    await _getMsg();
    if(_msg.isEmpty) {
      yield _ae;
      yield await _getErr(res, 'getMsg');
      return;
    }
    addP();

    _procMaster = InitProcessT.formatMsg;
    yield task;
    await _sleep();
    _formatMsg();
    addP();

    addP();
    console.addOk('Listo! Comencemos...');
    await _sleep();
    yield 'Listo! Comencemos...';
  }

  
  // ------------------ FUNCTIONS ---------------


  ///
  Future<String> _getErr(String err, String paso) async {

    await _sleep(time: 500);
    return await anaErr(
      pprov, console, err, 'initProcess', paso
    );
  }

  ///
  Future<String> _isTest() async {

    String res = '';
    if(pprov.isTest) {

      console.addWar('Probando Sistema con TESTERS');

      if(pprov.lstTestings.isEmpty) {
        final testers = await getLstTester();
        if(testers.isNotEmpty) {
          pprov.lstTestings = List<Map<String, dynamic>>.from(testers['testers']);
        }
      }
    
      int indx = -1;
      if(pprov.lstTestings.length > 1) {
        final rnd = Random();
        do {
          indx = rnd.nextInt(pprov.lstTestings.length);
        } while (pprov.indexLastCurcTester == indx);
      }else{
        indx = 0;
      }
    
      if(indx > -1) {
        pprov.indexLastCurcTester = indx;
        pprov.curcProcess = pprov.lstTestings[indx]['curc'];
        pprov.nombreProcess = pprov.lstTestings[indx]['nombre'];
      }else{
        pprov.curcProcess = chatContacts;
        pprov.nombreProcess = 'Probando con $chatContacts';
      }

      res = 'ok';

    }else{

      if(pprov.lstTestings.isNotEmpty) {
        pprov.lstTestings = [];
      }
      pprov.isTest = false;
      pprov.indexLastCurcTester = -1;
    }

    return res;
  }

  ///
  Future<String> _hasProcess() async {

    console.addTask(task);

    if(pprov.receiverCurrent.idCamp == 0) {
      if(pprov.currentFileReceiver.isEmpty) {
        return errsInitProcess[0];
      }
    }
    return 'ok';
  }

  /// Creamos el registro de envio en la base de datos local
  Future<String> _buildReg() async {

    console.addTask(task);
    if(pprov.idRegDb == 0) {
      await ToServer.buildRegInBD(
        pprov.receiverCurrent.idCamp, pprov.receiverCurrent.idReceiver
      );
      if(!ToServer.result['abort']) {
        int? idReg = int.tryParse('${ToServer.result['body']}');
        if(idReg != null) {
          pprov.idRegDb = idReg;
        }else{
          return errsInitProcess[1];
        }
      }else{
        return errsInitProcess[1];
      }
    }

    return 'ok';
  }

  /// Formateamos las variables generales del mensaje como el 
  /// auto e id de la orden
  Future<void> _getMsg() async {

    console.addTask(task);
    switch (pprov.enProceso.target) {
      case 'orden':
        await _formatMsgOfOrden();
        _msg = List<String>.from(pprov.msgCurrent);
        break;
      default:
    }

  }

  /// Sustituimos solo el auto y el IdOrden el cual es general
  /// para todos los receivers de esta campaña
  Future<void> _formatMsgOfOrden() async {

    final partes = replaceAutoAndIdOrden(
      pprov, List<String>.from(pprov.msgCurrent)
    );
    // Actualizamos el mensaje en el proveedor, ya que estas
    // variables son para todos los receivers.
    pprov.setMsgCurrent(partes);
  }

  /// Le colocamos los datos personales al mensaje
  void _formatMsg() {
    
    console.addTask(task);
    for (var i = 0; i < _msg.length; i++) {

      if(_msg[i].contains('_ids_')){
        final ids = _buildIdsForLink();
        _msg[i] = _msg[i].replaceAll('_ids_', ids);
      }
      if(_msg[i].contains('_nombre_')) {
        _msg[i] = _msg[i].replaceAll('_nombre_', pprov.receiverCurrent.nombre);
      }
    }
    pprov.msgCurrentFormat = _msg;
  }

  ///
  String _buildIdsForLink() {

    return '${pprov.enProceso.src['id']}-' // Id de la orden
    '${pprov.receiverCurrent.idReceiver}-' // Id del Cotizador
    '${pprov.enProceso.remiter.id}-'       // Id del Avo
    '${pprov.idRegDb}';                    // Id del Reg. Msg
  }

  ///
  Future<void> _sleep({int time = 250}) async => await Future.delayed(Duration(milliseconds: time));

  ///
  String get task => initProcessT[_procMaster]!['task']!;

  /// Incrementamos la barra de progreeso
  void addP() => incProgress(null);

}