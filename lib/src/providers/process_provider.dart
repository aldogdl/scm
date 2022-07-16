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

  /// Utilizado para saber en que momento se presiono el
  /// boton de refresh y realizar dicha acción.
  bool isRefresh = false;
  
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
  void setReloadMsgAcction(String msg) {
    _reloadMsgAcction = msg;
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
    try {
      notifyListeners();
    } catch (_) {}
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
    _enTray = enT;
    notifyListeners();
  }

  /// [r] Cantidad Mensajes en espera de envio
  int _enAwait = 0;
  int get enAwait => _enAwait;
  set enAwait(int enA){
    _enAwait = enA;
    notifyListeners();
  }

  /// [r] Cantidad de mensajes enviados
  int _sended = 0;
  int get sended => _sended;
  set sended(int enSen){
    _sended = enSen;
    notifyListeners();
  }

  /// [r] Cantidad de mensajes en papelera
  int _papelera = 0;
  int get papelera => _papelera;
  set papelera(int pap){
    _papelera = pap;
    notifyListeners();
  }

  /// [r] El path absoluto al archivo de la campaña en proceso
  String currentFileProcess = '';
  /// [r] El nombre del archivo del receiver que se esta enviando
  String currentFileReceiver = '';

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

  bool _isStopAllCrones = true;
  bool get isStopAllCrones => _isStopAllCrones;
  set isStopAllCrones(bool isT){
    _isStopAllCrones = isT;
    notifyListeners();
  }

  bool _isStopCronFles = true;
  bool get isStopCronFles => _isStopCronFles;
  set isStopCronFles(bool isT){
    _isStopCronFles = isT;
    notifyListeners();
  }

  bool _isStopCronStage = true;
  bool get isStopCronStage => _isStopCronStage;
  set isStopCronStage(bool isT){
    _isStopCronStage = isT;
    notifyListeners();
  }

  int cadaL = 3;
  int cadaS = 10;

  //--------------------------- FUNCTIONS ----------------------------
  
  /// [r] Detenemos los cron que revisan los folders excepto el
  /// del stage
  Future<void> stopCronFiles() async {
    cron['files']!.close();
    isStopCronFles = true;
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  /// [r] Detenemos los cron que revisan el folder stage
  Future<void> stopCronStage() async {
    cron['stage']!.close();
    isStopCronStage = true;
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// [r]
  Future<void> _stopAllCrones() async {
    cron['stage']!.close();
    cron['files']!.close();
    isStopAllCrones = true;
    isStopCronStage = true;
    isStopCronFles = true;
    await Future.delayed(const Duration(milliseconds: 3000));
  }
  
  /// [r] Usado para arrancar por primera vez.
  void startAllCrones() async {
    
    if(_reloadMsgAcction.isEmpty) {
      _reloadMsgAcction = 'HOLA ${_globals.user.nombre}';
    }
    isStopAllCrones = false;
    isStopCronStage = false;
    isStopCronFles = false;
    initCronFolderStage();
    await Future.delayed(const Duration(milliseconds: 3000));
    initCronFolderLocal();
  }

  /// [r] Limpiamos las variables correspondientes a la campaña actual
  void cleanCampaingCurrent() {

    _taskTerminal  = [];
    _lstTestings   = [];
    _msgCurrent    = [];
    if(!isRefresh) {
      currentFileProcess = '';
    }
    currentFileReceiver = '';
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

  /// [r] Buscaremos para ver si callo una campaña con mayor prioridad
  /// que con la que se esta trabajando.
  /// 
  /// Por lo tanto solo se buscará en la carpeta de TRAY, en caso de haber una
  /// le ponemos el prefijo de trabajo y dejamos que el cron haga lo suyo
  Future<void> buscamosCampaniaPrioritaria() async {

    if(currentFileReceiver.isEmpty) {

      if(!isStopCronFles) { await stopCronFiles(); }

      final campas = GetContentFile.getLstFilesByFolder(FoldStt.tray);

      if(campas.isNotEmpty) {

        var filePriory = '';
        if(campas.length > 1) {
          filePriory = await GetContentFile.searchPriority(campas);
        }else{
          filePriory = ScmPaths.extractNameFile(campas.first.path);
          if(filePriory.contains(ScmPaths.prefixFldWrk)) {
            filePriory = ScmPaths.removePrefixWork(filePriory, isPath: false);
          }
        }
        if(filePriory.isNotEmpty) {

          bool isSame = await GetContentFile.isSameCampaing(
            currentFileProcess, filePriory
          );

          receiverCurrent = ScmEntity();
          if(isSame) {
            await _getReceiverToSend();
          }else{
            
            int mili = 3000;
            if(reloadMsgAcction.contains('Espera')) {
              mili = 0;
            }
            reloadMsgAcction = 'Cambiando campaña Prioritaria.';
            await Future.delayed(Duration(milliseconds: mili));
            final fileW = await GetContentFile.cambiamosFileDeTrabajo(
              currentFileProcess, filePriory
            );
            cleanCampaingCurrent();
            await _putCampaEnProceso(fileW);
            await _getReceiverToSend();
          }
          
          if(currentFileReceiver.isNotEmpty) {
            if(reloadMsgAcction != 'Iniciando Envio') {
              reloadMsgAcction = 'Iniciando Envio';
            }
          }
        }
      }else{
        reloadMsgAcction = 'En espera de nuevas Campañas';
      }
    }
    
    timer = 1;
    if(isStopCronFles) {
      await initCronFolderLocal();
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
    currentFileReceiver = noSend.first;
    _receiverCurrent = ScmEntity()..fromProvider(
      await GetContentFile.getContentByFileAndFolder(
        fileName: currentFileReceiver, folder: FoldStt.wait
      )
    );
  }

  /// [r] Al llegar aqui es que ya no hay mas receptores en el
  /// campo de noSend, analizamos si ya fueron enviados todos.
  Future<void> _analizarCampEnProceso() async {

    final drash  = _enProceso.drash;
    FoldStt foldTo = FoldStt.hist;
    if(drash.isNotEmpty) {
      foldTo = FoldStt.werr;
    }
    await GetContentFile.moveFileWorkingAndRemovePrefix(from: FoldStt.tray, to: foldTo);
    cleanCampaingCurrent();
  }

  /// [r] Revisamos si hay nuevos mensajes en la carpeta local
  Future<void> initCronFolderLocal() async {

    try {
      cron['files']!.schedule(Schedule.parse('*/$cadaL * * * * *'), () async {
        await checkingFolderLocales();
      });
      isStopCronFles = false;
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

    if(!isStopCronStage) { await stopCronStage(); }
    
    String pathWrk = await GetContentFile.putWorkingIfAbsent(
      folder: FoldStt.stage
    );

    if(pathWrk != _extrayendoReceptoresOf) {
      _extrayendoReceptoresOf = pathWrk;
      await GetContentFile.extraerReceptores(_extrayendoReceptoresOf);
      _extrayendoReceptoresOf = '';
      final cat  = await GetContentFile.getCantContentFilesByFolder(FoldStt.stage);
      enTray = enTray +1;
      await Future.delayed(const Duration(milliseconds: 250));
      if(cat > 0) {
        _checkingFolderStage();
        return;
      }
    }

    timerS = 1;
    if(isStopCronStage) {
      isStopCronStage = false;
      initCronFolderStage();
    }
  }

  /// [r] Realizar el chequeo de archivos en las carpetas de tray, await, sended y drash.  
  /// Solo en la carpeta de tray hace trabajo en las demas solo nos da la cantidad de
  /// archivos existentes.
  Future<void> checkingFolderLocales() async {
    
    var cat = await GetContentFile.getCantContentFilesByFolder(FoldStt.tray);
    if(cat != enTray) { enTray = cat; }

    buscamosCampaniaPrioritaria().whenComplete(() async {
      cat = await GetContentFile.getCantContentFilesByFolder(FoldStt.wait);
      if(cat != enAwait) { enAwait = cat; }
      cat  = await GetContentFile.getCantContentFilesByFolder(FoldStt.sended);
      if(cat != sended) { sended = cat; }
      cat  = await GetContentFile.getCantContentFilesByFolder(FoldStt.drash);
      if(cat != papelera) { papelera = cat; }
    });
  }

}

