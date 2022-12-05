import 'dart:io';
import 'dart:convert';
import 'dart:math' show Random;

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:cron/cron.dart';

import '../config/sng_manager.dart';
import '../entity/proceso_entity.dart';
import '../entity/scm_entity.dart';
import '../services/get_content_files.dart';
import '../services/scm/scm_paths.dart';
import '../providers/terminal_provider.dart';
import '../vars/globals.dart';

class ProcessProvider extends ChangeNotifier {

  final _globals = getSngOf<Globals>();
  String get verScm => _globals.ver;
  
  /// Estas variables son para no tocar la variable original del
  /// recerverCurrent y utilizar estas para enviar los mensajes.
  String curcProcess = '';
  String nombreProcess = '';

  ///
  bool _isPause = true;
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
  
  /// Utilizado para saber si el browser y la pagina de Whats
  /// ya fueron checadas y que estan funcionando. 1000 es ok
  int _systemIsOk  = 0;
  int get systemIsOk => _systemIsOk;
  set systemIsOk(int isT) {
    _systemIsOk = isT;
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
  void setTimer(int inc, {bool reset = false}) {
    if(reset) {
      _timer = 0;
    }else{
      _timer = _timer + inc;
      notifyListeners();
    }
  }
  void resetTimer() => setTimer(1, reset: true);

  /// Usado para refrescar la lista de campañas
  int _refreshTray = 0;
  int get refreshTray => _refreshTray;
  set refreshTray(int i) {
    _refreshTray = i;
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

  int cadaL = 3;

  /// El path absoluto al archivo de la campaña en proceso
  String currentFileProcess = '';
  /// Esta es la variable llave, la que hace que funcione todo.
  /// El nombre del archivo del receiver que se esta enviando
  String currentFileReceiver = '';

  /// [r] El contenedor de la data completa de la campaña que se esta
  /// procesando actualmente.
  ProcesoEntity _enProceso = ProcesoEntity();
  ProcesoEntity get enProceso => _enProceso;
  set enProceso(ProcesoEntity proc) {
    _enProceso = proc;
    notifyListeners();
  }
  
  /// Es usado para refrescar el viewer del receiver
  int _receiverViewer = 0;
  int get receiverViewer => _receiverViewer;
  set receiverViewer(int receiver) {
    _receiverViewer = receiver;
    notifyListeners();
  }
  ScmEntity? _receiverCurrent;
  ScmEntity? get receiverCurrent => _receiverCurrent;
  set receiverCurrent(ScmEntity? receiver) {
    _receiverCurrent = receiver;
    notifyListeners();
  }
  void receiverCurrentClean() {
    _receiverCurrent = null;
  }

  /// Los curs acumulados que no existen en la lista de
  /// contactos o que han sido como marcados para no
  /// enviar mensaje.
  List<String> _curcsNoSend = [];
  List<String> get curcsNoSend => _curcsNoSend;
  void setcurcsNoSend(List<String> lst) {
    _curcsNoSend = lst;
  }

  /// [r] El mensaje actual de la campaña en proceso
  List<String> _msgCurrent = [];
  List<String> get msgCurrent => _msgCurrent;
  void setMsgCurrent(List<String> msg) {
    _msgCurrent = msg;
  }

  bool _isStopCronFiles = true;
  bool get isStopCronFiles => _isStopCronFiles;
  set isStopCronFiles(bool isT){
    _isStopCronFiles = isT;
    notifyListeners();
  }

  /// Usado para bloquear partes del funcionamiento de esta
  /// clase, para que no se repitan cuando flutter repinta.
  bool _isProcessWorking = false;
  bool get isProcessWorking => _isProcessWorking;
  set isProcessWorking(bool isT){
    _isProcessWorking = isT;
    notifyListeners();
  }

  /// Usado para saber en que proceso y view me quede al
  /// pausar o hacer refresh.
  Map<int, List<String>> lastProcess = {};

  /// Un indicador de que se presionó el btn de refresh usado para regresar
  /// siertas variables a su valor original y continuar con el proceso de chequeo
  bool isRefresh = false;

  //--------------------------- FUNCTIONS ----------------------------


  /// Despues de que el sistema este en funcionamiento
  /// arrancamos el cron para empezar a buscar en las carpetas.
  Future<bool> iniciarMonitoreo(TerminalProvider console) async {

    if(!isStopCronFiles){ return true; }

    Future.microtask(() {
      console.taskTerminal = [];
      console.addWar('[$cadaL Seg.] Calentando MOTORES.');
    });

    Future.delayed(Duration(seconds: cadaL), () {
      console.taskTerminal = [];
      initCronFolderLocal();
      console.addWar('[Ignisión] MOTORES ENCENDIDOS.');
      if(systemIsOk >= 1000 && isRefresh) {
        isRefresh = false;
        isProcessWorking = false;
        isStopCronFiles = false;
      }
    });
    return true;
  }

  /// Solamente Cambiamos de receptor sin cambiar de campaña o si
  /// no hay mas, terminamos el proceso y tomamos la sig. Camp.
  Future<bool> getNextReceiver(TerminalProvider? console) async {
    
    if(console != null) {
      console.taskTerminal.clear();
      console.addOk('Tomando nuevo Receptor.');
    }
    isProcessWorking = false;
    bool res = await _hidratarReceiver(console);
    if(!res) {
      refreshTray = refreshTray + 1;
      receiverViewer = receiverViewer + 1;
    }
    return res;
  }

  /// Aqui llegamos cada ves que todos los receivers de la
  /// campaña que actualmente se esta procesando terminan.
  Future<void> _fetchCampToProcesar() async {

    // Si no hay nada en la carpeta de TRAY retornamos
    if(enTray == 0) { _refreshTray = -1; return; }

    if(currentFileProcess.isNotEmpty) {
      cleanCampaingCurrent();
    }
    currentFileProcess = await GetContentFile.searchPriority(
      GetContentFile.getLstFilesByFolder(FoldStt.tray)
    );

    if(currentFileProcess.isNotEmpty) {
      await _hidratarProceso();
    }else{
      _refreshTray = (_refreshTray == -1) ? 0 : -1;
    }
    return;
  }

  /// Colocamos en memoria todos los datos relacionados a
  /// la campaña que se va a preocesar.
  Future<void> _hidratarProceso() async {

    final fileCamp = File(currentFileProcess);
    if(fileCamp.existsSync()) {

      _enProceso = ProcesoEntity()..fromJson(
        json.decode( fileCamp.readAsStringSync() )
      );
      
      // Metricas de la nueva campaña
      GetContentFile.setMetrixInit(_enProceso);

      final res = await _hidratarReceiver(null);
      if(res) {
        _msgCurrent = await GetContentFile.getMsgOfCampaing(
          _enProceso.msgTxt, _enProceso.data
        );
        refreshTray = refreshTray + 1;
      }
    }
  }

  /// En el metodo lib_fin_process.dart se debieron de
  /// haber echo los procedimientos necesario para terminar
  /// el proceso del envio del anterior receptor, al llegar
  /// aqui, es solo para tomar el primero de la lista y continuar.
  Future<bool> _hidratarReceiver(TerminalProvider? console) async {

    if(isProcessWorking){ return false; }

    isProcessWorking = true;
    await Future.delayed(const Duration(milliseconds: 250));

    final noSend = _enProceso.noSend;

    if(noSend.isEmpty) {
      if(console != null) {
        console.taskTerminal.clear();
        console.addWar('FINALIZANDO Campaña Actual.');
      }
      
      final tiempo = await GetContentFile.updateFilesFinSendCamp(
        _enProceso, currentFileProcess
      );
      if(console != null) { console.addOk(tiempo); }
      currentFileReceiver = '';
      isProcessWorking = false;
      refreshTray = 0;
      return false;
    }

    if(noSend.first != currentFileReceiver) {

      currentFileReceiver = noSend.first;
      final rece = await GetContentFile.getContentByPath(
        fileName: currentFileReceiver,
        folder: _enProceso.pathReceivers
      );

      if(rece.isEmpty) {
        if(console != null) {
          console.addWar(currentFileReceiver);
          console.addWar('Receptor no encontrado Archivo:');
        }
        _enProceso.noSend.removeAt(0);
        isProcessWorking = false;
        receiverCurrent = null;
        getNextReceiver(console);
        return false;
      }

      _receiverCurrent = ScmEntity()..fromProvider(rece);
      _receiverCurrent!.fIni = DateTime.now().toIso8601String();

      // Verificamos que el receiver no este en la lista de
      // no procesar, si existe lo eliminamos y buscamos el next.
      if(curcsNoSend.contains(_receiverCurrent!.curc)) {
        _enProceso.noSend.removeAt(0);
        isProcessWorking = false;
        receiverCurrent = null;
        getNextReceiver(console);
        return false;
      }

      // Editamos la metrix.
      GetContentFile.setMetrixMiddle(_enProceso, _receiverCurrent!.idReceiver);
      await _setCurcGlobal();
      receiverViewer = receiverViewer+1;
      return true; 
    }

    // Algo raro, esto quiere decir, que no se eliminó de la lista
    // poner en una variable de warning.
    if(console != null) {
      console.taskTerminal.clear();
      console.addWar('[ALERTA] intentarlo nuevamente.');
      console.addWar('[ALERTA] refresca el sistema para');
      console.addWar('[ALERTA] quitó de la lista noSend');
      console.addWar('[ALERTA] El ultimo receptor no se');
    }
    isProcessWorking = false;
    return false;
  }

  /// En la carpeta de [scm_werr] iran los archivos de los receivers
  /// organizados por orden e id campaña.
  /// En la carpeta de [scm_drash] ira el archivo principal de la campaña
  /// al finalizar el proceso en caso de haber errores.
  Future<void> updateFilesFinSendReceiver(TerminalProvider? console) async {

    if(console != null) {
      console.addOk('Terminando Envio del Receptor.');
    }

    final pathToMove = _getPathToMove();
    GetContentFile.createFolderIfAbsent(pathToMove);

    // Procesamos los datos de EnProceso
    // Movemos el filename del receiver a su respectivo campo.
    // y actualizamos las metricas a su ves hidratamos la variable
    // de errores acumulados.
    String passTo = await _changeFileNameOtheCampo(pathToMove);

    // Procesamos el archivo del receptor.
    receiverCurrent!.fFin = DateTime.now().toIso8601String();
    final file = File('${enProceso.pathReceivers}$currentFileReceiver');
    file.writeAsStringSync(json.encode(receiverCurrent!.toJson()));

    String moveTo = '$pathToMove$currentFileReceiver';
    if(passTo == 'sended') {
      moveTo = '$pathToMove${receiverCurrent!.idReceiver}.json';
    }
    // Pasamos el archivo receiver a sus respectiva carpeta
    file.renameSync(moveTo);
    receiverCurrent = null;
    // Checar si ya no hay mas mensajes en el folder de Await
    // en caso de estar vacio eliminamos todos los sub folders.
    final dirR = Directory(_enProceso.pathReceivers).listSync().toList();
    if(dirR.isEmpty) {
      final fold = GetContentFile.getAbsolutePathFolder(FoldStt.wait);
      Directory('$fold${_enProceso.src['id']}').deleteSync(recursive: true);
    }
  }

  /// A donde vamos a pasar el archivo del receiver al finalizar
  /// el envio papelera o al folder del expediente.
  String _getPathToMove() {

    String s = GetContentFile.getSep;
    String folder = '';
    // Revisar si no cuenta con errores acumulados
    if(receiverCurrent!.errores.isNotEmpty) {
      // Si existen errores, pasamos el archivo a werr.
      folder = GetContentFile.getAbsolutePathFolder(FoldStt.werr);
      folder = '$folder${enProceso.data['id']}$s${enProceso.id}$s';
    }else{
      // Si no hay errores, lo pasamos al expediente.
      folder = '${enProceso.expediente}${enProceso.id}$s${enProceso.freceivers}$s';
    }

    return folder;
  }

  ///
  Future<void> _setCurcGlobal() async {

    if(_globals.env == 'dev') {
      isTest = true;
      noSendMsg = true;
    }
    
    if(isTest) {

      if(lstTestings.isEmpty) {
        final testers = await GetContentFile.getCurcsTesting();
        if(testers.isNotEmpty) {
          lstTestings = List<Map<String, dynamic>>.from(testers['testers']);
        }
      }
    
      int indx = -1;
      if(lstTestings.length > 1) {
        final rnd = Random();
        do {
          indx = rnd.nextInt(lstTestings.length);
        } while (indexLastCurcTester == indx);
      }else{
        indx = 0;
      }
    
      indexLastCurcTester = indx;
      curcProcess = lstTestings[indx]['curc'];
      nombreProcess = lstTestings[indx]['nombre'];

    }else{

      if(lstTestings.isNotEmpty) {
        lstTestings = [];
      }
      isTest = false;
      indexLastCurcTester = -1;
      if(_receiverCurrent != null) {
        curcProcess = _receiverCurrent!.curc;
        nombreProcess = _receiverCurrent!.nombre;
      }
    }
  }

  /// Revisamos si hay nuevos mensajes en la carpeta local
  Future<void> initCronFolderLocal() async {

    try {
      cron.schedule(Schedule.parse('*/$cadaL * * * * *'), () async {
        await checkingFolderLocales();
      });
      isStopCronFiles = false;
    } catch (e) {

      if(e.toString().contains('Closed')) {
        cron = Cron();
        initCronFolderLocal();
      }
    }
  }

  ///
  Future<String> _changeFileNameOtheCampo(String pathToMove) async {

    String passTo = 'sended';
    
    _enProceso.noSend.remove(currentFileReceiver);
    if(receiverCurrent!.errores.isNotEmpty) {
      passTo = 'drash';
      // Movemos el namefile receiver de no send a drahs
      if(!_enProceso.drash.contains(currentFileReceiver)) {
        _enProceso.drash.add(currentFileReceiver);
      }
    }else{
      if(!_enProceso.sended.contains(currentFileReceiver)) {
        _enProceso.sended.add(currentFileReceiver);
      }
    }

    await GetContentFile.updateMetrixReceiver(enProceso, passTo, receiverCurrent!.idReceiver);
    GetContentFile.updateFileWorking(currentFileProcess, _enProceso.toJson());
    return passTo;
  }

  /// Realizar el chequeo de archivos en las carpetas de tray, await, sended y drash.  
  /// Solo en la carpeta de tray hace trabajo en las demas solo nos da la cantidad de
  /// archivos existentes.
  Future<void> checkingFolderLocales() async {
    
    var cat  = await GetContentFile.getCantContentFilesByFolder(FoldStt.drash);
    if(cat != papelera) { papelera = cat; }

    cat  = await GetContentFile.getCantContentFilesByFolder(FoldStt.sended);
    if(cat != sended) { sended = cat; }

    cat = await GetContentFile.getCantContentFilesByFolder(FoldStt.tray);
    if(cat != enTray) { enTray = (cat == 0) ? -1 : cat; }

    if(enTray > 0) {
      cat = await GetContentFile.getCantContentFilesByFolder(FoldStt.wait);
      if(cat != enAwait) { enAwait = cat; }
    }else{
      enAwait = 0;
    }

    if(currentFileReceiver.isEmpty && enTray > 0) {
      if(!isStopCronFiles && !isProcessWorking) {
        currentFileReceiver = 'init';
        await _fetchCampToProcesar();
      }
    }else{

      if(currentFileReceiver.isEmpty && enTray <= 0) {
        if(!isStopCronFiles && !isProcessWorking) {
          if(enProceso.id != 0) {
            cleanCampaingCurrent();
          }
        }
        if(!isStopCronFiles) {
          await _checkIfExistFilesInDrash();
        }
        // TODO si no hay en papelera, hacer un recording.
      }
    }
    setTimer(1);
  }

  ///
  void cleanProcess() {
    curcProcess = '';
    nombreProcess = '';
    _isPause = false;
  }

  /// Limpiamos las variables correspondientes a la campaña actual
  void cleanCampaingCurrent() {

    _tituloColaBarr = '...';
    _msgCurrent= [];
    _enProceso = ProcesoEntity();
    _receiverCurrent = null;
    currentFileProcess = '';
    currentFileReceiver = '';
    refreshTray = -1;
    cleanProcess();
  }

  /// Usado solo para cerrar sesion
  Future<void> cerrarSesionProcess() async {

    cron.close();
    _timer = 0;
    _refreshTray = 0;
    _isStopCronFiles = true;
    isProcessWorking = false;
    _isPause = false;
    _isTest = false;
    _systemIsOk = 0;
    _enAwait = 0;
    _sended = 0;
    _papelera = 0;
  }

  ///
  Future<void> _checkIfExistFilesInDrash() async {

    final campInDrash  = GetContentFile.getLstFilesByFolder(FoldStt.drash);
    if(campInDrash.isNotEmpty) {

      isStopCronFiles = true;
      final s = GetContentFile.getSep;
      for (var i = 0; i < campInDrash.length; i++) {

        final isRecovery = await GetContentFile.tratarErrores(campInDrash[i].path);
        if(isRecovery) {

          final camp = await GetContentFile.getMsgToMap(campInDrash[i].path);
          final fld = Directory(camp['path_receivers']);
          if(fld.existsSync()) {
            List<String> filesRecovery = [];
            fld.listSync().toList().map((e) {
              filesRecovery.add(e.path.split(s).last);
            }).toList();

            if(filesRecovery.isNotEmpty) {

              camp['noSend'] = filesRecovery;
              camp['drash']  = [];
              // Al finalizar el ciclo de los receiver con error pasamos el
              // archivo de la camp nuevamente a tray o a hist.
              final passFld = (isRecovery) ? FoldStt.tray : FoldStt.hist;
              final txtFld = GetContentFile.getAbsolutePathFolder(passFld);
              // Actualizamos el archivo antes de enviarlos
              File(campInDrash[i].path).writeAsStringSync(json.encode(camp));
              campInDrash[i].renameSync('$txtFld${camp['filename']}');
            }
          }
        }
      }

      isStopCronFiles = false;
      isProcessWorking = false;
    }
  }

}

