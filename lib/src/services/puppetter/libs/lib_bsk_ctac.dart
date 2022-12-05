import 'package:flutter/material.dart' show ValueChanged;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:puppeteer/puppeteer.dart' as pupp show
ElementHandle;

import 'task_shared.dart';
import '../providers/browser_provider.dart';
import '../vars_puppe.dart';
import '../../../providers/process_provider.dart';
import '../../../providers/terminal_provider.dart';

///
enum TaskContac {
  html, bskContac, capturBox, capturCheckBox, writeCtac, checkCtac
}
Map<TaskContac, Map<String, String>> taskContact = {
  TaskContac.html: {
    'caja': '#side>div.uwk68>div>div>div._16C8p>div>div._13NKt.copyable-text.selectable-text',
    'back': '#side>div.uwk68>div>div>button._28-cz',
    'xDel': '#side>div.uwk68>div>div>span>button._3GYfN'
  },
  TaskContac.bskContac: {
    'task': 'Detectando Caja de Búsqueda',
  },
  TaskContac.capturBox: {
    'task': 'Capturando Caja de Búsqueda',
  },
  TaskContac.capturCheckBox: {
    'task': 'Asegurando captura de Caja',
  },
  TaskContac.writeCtac: {
    'task': 'Escribiendo nombre del Contacto',
  },
  TaskContac.checkCtac: {
    'task': 'Revisando nombre del Contacto',
  },
};

///
List<String> errsContact = [
  'ERROR,<stop> Sin Conexión a Internet',
  'ERROR,<retry> No se alcanzó la caja de Búsqueda de Contactos.',
  'ERROR,<retry> No se escribió el CURC en la caja de Busqueda de contacto',
  'ERROR,<retry> El sistema sobre paso el tiempo de espera al querer buscar el contacto.',
  'ERROR,<retry> No se recibió el CURC. variable bacía'
];

class LibBskCtac {

  final ValueChanged<void> incProgress;
  final BrowserProvider wprov;
  final ProcessProvider pprov;
  final TerminalProvider console;
  LibBskCtac({
    required this.incProgress,
    required this.wprov,
    required this.pprov,
    required this.console
  });

  TaskContac _procMaster = TaskContac.bskContac;

  // El elemento html que se esta gestioando.
  pupp.ElementHandle? element;

  bool _isBlock = false;
  String curcInterno = '';
  String nameInterno = '';
  final String _ae = 'Analizando Error!!';

  ///
  Stream<String> make() async* {

    String res = '';

    curcInterno = pprov.curcProcess;
    nameInterno = pprov.nombreProcess;
    await tituloSecc(console, 'bskContac >> $curcInterno');
    await _sleep(time: 350);

    _procMaster = TaskContac.bskContac;
    yield task;
    res = await _bskContac();
    if(res != 'ok') {
      yield _ae;
      yield await _getErr(res, 'bskContac');
      return;
    }
    addP();

    _procMaster = TaskContac.capturBox;
    yield task;
    res = await _capturBox();
    if(res != 'ok') {
      yield _ae;
      yield await _getErr(res, 'capturBox');
      return;
    }
    addP();

    _procMaster = TaskContac.capturCheckBox;
    yield task;
    res = await _capturCheckBox();
    if(res != 'ok') {
      yield _ae;
      yield await _getErr(res, 'capturCheckBox');
      return;
    }
    addP();

    _procMaster = TaskContac.writeCtac;
    yield task;
    res = await _writeCtac();
    if(res != 'ok') {
      yield _ae;
      yield await _getErr(res, 'writeCtac');
      return;
    }
    addP();

    _procMaster = TaskContac.checkCtac;
    yield task;
    await _release();
    res = await _checkCtac();
    if(res != 'ok') {
      if(res == 'typea') {
        res = await _typea();
      }
      if(res != 'ok'){
        yield _ae;
        yield await _getErr(res, 'checkCtac');
        return;
      }
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
      pprov, console, err, 'bskContac', paso
    );
  }

  /// Buscamos la existencia de la caja de busqueda
  Future<String> _bskContac() async {

    if(curcInterno.isEmpty || curcInterno == '0') {
      return errsContact[4];
    }
    if(wprov.pagewa == null) {
      await _reconectarSistema();
    }
    try {
      element = await wprov.pagewa!.waitForSelector(
        taskContact[TaskContac.html]!['caja']!, timeout: esperarPorHtml
      );
      console.addTask(task);
    } catch (e) {
      return errsContact[1];
    }

    return 'ok';
  }

  ///
  Future<String> _capturBox() async {

    try {
      await element!.click();
      console.addTask(task);
    } catch (e) {
      return errsContact[1];
    }
    return 'ok';
  }

  /// Checamos que efectivamente este el foco en la caja de texto
  Future<String> _capturCheckBox() async {

    try {
      final btnBack = await wprov.pagewa!.waitForSelector(
        taskContact[TaskContac.html]!['back']!, timeout: esperarPorHtml
      );
      console.addTask(task);
      if(btnBack != null) { return 'ok'; }
    } catch (_) { }

    return errsContact[1];
  }
  
  ///
  Future<String> _writeCtac() async {

    if(!_isBlock) {
      await _block();
    }else{
      return '';
    }

    await _borrarContenido();

    console.addTask(task);
    
    try {
      await Clipboard.setData(ClipboardData(text: curcInterno));
      await _sleep();
      await pegarDash(element: element!, page: wprov.pagewa!);
      await _sleep();
      await Clipboard.setData(const ClipboardData(text: ''));
      await _sleep();
    } catch (e) {
      return 'ERROR<retry> ${e.toString()}';
    }

    return 'ok';
  }

  ///
  Future<String> _checkCtac({String from = 'make'}) async {

    console.addTask(task);
    await _sleep(time: 350);

    var res = await getContenido(element: element!);

    res = res.trim();
    console.addTask('Comparando: $curcInterno > $res');
    if(res == curcInterno) {
      return 'ok';
    }else{

      if(from == 'make') {
        if(res.isEmpty) {
          return 'typea';
        }
      }

      return errsContact[2];
    }
  }

  ///
  Future<String> _typea() async {

    if(!_isBlock) {
      await _block();
    }else{
      return '';
    }
    console.addTask('Typeando: $curcInterno');
    await _sleep();
    await element!.type(curcInterno, delay: const Duration(milliseconds: 90));
    return await _checkCtac(from: 'typea');
  }

  ///
  Future<void> _borrarContenido() async {

    console.addTask('Borrando Contenido');
    await borrarContenidoContac(element: element!, page: wprov.pagewa!);
    final res = await hasContenido(element: element!);
    
    // Borrar tambien lo del portapapeles
    await Clipboard.setData(const ClipboardData(text: ''));
    await _sleep();

    if(res) {
      bool pressFlecha = false;

      try {
        var btnDel = await wprov.pagewa!.waitForSelector(
          taskContact[TaskContac.html]!['xDel']!, timeout: esperarPorHtml
        );
        if(btnDel != null) {
          await btnDel.click();
        }else{
          pressFlecha = true;
        }
      } catch (e) {
        pressFlecha = true;
      }

      if(pressFlecha) {
        var btnDel = await wprov.pagewa!.waitForSelector(
          taskContact[TaskContac.html]!['back']!, timeout: esperarPorHtml
        );
        if(btnDel != null) {
          await btnDel.click();
        }
      }
    }
  }

  ///
  Future<void> _reconectarSistema() async {

    // TODO Ver como regresar al Widget de inicio para reconectar
  }

  ///
  Future<void> _block() async { _isBlock = true; }
  
  ///
  Future<void> _release() async { _isBlock = false; }

  ///
  Future<void> _sleep({int time = 250}) async => await Future.delayed(Duration(milliseconds: time));

  ///
  String get task => taskContact[_procMaster]!['task']!;

  /// Incrementamos la barra de progreeso
  void addP() => incProgress(null);

}