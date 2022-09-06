import 'package:flutter/material.dart' show ValueChanged;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:puppeteer/puppeteer.dart' as pupp show
ElementHandle, Key;

import 'task_shared.dart';
import 'vars_write_msg.dart';
import '../providers/browser_provider.dart';
import '../vars_puppe.dart';
import '../../../providers/terminal_provider.dart';
import '../../../providers/process_provider.dart';

class LibWriteMsg {

  final ValueChanged<void> incProgress;
  final BrowserProvider wprov;
  final ProcessProvider pprov;
  final TerminalProvider console;

  LibWriteMsg({
    required this.incProgress,
    required this.wprov,
    required this.pprov,
    required this.console
  });

  WriteMsgT _procMaster = WriteMsgT.bskBoxWrite;

  // El elemento html que se esta gestioando.
  pupp.ElementHandle? element;
  String curcInterno = '';
  String nameInterno = '';
  final String _ae = 'Analizando Error!!';
  bool _isBlock = false;

  ///
  Stream<String> make() async* {

    String res = '';

    curcInterno = pprov.curcProcess;
    nameInterno = pprov.nombreProcess;

    await tituloSecc(console, 'writeMsg >> $curcInterno');
    await _sleep(time: 500);
    
    _procMaster = WriteMsgT.bskBoxWrite;

    yield task;
    await _sleep();
    res = await _bskBoxWrite();
    if(res != 'ok') {
      yield _ae;
      yield await _getErr(res, 'bskBoxWrite');
      return;
    }
    addP();

    _procMaster = WriteMsgT.capturCheckBox;
    yield task;
    await _sleep();
    res = await _capturCheckBox();
    if(res != 'ok') {
      yield _ae;
      yield await _getErr(res, 'capturCheckBox');
      return;
    }
    addP();

    _procMaster = WriteMsgT.checkChat;
    yield task;
    await _sleep();
    res = await _checkChat();
    if(res != 'ok') {
      yield _ae;
      yield await _getErr(res, 'checkChat');
      return;
    }
    addP();

    _procMaster = WriteMsgT.writeMsg;
    yield task;
    await _sleep();
    res = await _writeMsg();
    await _release();
    if(res != 'ok') {
      yield _ae;
      yield await _getErr(res, 'writeMsg');
      return;
    }
    addP();

    _procMaster = WriteMsgT.checkMsg;
    yield task;
    await _sleep();
    res = await _checkMsg();
    if(res != 'ok') {
      yield _ae;
      yield await _getErr(res, 'checkMsg');
      return;
    }
    addP();

    _procMaster = WriteMsgT.send;
    yield task;
    await _sleep();
    res = await _sendMsg();
    if(res != 'ok') {
      yield _ae;
      yield await _getErr(res, 'send');
      return;
    }
    addP();

    addP();
    console.addOk('Listo! Siguiente paso...');
    await _sleep();
    yield 'Listo! Siguiente paso...';
  }


  // ------------------ FUNCTIONS ---------------


  ///
  Future<String> _getErr(String err, String paso) async {

    await _sleep(time: 500);
    return await anaErr(
      pprov, console, err, 'writeMsg', paso
    );
  }

  ///
  Future<String> _bskBoxWrite() async {

    console.addTask(task);
    try {
      element = await wprov.pagewa!.waitForSelector(
        writeMsgt[WriteMsgT.html]!['caja']!, timeout: esperarPorHtml
      );
    } catch (e) {
      return errsWrite[0];
    }

    return 'ok';
  }

  /// Checamos que efectivamente este el foco en la caja de texto
  Future<String> _capturCheckBox() async {

    console.addTask(task);
    try {
      await element!.click();
      final btnSend = await wprov.pagewa!.waitForSelector(
        writeMsgt[WriteMsgT.html]!['check']!, timeout: esperarPorHtml
      );
      if(btnSend != null) { return 'ok'; }
    } catch (_) { }
    return errsWrite[0];
  }

  ///
  Future<String> _checkChat() async {

    console.addTask(task);

    String? select = writeMsgt[WriteMsgT.html]!['chatRoomTitulo'];
    final elem = await wprov.pagewa!.waitForSelector(select!, timeout: esperarPorHtml);
    if(elem != null) {

      String? tituloDelChat = await elem.evaluate<String>('node => node.innerText');
      console.addTask('Checking: $curcInterno > $tituloDelChat');

      if(tituloDelChat != null) {
        if(tituloDelChat == curcInterno) {
          return 'ok';
        }
      }
    }

    return errsWrite[0];
  }

  ///
  Future<String> _writeMsg() async {

    if(!_isBlock) {
      await _block();
    }else{
      return '';
    }

    final res = await _borrarContenido();
    if(res != 'ok') { return res; }

    console.addTask(task);

    for (var i = 0; i < pprov.msgCurrentFormat.length; i++) {

      if(pprov.msgCurrentFormat[i].contains('_sp_')) {
        await wprov.pagewa!.keyboard.down(pupp.Key.control);
        await wprov.pagewa!.keyboard.press(pupp.Key.enter);
        await wprov.pagewa!.keyboard.up(pupp.Key.control);
        await _sleep(time: 100);
      }else{
        try {
          await Clipboard.setData(ClipboardData(text: pprov.msgCurrentFormat[i]));
          await pegarDash(element: element!, page: wprov.pagewa!);
          await Clipboard.setData(const ClipboardData(text: ''));
        } catch (e) {
          return errsWrite[2];
        }
      }
    }

    return 'ok';
  }

  ///
  Future<String> _typea() async {

    if(!_isBlock) {
      await _block();
    }else{
      return '';
    }

    final res = await _borrarContenido();
    if(res != 'ok') { return res; }

    console.addTask('Typeando: $curcInterno');
    await _sleep();
    for (var i = 0; i < pprov.msgCurrentFormat.length; i++) {
      if(pprov.msgCurrentFormat[i].contains('_sp_')) {
        await wprov.pagewa!.keyboard.down(pupp.Key.control);
        await wprov.pagewa!.keyboard.press(pupp.Key.enter);
        await wprov.pagewa!.keyboard.up(pupp.Key.control);
        await _sleep(time: 100);
      }else{
        
        await element!.type(
          pprov.msgCurrentFormat[i], delay: const Duration(milliseconds: 90)
        );
      }
    }

    return await _checkMsg(from: 'typea');
  }

  ///
  Future<String> _checkMsg({String from = 'write'}) async {

    console.addTask(task);

    var contenido = await getContenido(element: element!);
    bool isOkTxtRes = true;
    if(contenido.isNotEmpty) {
      final partes = contenido.split(' ');
      List<String> msg = [];
      for (var i = 0; i < partes.length; i++) {
        var parte = partes[i].trim().toLowerCase();
        if(parte.isNotEmpty) {
          msg.add(parte);
        }
      }

      contenido = msg.join(' ');
      final comparaCon = await _buildCom();

      for (var i = 0; i < comparaCon.length; i++) {
        if(!contenido.contains(comparaCon[i])) {
          isOkTxtRes = false;
          break;
        }
      }
    }
    if(isOkTxtRes) {
      return 'ok';
    }else{
      if(from == 'write') {
        await _release();
        return await _typea();
      }
      return errsWrite[2];
    }
  }

  ///
  Future<String> _sendMsg() async {

    if(!pprov.noSendMsg) {

      console.addOk(task.toUpperCase());
      
      String? select = writeMsgt[WriteMsgT.html]!['send'];
      if(select != null) {

        pupp.ElementHandle? btnSend = await wprov.pagewa!.waitForSelector(select);
        try {
          btnSend = await wprov.pagewa!.$OrNull(select);
        } catch (_) {}

        if(btnSend != null) {
          await btnSend.click();
          await _sleep(time: 500);
          return 'ok';
        }
      }

      return errsWrite[3];
    }else{
      console.addWar('---->>>> SIN ENVIO <<<<----');
      await _sleep();
    }
    
    return 'ok';
  }

  ///
  Future<String> _borrarContenido() async {

    console.addTask('Borrando Contenido');

    await borrarMensaje(element: element!, page: wprov.pagewa!);
    final res = await hasContenido(element: element!);
    if(res) {
      await borrarMensaje(element: element!, page: wprov.pagewa!);
      final res = await hasContenido(element: element!);
      if(res) {
        return errsWrite[1];
      }
    }
    return 'ok';
  }

  /// Tomamos una lista de palabras las cuales son utilizadas para
  /// comparar el mensaje escrito final, y ver si este es integro.
  Future<List<String>> _buildCom() async {

    console.addTask('Creando MSG. Comparativo');
    if(curcInterno == chatContacts) {
      return ['contacto', 'inexistente'];
    }
    String nombre = nameInterno;
    if(pprov.isTest) {
      nombre = pprov.receiverCurrent.nombre;
    }
    return buildMsgCom(pprov, nombre: nombre);
  }

  ///
  Future<void> _sleep({int time = 250}) async => await Future.delayed(Duration(milliseconds: time));
  
  ///
  Future<void> _block() async { _isBlock = true; }
  
  ///
  Future<void> _release() async { _isBlock = false; }

  ///
  String get task => writeMsgt[_procMaster]!['task']!;

  /// Incrementamos la barra de progreeso
  void addP() => incProgress(null);
}