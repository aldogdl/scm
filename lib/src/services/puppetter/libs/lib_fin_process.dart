import 'dart:convert';

import 'package:flutter/material.dart' show ValueChanged;
import 'package:scm/src/entity/proceso_entity.dart';

import '../../get_content_files.dart';
import '../../push_send.dart';
import '../../scm/scm_paths.dart';
import '../../../providers/terminal_provider.dart';
import '../../../providers/process_provider.dart';
import '../../../repository/to_server.dart';
import '../../../services/puppetter/libs/task_shared.dart';
import '../../../services/puppetter/libs/vars_fin_process.dart';

class LibFinProcess {

  final bool forceDrash;
  final ProcessProvider pprov;
  final TerminalProvider console;
  final ValueChanged<void> incProgress;
  final ValueChanged<String> onFinish;
  LibFinProcess({
    required this.forceDrash,
    required this.incProgress,
    required this.pprov,
    required this.console,
    required this.onFinish,
  });

  FinProcessT _procMaster = FinProcessT.stopCronFile;
  String stt = 'i';
  String curcInterno = '';
  String nameInterno = '';
  FoldStt fold = FoldStt.sended;
    
  ///
  Stream<String> make() async* {

    String res = '';
    
    curcInterno = pprov.curcProcess;
    nameInterno = pprov.nombreProcess;

    tituloSecc(console, 'finProcess >> $curcInterno');
    await _sleep(time: 1000);

    _procMaster = FinProcessT.stopCronFile;
    yield task;
    await _sleep();
    await _stopCronFile();
    console.addWar('Monitoreo Pausado');
    addP();

    // No hay errores no hay nada que actualizar
    _procMaster = FinProcessT.updateSttBD;
    yield task;
    addP();

    _procMaster = FinProcessT.saveDataLocal;
    yield task;
    await _sleep();
    res = await _saveDataLocal();
    if(res != 'ok') { yield res; return; }
    addP();

    _procMaster = FinProcessT.sendPush;
    yield task;
    await _sleep();
    await _sendPush();
    console.addTask('^^^^ ENVIANDO NOTIFICACIÓN A: >>>');
    await _sleep();
    console.addOk('^^^^ $nameInterno');
    addP();
    
    _procMaster = FinProcessT.moveFile;
    yield task;
    await _sleep();
    res = await _moveFile();
    addP();

    addP();
    console.addOk('Listo! Siguiente Remitente');
    yield '√ Listo! Siguiente Remitente >>';
  }

  /// Este metodo es una duplicidad del metodo anterior solo que este
  /// es llamado desde el procesamiento de errores
  Future<String> makeWithErr() async {

    String res = '';

    curcInterno = pprov.curcProcess;
    nameInterno = pprov.nombreProcess;

    Future.microtask(() {
      tituloSecc(console, 'finProcess Console >> $curcInterno');
    });
    await _sleep(time: 500);

    if(forceDrash) {
      stt = 'p';
      fold = FoldStt.drash;
    }else{
      if(pprov.receiverCurrent.errores.isNotEmpty) {
        stt = 'p';
        fold = FoldStt.drash;
      }
    }

    _procMaster = FinProcessT.stopCronFile;
    await _stopCronFile();

    _procMaster = FinProcessT.updateSttBD;
    res = await _updateSttBD();
    if(res != 'ok') {  return res; }

    _procMaster = FinProcessT.saveDataLocal;
    res = await _saveDataLocal();
    if(res != 'ok') {  return res;  }

    _procMaster = FinProcessT.sendPush;
    await _sendPush();

    _procMaster = FinProcessT.moveFile;
    res = await _moveFile();

    console.addOk('Listo! Siguiente Receptor >>');
    await _sleep(time: 2000);
    return '√ Listo! Siguiente Remitente >>';
  }


  // ------------------ FUNCTIONS ---------------


  ///
  Future<void> _stopCronFile() async {
    console.addWar(task);
    await pprov.cron.close();
    Future.microtask(() => pprov.isStopCronFles = true );
  }

  ///
  Future<String> _updateSttBD() async {

    console.addWar(task);
    await ToServer.updateRegInBD(pprov.idRegDb, stt);
    return 'ok';
  }

  ///
  Future<String> _saveDataLocal() async {

    console.addWar(task);
    final file = pprov.currentFileReceiver;
    var receiver = pprov.receiverCurrent.toJson();
    if(stt == 'p') {
      if(receiver.containsKey('history')) {
        receiver['history'] = json.encode(console.taskTerminal);
      }else{
        receiver.putIfAbsent('history', () => json.encode(console.taskTerminal));
      }
    }

    await GetContentFile.saveData(file, FoldStt.wait, receiver);
    ProcesoEntity copy = pprov.enProceso;

    copy.noSend.remove(file);
    if(stt == 'p') {
      copy.drash.add(file);
    }else{
      copy.sended.add(file);
    }
    await GetContentFile.saveData(
      ScmPaths.extractNameFile(pprov.currentFileProcess),
      FoldStt.tray, copy.toJson(),
    );

    pprov.enProceso = ProcesoEntity();
    Future.microtask(() => pprov.enProceso = copy);

    console.addOk('Archivos Locales Actualizados');
    return 'ok';
  }

  ///
  Future<void> _sendPush() async {

    await PushSend.sended(pprov.enProceso.toJson());
    console.addWar('^^^^ NOTIFICADANDO A LOS SCP ^^^^');
    await _sleep();
  }

  ///
  Future<String> _moveFile() async {

    console.addWar(task);
    await GetContentFile.changeDeFolder(
      filename: pprov.currentFileReceiver, 
      from: FoldStt.wait, to: fold
    );
    return 'ok';
  }
  
  ///
  Future<void> _sleep({int time = 250}) async => await Future.delayed(Duration(milliseconds: time));

  ///
  String get task => finProcessT[_procMaster]!['task']!;

  /// Incrementamos la barra de progreeso
  void addP() => incProgress(null);

}