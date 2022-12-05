import 'package:flutter/material.dart' show ValueChanged;
import 'package:puppeteer/puppeteer.dart' as pupp show
ElementHandle;

import 'task_shared.dart';
import '../providers/browser_provider.dart';
import '../vars_puppe.dart';
import '../../../providers/process_provider.dart';
import '../../../providers/terminal_provider.dart';

///
enum FindCtac {
  html, searchCtac, checkTitulo
}

Map<FindCtac, Map<String, String>> findCtac = {
  FindCtac.html: {
    'chatLstNormal': 'div.zoWT4>span>span.matched-text',
    'chatLstGroup': 'div.zoWT4>span',
    'chatRoomTitulo': '#main>header>div._24-Ff>div._2rlF7>div>span',
  },
  FindCtac.searchCtac: {
    'task': 'Buscando el Contacto en la Lista',
  },
  FindCtac.checkTitulo: {
    'task': 'Corroborando Chat',
  },
};

///
List<String> errsSearch = [
  'ERROR<contac>, No se encontró entre los resultados el CHAT > ',
  'ERROR<retry>, No se esta en el mismo dentro del Room del Chat Solicitado.',
  'ERROR<retry>, No se alcanzó el TÍTULO DEL CHAT para poder corroborar su veracidad.'
];

class LibSeachCtac {

  final ValueChanged<void> incProgress;
  final BrowserProvider wprov;
  final ProcessProvider pprov;
  final TerminalProvider console;
  LibSeachCtac({
    required this.incProgress,
    required this.wprov,
    required this.pprov,
    required this.console
  });

  FindCtac _procMaster = FindCtac.searchCtac;
  String curcInterno = '';
  String nameInterno = '';
  final String _ae = 'Analizando Error!!';

  ///
  Stream<String> make() async* {

    String res = '';

    curcInterno = pprov.curcProcess;
    nameInterno = pprov.nombreProcess;

    tituloSecc(console, 'searchCtac >> $curcInterno');
    await _sleep(time: 350);

    _procMaster = FindCtac.searchCtac;

    yield task;
    res = await _searchCtac();
    if(res != 'ok') {
      yield _ae;
      yield await _getErr(res, 'searchCtac');
      return;
    }
    addP();

    _procMaster = FindCtac.checkTitulo;
    yield task;
    res = await _checkTitulo();
    if(res != 'ok') {
      yield _ae;
      yield await _getErr(res, 'checkTitulo');
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

    return await anaErr(
      pprov, console, err, 'searchCtac', paso
    );
  }

  ///
  Future<String> _searchCtac() async {

    console.addTask(task);
    bool isGrup = false;
    if(curcInterno == chatContacts) { isGrup = true; }
    
    String? select = findCtac[FindCtac.html]!['chatLstNormal'];
    if(isGrup) {
      select = findCtac[FindCtac.html]!['chatLstGroup'];
    }

    List<pupp.ElementHandle> chats = await wprov.pagewa!.$$(select!);
    if(chats.isEmpty) {
      // Buscamos nuevamente esperando 2 segundos
      await Future.delayed(const Duration(seconds: 2));
      chats = await wprov.pagewa!.$$(select);
    }

    if(chats.isEmpty) {
      if(!pprov.curcsNoSend.contains(curcInterno)) {
        pprov.curcsNoSend.add(curcInterno);
      }
      return '${errsSearch[0]}$curcInterno';
    }

    int rota = (chats.length < 5) ? chats.length : 5;

    for (var i = 0; i < rota; i++) {

      String? nombreDelChat = await chats[i].evaluate<String>('node => node.innerText');
      if(nombreDelChat != null) {
        if(nombreDelChat == curcInterno) {
          try {
            await chats[i].click();
            return 'ok';
          } catch (_) {}
        }
      }
    }
    
    if(!pprov.curcsNoSend.contains(curcInterno)) {
      pprov.curcsNoSend.add(curcInterno);
    }
    return '${errsSearch[0]}$curcInterno';
  }

  /// Corroboramos que estamos en el chat correcto
  Future<String> _checkTitulo() async {

    console.addTask(task);

    String? select = findCtac[FindCtac.html]!['chatRoomTitulo'];
    final elem = await wprov.pagewa!.waitForSelector(select!, timeout: esperarPorHtml);
    if(elem != null) {

      String? tituloDelChat = await elem.evaluate<String>('node => node.innerText');

      console.addTask('Chat: $curcInterno | Tit.: $tituloDelChat');
      if(tituloDelChat != null) {
        if(tituloDelChat == curcInterno) {
          return 'ok';
        }else{
          return errsSearch[1];
        }
      }
    }

    return errsSearch[2];
  }

  ///
  Future<void> _sleep({int time = 250}) async => await Future.delayed(Duration(milliseconds: time));

  ///
  String get task => findCtac[_procMaster]!['task']!;

  /// Incrementamos la barra de progreeso
  void addP() => incProgress(null);

}