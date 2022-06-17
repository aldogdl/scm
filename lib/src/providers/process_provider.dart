import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:cron/cron.dart';

import '../config/sng_manager.dart';
import '../entity/proceso_entity.dart';
import '../entity/scm_entity.dart';
import '../entity/scm_file.dart';
import '../services/get_content_files.dart';
import '../services/get_paths.dart';
import '../services/my_http.dart';
import '../vars/globals.dart';

class ProcessProvider extends ChangeNotifier {

  final Globals _globals = getSngOf<Globals>();
  bool _isDowload = false;

  ///
  Map<String, Cron> cron = {
    'stage' : Cron(),
    'files' : Cron(),
    'remoto': Cron(),
  };

  String _extrayendoReceptoresOf = '';
  bool _blockRevRemota = false;
  bool _blockCheckLocal = false;
  bool _blockCheckStage = false;
  bool _isStopAllCrones = false;


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

  ///
  bool _isTest  = false;
  bool get isTest => _isTest;
  set isTest(bool isT) {
    _isTest = isT;
    notifyListeners();
  }

  ///
  bool _noSend  = false;
  bool get noSend => _noSend;
  set noSend(bool isT) {
    _noSend = isT;
    notifyListeners();
  }

  ///
  bool _isStopedByUserRemoto = false;
  bool get isStopedByUserRemoto => _isStopedByUserRemoto;
  set isStopedByUserRemoto(bool stop) {
    _isStopedByUserRemoto = stop;
    if(stop) {
      cron['remoto']!.close();
    }else{
      initCronServidorRemoto();
    }
    notifyListeners();
  }

  ///
  bool _isStopedByUserFiles = false;
  bool get isStopedByUserFiles => _isStopedByUserFiles;
  set isStopedByUserFiles(bool stop) {
    _isStopedByUserFiles = stop;
    if(stop) {
      cron['files']!.close();
      cron['stage']!.close();
    }else{
      initCronFolderLocal();
      initCronFolderStage();
    }
    notifyListeners();
  }

  /// La version del centinela
  int _verCenti = 0;
  int get verCenti => _verCenti;
  set verCenti(int newver) {
    _verCenti = verCenti;
    notifyListeners();
  }

  DateTime initRR = DateTime.now();
  Map<String, dynamic> lastResult = {};

  /// Usado para ver cuantas revisiones ha hecho al servidor remoto
  bool _terminalIsMini = true;
  bool get terminalIsMini => _terminalIsMini;
  set terminalIsMini(bool isMini) {
    _terminalIsMini = isMini;
    notifyListeners();
  }

  /// Cantidad de campañas pendientes
  int _enTray = 0;
  int get enTray => _enTray;
  set enTray(int enT){
    if(enT != _enTray) {
      _enTray = enT;
      notifyListeners();
    }
  }

  /// Cantidad de mensajes pendientes
  int _enAwait = 0;
  int get enAwait => _enAwait;
  set enAwait(int enA){
    if(enA != _enAwait) {
      _enAwait = enA;
      notifyListeners();
    }
  }

  /// La lista de mensajes enviados
  int _sended = 0;
  int get sended => _sended;
  set sended(int enSen){
    if(enSen != _sended) {
      _sended = enSen;
      notifyListeners();
    }
  }

  /// La lista de mensajes en papelera
  int _papelera = 0;
  int get papelera => _papelera;
  set papelera(int pap){
    if(pap != _papelera) {
      _papelera = pap;
      notifyListeners();
    }
  }
  
  /// Usado para ver cuantas revisiones ha hecho al servidor remoto
  int _nRevRm = 0;
  int get nRevRm => _nRevRm;
  void setnRevRm() {
    _nRevRm++;
    notifyListeners();
  }

  /// El numero de veces que se hace una revisión
  /// a la carpeta de await
  int _timer = 0;
  int get timer => _timer;
  void timerL(){
    _timer++;
    notifyListeners();
  }

  /// El numero de veces que se hace una revisión
  /// a la carpeta de stage
  int _timerS = 0;
  int get timerS => _timerS;
  void timerSt(){
    _timerS++;
    //notifyListeners();
  }

  /// Para la página bacia que se usa para recargar ReloadPage()
  String _reloadMsgAcction = 'Preparandome para Autenticarte';
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

  String currentFileProcess = '';

  /// El contenedor de la data completa de la campaña que se esta
  /// procesando actualmente.
  ProcesoEntity _enProceso = ProcesoEntity();
  ProcesoEntity get enProceso => _enProceso;
  set enProceso(ProcesoEntity proc) {
    _enProceso = proc;
    notifyListeners();
  }

  /// La lista de todos los receptores de la campaña en proceso
  List<ScmEntity> _receiversCola = [];
  List<ScmEntity> get receiversCola => _receiversCola;
  set receiversCola(List<ScmEntity> lstRe) {
    _receiversCola = lstRe;
    notifyListeners();
  }
  void cleanReceiversCola() {
    _receiversCola = [];
  }
  
  /// Es usado para procesar el envio, este es el que se toma en cuenta para
  /// la seccion de send_to_receiver
  int idCurrenProcesando = -1;
  ScmEntity _receiverCurrent = ScmEntity();
  ScmEntity get receiverCurrent => _receiverCurrent;
  set receiverCurrent(ScmEntity receiver) {
    _receiverCurrent = receiver;
    idCurrenProcesando = receiver.idReceiver;
    notifyListeners();
  }
  set receiverCurrentClean(ScmEntity receiver) {
    _receiverCurrent = receiver;
  }

  /// La lista de todas las campañas que estan a la espera, son
  /// todos los archivos que estan en la carpeta TRAY
  List<Map<String, dynamic>> _campaingsCola = [];
  List<Map<String, dynamic>> get campaingsCola => _campaingsCola;
  set campaingsCola(List<Map<String, dynamic>> lstRe) {
    _campaingsCola = lstRe;
    notifyListeners();
  }
  void cleanCampaingsCola() {
    _campaingsCola = [];
  }

  ///
  List<String> _msgCurrent = [];
  List<String> get msgCurrent => _msgCurrent;
  void setMsgCurrent(List<String> msg) {
    _msgCurrent = msg;
  }

  /// Usado para hacer testing desde comandos
  List<Map<String, dynamic>> _lstTestings = [];
  List<Map<String, dynamic>> get lstTestings => _lstTestings;
  set lstTestings(List<Map<String, dynamic>> cmds){
    _lstTestings = cmds;
    notifyListeners();
  }
  
  //--------------------------- FUNCTIONS ----------------------------
  
  ///
  void cambiarDeCampaing() {

    _receiversCola = [];
    _taskTerminal  = [];
    _lstTestings   = [];
    _campaingsCola = [];
    currentFileProcess = '';
    _tituloColaBarr = 'Cargando...';
    _verColaMini = false;
    _termitente = false;
    _enProceso = ProcesoEntity();
    _receiverCurrent = ScmEntity();
  }
  
  ///
  void stopAllCrones() async {
    cron['stage']!.close();
    cron['files']!.close();
    cron['remoto']!.close();
    _isStopedByUserRemoto = true;
    _isStopedByUserFiles = true;
    _isStopAllCrones = true;
    await Future.delayed(const Duration(milliseconds: 3000));
  }

  ///
  void startAllCrones() async {
    _blockRevRemota = false;
    _isStopedByUserRemoto = false;
    _isStopedByUserFiles = false;
    _isStopAllCrones = false;
    initCronFolderStage();
    await Future.delayed(const Duration(milliseconds: 3000));
    initCronFolderLocal();
    await Future.delayed(const Duration(milliseconds: 1000));
    initCronServidorRemoto();
  }

  ///
  void clean() {
    _isPause = false;
    _isTest = false;
    _isStopedByUserRemoto = false;
    _isStopedByUserFiles = false;
    lastResult = {};
    _enProceso = ProcesoEntity();
    _terminalIsMini = true;
    _taskTerminal = [];
    _enAwait = 0;
    _sended = 0;
    _papelera = 0;
    _blockRevRemota = false;
  }

  ///
  List<String> getMensajeFormated() {

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

  /// Buscaremos para ver si callo una campaña con mayor prioridad
  /// que con la que se esta trabajando.
  /// 
  /// Por lo tanto solo se buscará en la carpeta de TRAY, en caso de haber una
  /// le ponemos el prefijo de trabajo y dejamos que el cron haga su trabajo
  Future<void> buscamosCampaniaPrioritaria({bool onlyCheck = false}) async {

    if(!_isStopAllCrones) {
      stopAllCrones();
    }

    ScmFile fileS = ScmFile();
    final dir = GetPaths.getPathsFolderTo(fileS.getFolder(FoldStt.tray));

    String current = '';
    String fileRes = '';
    List<List<String>> archivos = [];
    List<List<String>> priory = [];

    if(dir != null) {
      if(dir.existsSync()) {

        final campas = dir.listSync();
        if(campas.isNotEmpty) {
          if(campas.length > 1) {

            reloadMsgAcction = '-> CALCULANDO PRIORIDADES';
            await Future.delayed(const Duration(milliseconds: 500));

            for (var i = 0; i < campas.length; i++) {
              if(!campas[i].path.contains(fileS.prefixFldSended)) {
                List<String> uriP = campas[i].path.split(fileS.sep).toList();
                String findF = uriP.removeLast();
                if(findF.startsWith(fileS.prefixFldWrk)) {
                  findF = findF.replaceFirst(fileS.prefixFldWrk, '').trim();
                  current = findF;
                  fileS.pathOrigin = campas[i].path;
                  fileS.parse();
                }
                archivos.add(findF.split(fileS.sF));
              }
            }

            if(archivos.isNotEmpty) {

              priory = List<List<String>>.from(archivos);
              // Reducimos la lista a una mayor prioridad
              for (var i = 0; i < 3; i++) {
                priory = reduceList(toReduce: priory, index: i);
              }
              
              if(priory.isEmpty) {
                priory = List<List<String>>.from(archivos);
                for (var i = 0; i < 3; i++) {
                  priory = reduceList(toReduce: priory, index: i, isOtros: true);
                }
                fileRes = priory.first.join(fileS.sF);
              }else{
                fileRes = priory.first.join(fileS.sF);
              }

              bool sn = true;
              if(current != fileRes) {

                List<String> finalComp = [current, fileRes];
                finalComp.sort();
                if(current != finalComp.first) {

                  sn = false;
                  await fileS.prefixWorking(accion: 'del');
                  reloadMsgAcction = '-> CAMBIO DE MSG PRIORITARIO';
                  
                  cambiarDeCampaing();
                  await Future.delayed(const Duration(milliseconds: 1000));
                  
                  fileS = ScmFile(pathOrigin: '${fileS.pathSinFile}${fileS.sep}$fileRes');
                  await fileS.prefixWorking(accion: 'put');
                  reloadMsgAcction = '-> LISTO ESPERANDO CAMPAÑAS';
                }
              }

              if(sn) {
                reloadMsgAcction = '-> CONTINUAMOS... SIN PRIORIDAD';
                if(!onlyCheck) {
                  await Future.delayed(const Duration(milliseconds: 500));
                  reloadMsgAcction = 'Recargando proceso de envio...';
                }
              }

            }else{
              reloadMsgAcction = '-> NADA QUE PROCESAR';
              setMsgCurrent([]);
              await Future.delayed(const Duration(milliseconds: 500));
              reloadMsgAcction = '-> LISTO ESPERANDO CAMPAÑAS';
            }

          }else{

            if(!campas.first.path.contains(fileS.prefixFldSended)) {

              if(currentFileProcess != campas.first.path) {

                cambiarDeCampaing();
                reloadMsgAcction = '-> ENCONTRADA CAMPAÑA PRIORITARIA';
                List<String> uriP = campas.first.path.split(fileS.sep).toList();
                String findF = uriP.removeLast();
                if(!findF.startsWith(fileS.prefixFldWrk)) {
                  fileS = ScmFile(pathOrigin: campas.first.path);
                  await fileS.prefixWorking(accion: 'put');
                }
                if(!onlyCheck) {
                  await Future.delayed(const Duration(milliseconds: 500));
                  reloadMsgAcction = 'Recargando proceso de envio...';
                }
              }else{
                reloadMsgAcction = '-> CONTINUAMOS... SIN PRIORIDAD';
              }
            }
          }
        }else{
          reloadMsgAcction = '-> NADA QUE PROCESAR';
          await Future.delayed(const Duration(milliseconds: 500));
          reloadMsgAcction = '-> LISTO ESPERANDO CAMPAÑAS';
        }
      }
    }
    if(_isStopAllCrones) {
      startAllCrones();
    }
  }

  /// Guardamos el registro de mensaje enviado en las BDs
  Future<bool> setSendedInDB(ScmEntity scm, {String stt = 'i'}) async {

    final data = {
      'camp': scm.idCamp, 'receiver': scm.idReceiver, 'stt': stt,
      'isLast': scm.nextReceivers.isEmpty ? true : false
    };
    String path = await GetPaths.getUri('set_reg_envio', isLocal: true);
    await MyHttp.post(path, data);
    
    if(!MyHttp.result['abort']) {
      if(!_globals.isLocalConn) {
        path = await GetPaths.getUri('set_reg_envio', isLocal: false);
        await MyHttp.post(path, data);
        if(!MyHttp.result['abort']) {
          return true;
        }
      }else{
        return true;
      }
    }
    return false;
  }

  ///
  List<List<String>> reduceList({
    required List<List<String>> toReduce,
    required int index,
    bool isOtros = false
  }) {

    List<List<String>> result = [];
    int? vIni = 0;
    for (var i = 0; i < toReduce.length; i++) {

      if(i == 0 && toReduce[i][index] != '_') {
        vIni = int.tryParse(toReduce[i][index]);
        vIni = (vIni == null) ? 0 : vIni;
      }

      int? vnew = int.tryParse(toReduce[i][index]);
      if(isOtros) {
        if(toReduce[i].contains('_')) {
          result.add(toReduce[i]);
        }
      }else{
        if(vnew != null && vIni != null) {
          if(vnew <= vIni) {
            if(!toReduce[i].contains('_')) {
              result.add(toReduce[i]);
            }
          }
        }
      }
    }
    return result;
  }

  /// Revisamos el servidor cada...
  /// Si hay algo nuevo se crea el archivo en Stage y se normalizan los datos
  void initCronServidorRemoto({int cada = 10}) {

    try {

      cron['remoto']!.schedule(Schedule.parse('*/$cada * * * * *'), () async {
        _initProcessCheckingRemoto(from: 'arriba');
      });
    } catch (e) {

      if(e.toString().contains('Closed')) {
        cron['remoto'] = Cron();
        cron['remoto']!.schedule(Schedule.parse('*/$cada * * * * *'), () async {
          _initProcessCheckingRemoto(from: 'abajo');
        });
      }
    }
  }

  ///
  void _initProcessCheckingRemoto({String? from}) async {

    if(_blockRevRemota) { return; }
    _blockRevRemota = true;

    var hasAlgo = await _checkingRemoto();
    List<Map<String, dynamic>> camps = [];
    if(hasAlgo) {
      addNewtaskTerminal('[CRON] Bloquo de Busqueda temporal');
      await Future.delayed(const Duration(milliseconds: 1000));
      _blockRevRemota = true;

      bool hasChanged = false;
      lastResult.forEach((key, value) {
        if(value.isNotEmpty) {
          hasChanged = true;
          camps.add({'target': key, 'ids':value});
        }
      });

      if(hasChanged) {

        cron['remoto']!.close();
        addNewtaskTerminal('[CRON] DETENIENDO revisión remota', esp: 500);
        Future.delayed(const Duration(milliseconds: 500));

        addNewtaskTerminal('[TASK] Se encontró una nueva Campaña');
        _isDowload = false;
        for (var i = 0; i < camps.length; i++) {

          if(!_isDowload) {

            addNewtaskTerminal(
              '[TASK] Recabando datos de "${camps[i]['target']}, msgs: ${camps[i]['ids'].join(', ')}"...'
            );
            final result = await _downloadNewsCampas(camps[i]);
            if(result.isNotEmpty) {
              addNewtaskTerminal('[TASK] Creando nuevos archivos en Stage');

              await GetContentFile.putNewFileInStage(result, camps[i]['target']);
              addNewtaskTerminal('[TASK] Listo! desplegando campaña');
              _isDowload = false;
            }else{
              addNewtaskTerminal('[ALERTA] No se recupero datos de Campaña');
            }
          }
        }

        _blockRevRemota = false;
        addNewtaskTerminal('[CRON] RE INICIANDO revisión remota');
        initCronServidorRemoto();
      }
    }else{
      _blockRevRemota = false;
    }
    setnRevRm();
  }

  /// Descarga del contenido del archivo datafix\targets.json donde nos indican
  /// los IDS de los mensajes de la tabla scm_camp que hay que descargar
  /// 
  /// --> Aprovechamos para ver si hay una nueva version del centinela
  Future<bool> _checkingRemoto() async {

    bool isLocal = false;
    if(_globals.isLocalConn) {
      isLocal = true;
    }
    String path = await GetPaths.getUri('has_updates', isLocal: isLocal);
    await MyHttp.get('$path$verCenti/');
    if(!MyHttp.result['abort']) {
      if(MyHttp.result['body'].isNotEmpty) {
        verCenti = MyHttp.result['body']['centinela']['newver'];
        if(!MyHttp.result['body']['centinela']['isSame']) {
          // Hay nueva version del centinela
          //-> Notificar a harbi para que haga su trabajo de descarga
        }

        if(MyHttp.result['body']['scm'].isNotEmpty) {

          bool hasResult = false;
          
          final results = Map<String, dynamic>.from(MyHttp.result['body']['scm']);
          results.forEach((key, value) {
            if(value.isNotEmpty) {
              if(lastResult.containsKey(key)) {
                if(lastResult[key] != value) {
                  lastResult = results;
                  hasResult = true;
                }
              }else{
                lastResult = results;
                hasResult = true;
              }
            }
          });

          return hasResult; 
        }
      }
    }

    return false;
  }

  /// descargamos todas las campañas y las ponemos en archivos diferentes
  Future<List<Map<String, dynamic>>> _downloadNewsCampas(Map<String, dynamic> data) async {

    _isDowload = true;
    bool isLocal = false;
    if(_globals.isLocalConn) {
      isLocal = true;
    }
    String path = await GetPaths.getUri('get_campaingof', isLocal: isLocal);
    await MyHttp.get('$path${data['target']}/');

    if(!MyHttp.result['abort']) {
      return List<Map<String, dynamic>>.from(MyHttp.result['body']);
    }else{
      addNewtaskTerminal('[ERROR] ${MyHttp.result['body']}');
    }
    return [];
  }

  /// Revisamos si hay nuevos mensajes en la carpeta local
  void initCronFolderLocal() {

    int cada = 3;
    try {
      cron['files']!.schedule(Schedule.parse('*/$cada * * * * *'), () async {
        await _checkingFolderLocales();
      });
    } catch (e) {

      if(e.toString().contains('Closed')) {
        cron['files'] = Cron();
        cron['files']!.schedule(Schedule.parse('*/$cada * * * * *'), () async {
          await _checkingFolderLocales();
        });
      }
    }
  }
  
  /// Realizar el chequeo de archivos en las carpetas de tray, await, sended y drash.
  /// 
  /// Solo en la carpeta de tray hace trabajo en las demas solo nos da la cantidad de
  /// archivos existentes.
  Future<void> _checkingFolderLocales() async {

    if(_blockCheckLocal){ return; }
    _blockCheckLocal = true;
    
    enTray = await GetContentFile.getCantContentFilesByFolder(FoldStt.tray);
    if(enTray != _campaingsCola.length) {
      campaingsCola = await GetContentFile.getAllCampaingsWithDataMini();
    }
    if(enTray == 0) {
      if(enProceso.id != 0) {
        enProceso = ProcesoEntity();
        currentFileProcess = '';
        receiverCurrentClean = ScmEntity();
        cleanReceiversCola();
      }
    }

    enAwait = await GetContentFile.getCantContentFilesByFolder(FoldStt.wait);
    sended = await GetContentFile.getCantContentFilesByFolder(FoldStt.sended);
    papelera = await GetContentFile.getCantContentFilesByFolder(FoldStt.drash);

    if(enProceso.id == 0 && enTray > 0) {
      
      String pathProcess = await GetContentFile.putWorkingIfAbsent(folder: FoldStt.tray);
      if(pathProcess.isNotEmpty) {
        if(pathProcess != currentFileProcess) {

          reloadMsgAcction = 'Recargando proceso de envio...';
          currentFileProcess = pathProcess;
          terminalIsMini = true;
          enProceso = await GetContentFile.getFileWorkingEnProceso(pathProcess);
          setMsgCurrent(await GetContentFile.getMsgOfCampaing(enProceso.src['msg']));
          await Future.delayed(const Duration(milliseconds: 2000));
          await _putReceiversEnCola();
        }
      }
    }

    timerL();
    _blockCheckLocal = false;
  }

  /// Colocamos los mensajes de la campaña actual en la cola
  Future<void> _putReceiversEnCola() async {

    final fileS = ScmFile();
    // Recuperar la campaña la cual se esta trabajando...
    var fwr = await GetContentFile.getContentFileWorking(folder: FoldStt.tray);
    
    fileS.fromFileCampaing(fwr);
    fileS.createNameFile();

    List<String> partes = [];
    if(fileS.nameFileSinExt.contains(fileS.suf)) {
      partes = fileS.nameFileSinExt.split(fileS.suf);
    }
    if(partes.isEmpty) {
      if(fileS.nameFileSinExt.contains(fileS.sufM)) {
        partes = fileS.nameFileSinExt.split(fileS.sufM);
      }
    }

    if(partes.isEmpty) {
      terminalIsMini = false;
      addNewtaskTerminal('[ERROR] No se ecnontró: ${fileS.nameFileSinExt}');
      return;
    }

    // De la parte primera del nombre del archivo de la campaña la cual
    // se esta trabajando, buscaremos los archivos de sus receivers.
    String fixed = partes.first;
    partes = fileS.nameFile.split(fileS.sF);

    // Primero entre los archivos de sus receivers buscamos el marcado como main.
    String? fileMain;
    Map<String, dynamic> content = {};
    List<ScmEntity> receiversDeCampaingEnCola = [];

    for (var i = 0; i < enProceso.toSend.length; i++) {

      fileMain = '$fixed${fileS.sufM}${enProceso.toSend[i]}${fileS.sF}${fwr['sufixTimeChilds']}';
      
      content = await GetContentFile.getContentByFileAndFolder(
        fileName: fileMain, folder: FoldStt.wait
      );
      if(content.isNotEmpty) {
        final v = ScmEntity()..fromJson(content);
        receiversDeCampaingEnCola.add(v);
        break;
      }else{
        fileMain = null;
      }
    }
    
    // Si existe un archivo main, adicionamos a la cola todos sus childs
    if(fileMain == null) {
      // que hacer si no encuentra el archivo main
      terminalIsMini = false;
      addNewtaskTerminal('[ERROR] No se encontro el archivo receiver main');
      return;
    }
    
    if(content['nextReceivers'].isNotEmpty) {

      for (var i = 0; i < content['nextReceivers'].length; i++) {

        fileMain = '$fixed${fileS.suf}${content['nextReceivers'][i]}${fileS.sF}${fwr['sufixTimeChilds']}';
        final contentChild = await GetContentFile.getContentByFileAndFolder(
          fileName: fileMain, folder: FoldStt.wait
        );
        if(contentChild.isNotEmpty) {
          final v = ScmEntity()..fromJson(contentChild);
          v.nFile = fileMain;
          receiversDeCampaingEnCola.add(v);
        }
      }
    }

    receiversCola = List<ScmEntity>.from(receiversDeCampaingEnCola);
    receiversDeCampaingEnCola = [];
  }

  /// Revisamos si hay nuevos mensajes en el Stage
  void initCronFolderStage() {

    int cada = 3;

    try {
      cron['stage']!.schedule(Schedule.parse('*/$cada * * * * *'), () async {
        await _checkingFolderStage();
      });
    } catch (e) {

      if(e.toString().contains('Closed')) {
        cron['stage'] = Cron();
        cron['stage']!.schedule(Schedule.parse('*/$cada * * * * *'), () async {
          await _checkingFolderStage();
        });
      }
    }
  }

  /// Realizar el chequeo de archivos.
  Future<void> _checkingFolderStage() async {

    if(_blockCheckStage) { return; }
    _blockCheckStage = true;

    String pathWrk = await GetContentFile.putWorkingIfAbsent(
      folder: FoldStt.stage
    );
    if(pathWrk != _extrayendoReceptoresOf) {
      
      _extrayendoReceptoresOf = pathWrk;
      await GetContentFile.extraerReceptores(_extrayendoReceptoresOf);
      _extrayendoReceptoresOf = '';
    }
    timerSt();
    _blockCheckStage = false;
  }

}

