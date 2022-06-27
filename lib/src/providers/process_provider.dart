import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:cron/cron.dart';

import '../config/sng_manager.dart';
import '../entity/proceso_entity.dart';
import '../entity/scm_entity.dart';
import '../services/get_content_files.dart';
import '../services/scm/scm_paths.dart';
import '../vars/globals.dart';

class ProcessProvider extends ChangeNotifier {

  final Globals _globals = getSngOf<Globals>();

  /// Usado para mostrar un punto intermitente cuando el proceso este en pausa
  bool _termitente = false;
  bool get termitente => _termitente;
  set termitente(bool isP) {
    _termitente = isP;
    notifyListeners();
  }

  ///
  bool _isPause = false;
  bool get isPause => _isPause;
  set isPause(bool isP) {
    _isPause = isP;
    _termitente = _isPause;
    notifyListeners();
  }

  /// Utilizado para indicar que el mensaje no debe enviarse
  bool _noSend  = false;
  bool get noSend => _noSend;
  set noSend(bool isT) {
    _noSend = isT;
    notifyListeners();
  }
  
  ///
  bool _isTest  = false;
  bool get isTest => _isTest;
  set isTest(bool isT) {
    _isTest = isT;
    notifyListeners();
  }

  /// Usado para hacer testing desde comandos
  List<Map<String, dynamic>> _lstTestings = [];
  List<Map<String, dynamic>> get lstTestings => _lstTestings;
  set lstTestings(List<Map<String, dynamic>> cmds){
    _lstTestings = cmds;
    notifyListeners();
  }
  
  DateTime initRR = DateTime.now();

  bool _terminalIsMini = true;
  bool get terminalIsMini => _terminalIsMini;
  set terminalIsMini(bool isMini) {
    _terminalIsMini = isMini;
    notifyListeners();
  }

  /// Usado para ver cuantas revisiones ha hecho al servidor remoto
  List<String> _taskTerminal = [];
  List<String> get taskTerminal => _taskTerminal;
  set taskTerminal(List<String> tasks){
    _taskTerminal = tasks;
    notifyListeners();
  }
  addNewtaskTerminal(String task, {int esp = 100}) async {
    _taskTerminal.insert(0, task);
    notifyListeners();
    await Future.delayed(Duration(milliseconds: esp));
  }

  /// Para la página bacia que se usa para recargar ReloadPage()
  String _reloadMsgAcction = '';
  String get reloadMsgAcction => _reloadMsgAcction;
  set reloadMsgAcction(String msg) {
    _reloadMsgAcction = msg;
    notifyListeners();
  }
  void cleanReloadMsgAcction() {
    _reloadMsgAcction = '';
  }

  ///
  bool _verColaMini = false;
  bool get verColaMini => _verColaMini;
  set verColaMini(bool receiver) {
    _verColaMini = receiver;
    notifyListeners();
  }

  ///
  String _tituloColaBarr = 'Cargando...';
  String get tituloColaBarr => _tituloColaBarr;
  set setTituloColaBarr(String tit) => _tituloColaBarr = tit;
  set tituloColaBarr(String receiver) {
    _tituloColaBarr = receiver;
    notifyListeners();
  }
  
  /// [r] los crones que se estan utilizando
  Map<String, Cron> cron = {
    'stage' : Cron(),
    'files' : Cron(),
  };
  
  /// El numero de veces que se hace una revisión
  /// a la carpeta de await
  int _timer = 0;
  int get timer => _timer;
  set timer(int inc){
    _timer = _timer + inc;
    notifyListeners();
  }

  /// El numero de veces que se hace una revisión
  /// a la carpeta de stage
  int _timerS = 0;
  int get timerS => _timerS;
  set timerS(int inc){
    _timerS = _timerS + inc;
    notifyListeners();
  }

  /// [r] Bandeja Cantidad de campañas pendientes
  int _enTray = 0;
  int get enTray => _enTray;
  set enTray(int enT){
    if(enT != _enTray) {
      _enTray = enT;
      notifyListeners();
    }
  }

  /// [r] Cantidad Mensajes en espera de envio
  int _enAwait = 0;
  int get enAwait => _enAwait;
  set enAwait(int enA){
    if(enA != _enAwait) {
      _enAwait = enA;
      notifyListeners();
    }
  }

  /// [r] Cantidad de mensajes enviados
  int _sended = 0;
  int get sended => _sended;
  set sended(int enSen){
    if(enSen != _sended) {
      _sended = enSen;
      notifyListeners();
    }
  }

  /// [r] Cantidad de mensajes en papelera
  int _papelera = 0;
  int get papelera => _papelera;
  set papelera(int pap){
    if(pap != _papelera) {
      _papelera = pap;
      notifyListeners();
    }
  }

  /// [r] El path absoluto al archivo de la campaña en proceso
  String currentFileProcess = '';
  /// [r] El nombre del archivo del receiver que se esta enviando
  String currentFileReveiver = '';

  /// [r] El contenedor de la data completa de la campaña que se esta
  /// procesando actualmente.
  ProcesoEntity _enProceso = ProcesoEntity();
  ProcesoEntity get enProceso => _enProceso;
  set enProceso(ProcesoEntity proc) {
    _enProceso = proc;
    notifyListeners();
  }
  
  /// [r] Es usado para procesar el envio, este es el que se
  /// toma en cuenta para la seccion de send_to_receiver
  ScmEntity _receiverCurrent = ScmEntity();
  ScmEntity get receiverCurrent => _receiverCurrent;
  set receiverCurrent(ScmEntity receiver) {
    _receiverCurrent = receiver;
    notifyListeners();
  }
  set receiverCurrentClean(ScmEntity receiver) {
    _receiverCurrent = receiver;
  }

  /// [r] El mensaje actual de la campaña en proceso
  List<String> _msgCurrent = [];
  List<String> get msgCurrent => _msgCurrent;
  void setMsgCurrent(List<String> msg) {
    _msgCurrent = msg;
  }

  ///
  String _extrayendoReceptoresOf = '';
  bool isStopAllCrones = true;
  bool _isStopCronFles = true;
  bool _isStopCronStage = true;

  int cadaL = 3;
  int cadaS = 10;

  //--------------------------- FUNCTIONS ----------------------------
  
  /// [r] Detenemos los cron que revisan los folders excepto el
  /// del stage
  Future<void> stopCronFiles() async {
    cron['files']!.close();
    _isStopCronFles = true;
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  /// [r] Detenemos los cron que revisan el folder stage
  Future<void> stopCronStage() async {
    cron['stage']!.close();
    _isStopCronStage = true;
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// [r]
  Future<void> _stopAllCrones() async {
    cron['stage']!.close();
    cron['files']!.close();
    isStopAllCrones = true;
    _isStopCronStage = true;
    _isStopCronFles = true;
    await Future.delayed(const Duration(milliseconds: 3000));
  }
  
  /// [r] Usado para arrancar por primera vez.
  void startAllCrones() async {
    
    if(_reloadMsgAcction.isEmpty) {
      _reloadMsgAcction = 'HOLA ${_globals.user.nombre}';
    }
    isStopAllCrones = false;
    _isStopCronStage = false;
    _isStopCronFles = false;
    initCronFolderStage();
    await Future.delayed(const Duration(milliseconds: 3000));
    initCronFolderLocal();
  }

  /// [r] Limpiamos las variables correspondientes a la campaña actual
  void cleanCampaingCurrent() {

    _taskTerminal  = [];
    _lstTestings   = [];
    _msgCurrent    = [];
    currentFileProcess = '';
    currentFileReveiver = '';
    _tituloColaBarr = 'Cargando...';
    _verColaMini = false;
    _termitente = false;
    _enProceso = ProcesoEntity();
    _receiverCurrent = ScmEntity();
  }

  
  /// [r] Usado solo para cerrar sesion
  Future<void> cerrarSesion() async {

    cleanCampaingCurrent();
    await _stopAllCrones();
    _isPause = false;
    _isTest = false;
    _terminalIsMini = true;
    _taskTerminal = [];
    _enAwait = 0;
    _sended = 0;
    _papelera = 0;
  }

  /// [r] Sistituimos las variables dentro del msg por valores
  List<String> formaterMsg() {

    List<String> msg = List<String>.from(msgCurrent);

    for (var i = 0; i < msg.length; i++) {
      if(msg[i].contains('_idCtc_')) {
        msg[i] = msg[i].replaceAll('_idCtc_', '${receiverCurrent.idReceiver}');
      }
      if(msg[i].contains('_nombre_')) {
        msg[i] = msg[i].replaceAll('_nombre_', receiverCurrent.receiver.nombre);
      }
    }
    return msg;
  }

  /// [r] Buscaremos para ver si callo una campaña con mayor prioridad
  /// que con la que se esta trabajando.
  /// 
  /// Por lo tanto solo se buscará en la carpeta de TRAY, en caso de haber una
  /// le ponemos el prefijo de trabajo y dejamos que el cron haga lo suyo
  Future<void> buscamosCampaniaPrioritaria() async {

    if(currentFileReveiver.isNotEmpty) { return; }
    
    if(!_isStopCronFles) { await stopCronFiles(); }
   
    final campas = GetContentFile.getLstFilesByFolder(FoldStt.tray);
    if(campas.isEmpty) { return; }

    var filePriory = '';
    if(campas.length > 1) {
      filePriory = await GetContentFile.searchPriority(campas);
    }else{
      if(!campas.first.path.contains(ScmPaths.prefixFldSended)) {
        filePriory = ScmPaths.extractNameFile(campas.first.path);
        if(filePriory.contains(ScmPaths.prefixFldWrk)) {
          filePriory = ScmPaths.removePrefixWork(filePriory, isPath: false);
        }
      }
    }

    if(filePriory.isNotEmpty) {
      bool isSame = await GetContentFile.isSameCampaing(
        currentFileProcess, filePriory
      );
      if(isSame) {
        await _getReceiverToSend();
      }else{
        final fileW = await GetContentFile.cambiamosFileDeTrabajo(
          currentFileProcess, filePriory
        );
        await _putCampaEnProceso(fileW);
        await _getReceiverToSend();
      }
      
      if(currentFileReveiver.isNotEmpty) {

        // reloadMsgAcction = 'Iniciando Envio';
      }
    }
  }

  /// [r] Colocamos en memoria todos los datos relacionados a
  /// la campaña que se va a preocesar.
  Future<void> _putCampaEnProceso(File? fileCamp) async {

    cleanCampaingCurrent();
    if(fileCamp != null) {
      currentFileProcess = fileCamp.path;
      _enProceso = ProcesoEntity()..fromJson(
        json.decode(fileCamp.readAsStringSync())
      );
      _msgCurrent = await GetContentFile.getMsgOfCampaing(
        _enProceso.campaing.msgTxt
      );
    }
  }

  /// [r] De la campaña que esta en memoria y que se esta procesando
  /// actualmente, tomamos el primer archivo del receiver para enviar
  Future<void> _getReceiverToSend() async {

    final noSend = _enProceso.noSend;
    if(noSend.isEmpty) {
      await _analizarCampEnProceso();
      return;
    }
    currentFileReveiver = noSend.first;
    _receiverCurrent = ScmEntity()..fromProvider(
      await GetContentFile.getContentByFileAndFolder(
        fileName: currentFileReveiver, folder: FoldStt.wait
      )
    );
  }

  /// [r] Al llegar aqui es que ya no hay mas receptores en el
  /// campo de noSend, analizamos si ya fueron enviados todos.
  Future<void> _analizarCampEnProceso() async {

    final toSend = _enProceso.toSend;
    final sended = _enProceso.sended;
    if(toSend.length != sended.length) {
      // Hacemos un analisis pero necesito ver como se almacenaran
      // los errores y cotejarlos antes de tomar decicion de ya
      // enviado...
      // TODO
    }
  }

  /// [r] Revisamos si hay nuevos mensajes en la carpeta local
  Future<void> initCronFolderLocal() async {

    try {
      cron['files']!.schedule(Schedule.parse('*/$cadaL * * * * *'), () async {
        await _checkingFolderLocales();
      });
      _isStopCronFles = false;
    } catch (e) {

      if(e.toString().contains('Closed')) {
        cron['files'] = Cron();
        await Future.delayed(const Duration(milliseconds: 500));
        initCronFolderLocal();
      }
    }
  }

  /// [r] Revisamos si hay nuevos mensajes en el Stage
  void initCronFolderStage() {

    try {
      cron['stage']!.schedule(Schedule.parse('*/$cadaS * * * * *'), () async {
        await _checkingFolderStage();
      });
    } catch (e) {

      if(e.toString().contains('Closed')) {
        cron['stage'] = Cron();
        initCronFolderStage();
      }
    }
  }

  /// [r] Realizar el chequeo de archivos en la carpeta stage.
  Future<void> _checkingFolderStage() async {

    if(!_isStopCronStage) { await stopCronStage(); }
    
    String pathWrk = await GetContentFile.putWorkingIfAbsent(
      folder: FoldStt.stage
    );

    if(pathWrk != _extrayendoReceptoresOf) {
      _extrayendoReceptoresOf = pathWrk;
      await GetContentFile.extraerReceptores(_extrayendoReceptoresOf);
      _extrayendoReceptoresOf = '';
    }

    timerS = 1;
    if(_isStopCronStage) {
      _isStopCronStage = false;
      initCronFolderStage();
    }
  }

  /// [r] Realizar el chequeo de archivos en las carpetas de tray, await, sended y drash.  
  /// Solo en la carpeta de tray hace trabajo en las demas solo nos da la cantidad de
  /// archivos existentes.
  Future<void> _checkingFolderLocales() async {

    enAwait = await GetContentFile.getCantContentFilesByFolder(FoldStt.wait);
    enTray  = await GetContentFile.getCantContentFilesByFolder(FoldStt.tray);
    sended  = await GetContentFile.getCantContentFilesByFolder(FoldStt.sended);
    papelera= await GetContentFile.getCantContentFilesByFolder(FoldStt.drash);
    buscamosCampaniaPrioritaria().then((_) async {
      timer = 1;
      if(_isStopCronFles) {
        _isStopCronFles = false;
        await initCronFolderLocal();
      }
    });
  }

}

