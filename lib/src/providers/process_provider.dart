import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:cron/cron.dart';
import 'package:scm/src/providers/terminal_provider.dart';

import '../config/sng_manager.dart';
import '../entity/proceso_entity.dart';
import '../entity/scm_entity.dart';
import '../services/push_send.dart';
import '../services/get_content_files.dart';
import '../services/scm/scm_paths.dart';
import '../vars/globals.dart';

class ProcessProvider extends ChangeNotifier {

  final Globals _globals = getSngOf<Globals>();
  String get verScm => _globals.ver;
  
  /// Utilizado para saber si estamos dentro de la seccion de 
  /// conectar browser, y saber en que seccion estamos.
  /// seccs: browser | whatsapp | test
  String seccBrowConn = '';

  /// El id del registro que se creo antes de enviar un mensaje
  /// con el fin de no duplicar registros en caso de necesitar
  /// repetir la acción de envio del mismo receiver.
  int idRegDb = 0;

  /// Estas variables son para no tocar la variable original del
  /// recerverCurrent y utilizar estas para enviar los mensajes.
  String curcProcess = '';
  String nombreProcess = '';
  /// Este es usado para saber si se esta corriendo un proceso
  /// pero que al finalizar debe de continuar con el siguiente
  /// proceso de error, marcado dentro de la variable receiverCurrent.cmds
  bool isProcessOnErr = false;
  /// Utilizado para saber en que momento se presiono el
  /// boton de refresh y realizar dicha acción.
  bool isRefresh = false;
  bool _isActiveRefresh = false;
  bool get isActiveRefresh => _isActiveRefresh;
  set isActiveRefresh(bool isAc) {
    _isActiveRefresh = isAc;
    notifyListeners();
  }
  Map<String, dynamic> fileBeforeRefresh = {
    'idRegDb':0, 'campFile': '', 'receiverFile': '', 'campJson':{}
  };
  void cleanRefresh() {
    fileBeforeRefresh = {
      'idRegDb':0, 'campFile': '', 'receiverFile': '', 'campJson':{}
    };
    isRefresh = false;
  }

  ///
  bool _isPause = false;
  bool get isPause => _isPause;
  set isPause(bool isP) {
    _isPause = isP;
    notifyListeners();
  }

  /// Utilizado para indicar que el mensaje no debe enviarse
  bool _noSendMsg  = false;
  bool get noSendMsg => _noSendMsg;
  set noSendMsg(bool isT) {
    _noSendMsg = isT;
    notifyListeners();
  }
  
  ///
  bool _isTest  = false;
  bool get isTest => _isTest;
  set isTest(bool isT) {
    _isTest = isT;
    notifyListeners();
  }

  /// Usado para no tomar el mismo tester en cada prueba
  int indexLastCurcTester = -1;

  List<Map<String, dynamic>> _lstTestings = [];
  List<Map<String, dynamic>> get lstTestings => _lstTestings;
  set lstTestings(List<Map<String, dynamic>> cmds){
    _lstTestings = cmds;
    notifyListeners();
  }
  
  DateTime initRR = DateTime.now();

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
  Cron cron = Cron();
  
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

  /// [r] El mensaje actual del receptor actual, este mensaje
  /// se actualizará cada ves que se cambie al receptor o 
  /// cambie el mensaje en si que se quiere enviar Ej. alerta al avo.
  List<String> msgCurrentFormat = [];

  bool _isStopCronFles = true;
  bool get isStopCronFles => _isStopCronFles;
  set isStopCronFles(bool isT){
    _isStopCronFles = isT;
    notifyListeners();
  }

  int cadaL = 3;

  //--------------------------- FUNCTIONS ----------------------------
  
  void cleanProcess() {
    curcProcess = '';
    nombreProcess = '';
    isProcessOnErr = false;
    _isPause = false;
    msgCurrentFormat = [];
  }

  /// [r] Limpiamos las variables correspondientes a la campaña actual
  void cleanCampaingCurrent({bool fromSender = false}) {

    idRegDb = 0;
    _tituloColaBarr = 'Cargando...';
    _msgCurrent= [];
    _enProceso = ProcesoEntity();
    _receiverCurrent = ScmEntity();
    if(!fromSender) {
      currentFileReceiver = '';
    }
    currentFileProcess = '';
  }

  /// [r] Usado solo para cerrar sesion
  Future<void> cerrarSesion() async {

    cleanCampaingCurrent();
    cron.close();
    _isStopCronFles = true;
    _isPause = false;
    _isTest = false;
    _enAwait = 0;
    _sended = 0;
    _papelera = 0;
  }

  /// [r] Buscaremos para ver si callo una campaña con mayor prioridad
  /// que con la que se esta trabajando.
  /// 
  /// Por lo tanto solo se buscará en la carpeta de TRAY, en caso de haber una
  /// le ponemos el prefijo de trabajo y dejamos que el cron haga lo suyo
  Future<void> buscamosCampaniaPrioritaria
    ({TerminalProvider? console, bool inFromSender = false}) async 
  {

    const String msgWait = 'En espera de nuevas Campañas';

    if(isRefresh){
      bool isOk = false;
      idRegDb = fileBeforeRefresh['idRegDb'];
      if(fileBeforeRefresh['campJson'].isNotEmpty) {
        if(fileBeforeRefresh['campJson']['id'] != 0) {
          if(fileBeforeRefresh['receiverFile'].isNotEmpty) {
            if(fileBeforeRefresh['campFile'].isNotEmpty) {
              isOk = true;
            }
          }
        }
      }
      if(!isOk) {
        cleanRefresh();
      }
    }

    if(currentFileReceiver.isEmpty || inFromSender) {

      if(console != null) {
        console.addTask('Buscando Prioridades...');
      }

      final campas = GetContentFile.getLstFilesByFolder(FoldStt.tray);
      if(campas.isEmpty) {
        timer = 1;
        if(console != null) {
          console.addTask(msgWait);
        }else{
          reloadMsgAcction = msgWait;
        }
        return;
      }

      if(!isStopCronFles) {
        await cron.close();
        Future.microtask(() => isStopCronFles = true );
      }

      if(console != null) {
        console.addTask('Verificando más Campañas');
      }else{
        reloadMsgAcction = 'Checando Msgs. Prioritarios.';
      }
      await Future.delayed(const Duration(milliseconds: 250));

      var filePriory = '';
      if(isRefresh){
        if(fileBeforeRefresh['receiverFile']!.isNotEmpty) {
          filePriory = fileBeforeRefresh['receiverFile']!;
        }else{
          filePriory = await _getFileNameReceiver(campas);
        }
      }else{
        filePriory = await _getFileNameReceiver(campas);
      }

      if(filePriory.isEmpty) {

        if(console != null) {
          console.addTask(msgWait);
        }else{
          reloadMsgAcction = msgWait;
        }

      }else{

        late bool isSame;
        receiverCurrent = ScmEntity();
        if(isRefresh){
          isSame = true;
          currentFileProcess = fileBeforeRefresh['campFile'];
          _setVariablesEnProceso(fileBeforeRefresh['campJson']);
        }else{
          isSame = await GetContentFile.isSameCampaing(
            currentFileProcess, filePriory
          );
        }

        if(isSame) {
          await _getReceiverToSend();
        }else{
          
          String typePush = '';
          if(reloadMsgAcction.contains('espera')) {
            typePush = 'init';
            if(console != null) {
              console.addTask('Tomando campaña Inicial.');
            }else{
              reloadMsgAcction = 'Tomando campaña Inicial.';
            }
          }else{
            typePush = 'change';
            if(console != null) {
              console.addTask('Cambiando campaña Prioritaria.');
            }else{
              reloadMsgAcction = 'Cambiando campaña Prioritaria.';
            }
          }
          await Future.delayed(const Duration(milliseconds: 250));
          
          final fileW = await GetContentFile.cambiamosFileDeTrabajo(
            currentFileProcess, filePriory
          );
          
          await _putCampaEnProceso(fileW, typePush);
          await _getReceiverToSend();
        }

        if(currentFileReceiver.isEmpty) {
          if(console != null) {
            console.addTask(msgWait);
          }else{
            reloadMsgAcction = msgWait;
          }
        }else{
          if(console != null) {
            console.addTask('Iniciando Envio');
          }else{
            reloadMsgAcction = 'Iniciando Envio';
          }
          await Future.delayed(const Duration(milliseconds: 250));
        }
      }
    }

    timer = 1;
    if(isStopCronFles) {
      await initCronFolderLocal();
    }
  }

  /// 
  Future<String> _getFileNameReceiver(List<FileSystemEntity> campas) async {

    String filePriory = '';
    if(campas.length > 1) {
      filePriory = await GetContentFile.searchPriority(campas);
    }else{
      filePriory = ScmPaths.extractNameFile(campas.first.path);
      if(filePriory.contains(ScmPaths.prefixFldWrk)) {
        filePriory = ScmPaths.removePrefixWork(filePriory, isPath: false);
      }
    }

    return filePriory;
  }

  /// [r] Colocamos en memoria todos los datos relacionados a
  /// la campaña que se va a preocesar.
  Future<void> _putCampaEnProceso(File? fileCamp, String typePush) async {

    if(typePush == 'change' && currentFileProcess.isNotEmpty) {
      if(_enProceso.id != 0) {
        await PushSend.ofChangeTo('2', _enProceso.toJson());
      }
    }
    cleanCampaingCurrent();
    if(fileCamp != null) {
      currentFileProcess = fileCamp.path;
      _setVariablesEnProceso(
        json.decode(fileCamp.readAsStringSync())
      );
      await PushSend.ofChangeTo('3', _enProceso.toJson());
    }
  }

  ///
  void _setVariablesEnProceso(Map<String, dynamic> enprocc) async {

    _enProceso = ProcesoEntity()..fromJson(enprocc);
    _msgCurrent = await GetContentFile.getMsgOfCampaing(
      _enProceso.campaing.msgTxt
    );
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
    if(isRefresh) {
      final fileRefresh = fileBeforeRefresh['receiverFile'];
      currentFileReceiver = (fileRefresh.isNotEmpty)
        ? fileRefresh : noSend.first;
      cleanRefresh();
    }

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
    final est = (foldTo == FoldStt.werr) ? '4' : '5';
    await PushSend.ofChangeTo(est, _enProceso.toJson());
    
    await GetContentFile.moveFileWorkingAndRemovePrefix(from: FoldStt.tray, to: foldTo);
    cleanCampaingCurrent();
  }

  /// [r] Revisamos si hay nuevos mensajes en la carpeta local
  Future<void> initCronFolderLocal() async {

    try {
      cron.schedule(Schedule.parse('*/$cadaL * * * * *'), () async {
        await checkingFolderLocales();
      });
      isStopCronFles = false;
    } catch (e) {

      if(e.toString().contains('Closed')) {
        cron = Cron();
        await Future.delayed(const Duration(milliseconds: 500));
        initCronFolderLocal();
      }
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

