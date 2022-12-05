import 'dart:async';

import 'task_shared.dart';
import '../browser_conn.dart';
import '../providers/browser_provider.dart';
import '../repository/puppe_repository.dart';
import '../vars_puppe.dart';
import '../../../providers/process_provider.dart';
import '../../../providers/terminal_provider.dart';

class LibCheckConn {

  final TerminalProvider console;
  final BrowserProvider connProv;
  final ProcessProvider procProv;
  LibCheckConn({
    required this.connProv,
    required this.procProv,
    required this.console
  });

  final pupEm = PuppeRepository();

  int indexMsg = 0;
  Timer? timer;
  List<Map<String, dynamic>> metadata = [];
  String prefixMsg = '';

  ///
  Stream<String> make() async* {

    metadata = [];
    console.clean();
    await tituloSecc(console, '::SERVIDOR DE MENSAJERÍA SCM::');
    if(connProv.isChecking) { yield ''; }
    connProv.isChecking = true;
    yield '::BIENVENIDO AL SCM::';
    await _sleep(time: 1000);

    bool hasErrBrowser = false;
    bool hasErrWhats = false;
    connProv.isOkCp = true;
    console.addTask('Recuperando Metadatos Browser');
    metadata = await pupEm.getListTargets();

    if(metadata.isEmpty) {
      bool isOk = BrowserConn.hasWrowserDownloader();
      if(!isOk) {
        console.addDiv();
        console.addTask('Descargando Browser...');
        await _sleep();
      }else{
        console.addDiv();
        console.addTask('Lanzando Navegador...');
        await _sleep();
      }

      isOk = await _lanzarBrowser(!isOk);
      if(!isOk) {
        hasErrBrowser = true;
        metadata = [];
      }

    }else{

      console.addTask('Conectando con el Navegador');
      connProv.browser = await BrowserConn.tryConnect();
      if(connProv.browser != null) {
        console.addOk('Browser Conectado');
      }else{
        hasErrBrowser = true;
        metadata = [];
      }
    }

    if(timer != null) { timer!.cancel(); }
    if(metadata.isNotEmpty) {
      await _sleep();
      console.addTask('Buscando Mensajería');
      bool existWhast = await _hasWhatsOpen();
      if(!existWhast) {
        console.addDiv();
        await _sleep();
        console.addWar('Lanzando WhatsApp');
        bool isOk = await _lanzarWhats();
        if(!isOk) {
          hasErrWhats = true;
          metadata = [];
        }
      }
    }

    if(timer != null) { timer!.cancel(); }
    if(hasErrBrowser) {
      console.addErr('Sin conexión con el Browser');
      yield '[X] ERROR DE CONEXIÓN';
      connProv.isOkCp = false;
    }
    
    if(hasErrWhats) {
      console.addErr('Sin conexión a WhatsApp');
      yield '[X] ERROR DE CONEXIÓN';
      connProv.isOkCp = false;
      metadata = [];
      console.addOk('primero Inicia WhatsApp y...');
      console.addAcc('[W] Presiona Aquí');
    }

    // Si todo resulto bien, checamos si Whats esta con
    // la sesion abierta por medio de buscar la caja de Contactos
    bool hayErr = false;
    if(connProv.isOkCp) {

      console.addTask('Conexión EXITOSA...');
      pupEm.getFrontTarget(connProv.targetId);
      console.addOk('Revisando Sesión de WhatsApp');
      await _sleep();
      console.addWar('Espera unos segundo por favor');
      String check = await BrowserConn.checarConectividad(
        connProv.browser, connProv.pagewa, connProv.titleCurrent
      );

      if(check.isEmpty) {
        console.addOk('Conexión Sistema Exitoso');
        connProv.isOkCp = true;
        yield 'Inicializando Monitoreo';
        Future.microtask(() => procProv.systemIsOk = 1000 );
      }else{
        console.addAcc('Checa tu Sesión de WhatsApp');
        yield '[!] REVISA LA CONSOLA';
        hayErr = true;
      }
    }

    if(timer != null) { timer!.cancel(); }
    if(hayErr) {
      yield '[X] ERROR DE CONEXIÓN';
    }
  }

  
  // ------------------ FUNCTIONS ---------------

  ///
  Future<bool> _lanzarBrowser(bool withDown) async {

    indexMsg = 0;
    if(withDown) {
      const uno =
      'El arranque puede durar\n'
      'considerables minutos ya que\n'
      'se descargará un navegador en tu\n'
      'directorio local de trabajo.\n';
      console.addTask(uno);
    }

    prefixMsg = 'B';
    timer = Timer.periodic(
      const Duration(milliseconds: 1500), _showMsgScreen
    );
    connProv.browser = await BrowserConn.lanzar();
    if(BrowserConn.typeErr.isNotEmpty) {
      console.addErr('[BR] ${BrowserConn.typeErr}');
    }
    console.addWar('Esperando 10 Segundos...');
    await Future.delayed(const Duration(milliseconds: 10000));
    if(connProv.browser != null) {
      metadata = await pupEm.getListTargets();
      if(metadata.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  ///
  Future<bool> _lanzarWhats() async {

    indexMsg = 0;
    bool res = false;
    final firstPage = await connProv.browser!.pages;
    if(firstPage.isNotEmpty) {

      prefixMsg = 'W';
      timer = Timer.periodic(const Duration(milliseconds: 1500), _showMsgScreen);
      connProv.titleCurrent = await BrowserConn.tryLunchWhatsapp(firstPage.first);
      if(BrowserConn.typeErr.isNotEmpty) {
        console.addErr('[WA] ${BrowserConn.typeErr}');
      }
      if(connProv.titleCurrent.toLowerCase().contains(
        pageWhatsapp.toLowerCase()
      )) {
        res = await _hasWhatsOpen();
      }
    }
    timer!.cancel();
    return res;
  }

  ///
  Future<bool> _hasWhatsOpen() async {

    bool existWhats = false;

    if(metadata.isEmpty) {
      metadata = await pupEm.getListTargets();
    }
    if(metadata.isEmpty) {
      console.addOk('Metadatos perdidos');
      return false;
    }

    final hasWs = metadata.where(
      (e) => e['url'].toString().toLowerCase() == uriWhatsapp.toLowerCase()
    ).toList();

    if(hasWs.isNotEmpty) {
      existWhats = await _setPageById('${hasWs.first['id']}');
      if(existWhats) {
        connProv.targetId = '${hasWs.first['id']}';
        connProv.titleCurrent = '${hasWs.first['title']}';
        console.addOk('WhatsApp alcanzado con éxito');
      }
    }else{
      console.addOk('WhatsApp Cerrado');
    }

    return existWhats;
  }

  ///
  Future<bool> _setPageById(idPage) async {

    connProv.pagewa = await BrowserConn.getPageByIdTarget(
      connProv.browser!, idPage
    );
    if(connProv.pagewa != null) {
      return true;
    }
    return false;
  }

  ///
  Future<void> _sleep({int time = 250}) async => await Future.delayed(Duration(milliseconds: time));

  ///
  void _showMsgScreen(_) {

    List<String> msgs = [
      '[$prefixMsg] Espera un mometo más, por favor.',
      '[$prefixMsg] No te desesperes ahí vamos!.',
      '[$prefixMsg] Estamos configurando todo.',
      '[$prefixMsg] Esto esta tardando un poco más.',
      '[$prefixMsg] Ups!, ahí vamos con ésto.',
      '[$prefixMsg] Arrancando motores.',
    ];

    if((timer!.tick % 3) == 0) {
      if(indexMsg >= 5) {
        indexMsg = 0;
      }
      console.addTask(msgs[indexMsg]);
      indexMsg++;
    }
    return;
  }

}