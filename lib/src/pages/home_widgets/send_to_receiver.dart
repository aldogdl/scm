import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:glass_kit/glass_kit.dart';

import '../../entity/scm_file.dart';
import '../../entity/scm_entity.dart';
import '../../providers/process_provider.dart';
import '../../services/get_content_files.dart';
import '../../services/puppetter/browser_task.dart';
import '../../widgets/texto.dart';
import '../../widgets/tile_contacts.dart';

class SendToReceiver extends StatefulWidget {

  const SendToReceiver({
    Key? key
  }) : super(key: key);

  @override
  State<SendToReceiver> createState() => _SendToReceiverState();
}

class _SendToReceiverState extends State<SendToReceiver> {

  
  final ValueNotifier<double> _progressTasks = ValueNotifier(0);
  final ValueNotifier<double> _progressSended = ValueNotifier(0);
  final ValueNotifier<String> _msgProgreso = ValueNotifier('');
  final ValueNotifier<bool> _prepareNext = ValueNotifier(false);

  late ProcessProvider _proc;
  final _fileS = ScmFile();

  double _progressTotal = 0;
  int timeTestByStep = 500;
  bool _isInit = false;

  /// _skeepToNext indica que ubo un error pero que podemos saltar al siguiente
  /// remitente, en caso de que sea false, el sistema debe continuar con el
  /// mensaje actual o en caso de error detener el sistema.
  bool _skeepToNext = false;
  bool _hasInternet = true;
  bool _isSending = false;
  double _pixPerTask = 0;
  Map<String, dynamic> _simula = {};
  int _indexLastCurcTester = 0;
  List<String> _msgC = [];

  @override
  void initState() {

    _initWidget();
    super.initState();
  }

  @override
  void dispose() {
    _progressTasks.dispose();
    _progressSended.dispose();
    _msgProgreso.dispose();
    _prepareNext.dispose();
    super.dispose();
  }

  /// El prov.receiverCurrent, es hidratado desde el widget ColaPage::_checarArranque
  /// este selecciona el archivo main de la lista encontrada en la carpeta scm_await
  /// 
  /// Esta clase debe ser la encargada de tomar los siguientes receptores indicados
  /// en el archivo main.
  @override
  Widget build(BuildContext context) {

    return Selector<ProcessProvider, ScmEntity>(
      selector: (_, prov) => prov.receiverCurrent,
      builder: (_, msgProc, __) {

        bool isHolder = (msgProc.receiver.id == 0) ? true : false;

        return Container(
          margin: const EdgeInsets.only(
            top: 15, right: 10, bottom: 8, left: 10
          ),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.grey.withOpacity(0.3),
            border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 3,
                offset: Offset(1,1)
              )
            ]
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.withOpacity(0.3),
              border: Border.all(color: const Color.fromARGB(255, 90, 90, 90)),
            ),
            child: Stack(
              children: [
                _body(isHolder, msgProc),
                _finEnvioCurrent()
              ],
            ),
          ),
        );
      }
    );
  }

  ///
  Widget _body(bool isHolder, ScmEntity scm) {

    double alto = 18;

    if(!isHolder && !_isSending) {
      _initProcesoDeEnvio(scm);
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        _tituloOrdenProgress(scm),
        const SizedBox(height: 1),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
          width: _progressTotal,
          height: alto,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(3)
          ),
          child: _barraProgreso(alto),
        ),
        const SizedBox(height: 5),
        if(isHolder)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 11),
            child: Center(
              child: Icon(
                Icons.settings_input_svideo_sharp,
                size: 50, color: Colors.grey
              ),
            ),
          )
        else
          TileContacts(
            title: '-> RECEPTOR EN PROCESO',
            nombre: scm.receiver.nombre,
            subTi: scm.receiver.celular,
            celular: scm.receiver.celular,
            curc: scm.receiver.curc,
            isCurrent: true,
          ),
      ],
    );
  }

  ///
  Widget _finEnvioCurrent() {

    return Positioned(
      top: 0, left: 0, right: 0, bottom: 0,
      child: ValueListenableBuilder<bool>(
        valueListenable: _prepareNext,
        builder: (_, val, child) {
          return (val) ? child! : const SizedBox();
        },
        child: GlassContainer.frostedGlass(
          height: appWindow.size.height * 0.3,
          width: appWindow.size.width + 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Selector<ProcessProvider, String>(
                selector: (_, provi) => provi.reloadMsgAcction,
                builder: (_, msg, __) {

                  if(msg.toLowerCase().contains('continuamos')) {

                    Future.delayed(const Duration(milliseconds: 500), () async {
                      _proc.reloadMsgAcction = '';
                      _prepareNext.value = false;
                      _putNextEnEnvio();
                    });
                  }

                  return Texto(
                    txt: _proc.reloadMsgAcction,
                    txtC: Colors.white.withOpacity(0.7),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  ///
  Widget _tituloOrdenProgress(ScmEntity scm) {

    String tit = 'EN ESPERA...';
    if(_proc.enProceso.id != 0) {
      tit = _proc.enProceso.campaing.titulo;
    }

    return Container(
      width: appWindow.size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: Colors.black,
      child: Center(
        child: Texto(
          txt: tit.toUpperCase(),
          txtC: Colors.white,
        ),
      )
    );
  }

  ///
  Widget _barraProgreso(double alto) {

    return Stack(
      children: [
        Positioned(
          top: 0, left: 0,
          child: ValueListenableBuilder<double>(
            valueListenable: _progressTasks,
            builder: (_, cant, __) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                width: cant,
                height: alto,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 64, 73, 114),
                  borderRadius: BorderRadius.circular(3)
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 0, left: 0,
          child: ValueListenableBuilder<double>(
            valueListenable: _progressSended,
            builder: (_, cant, __) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                width: cant,
                height: alto,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 105, 110, 131),
                  borderRadius: BorderRadius.circular(3)
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: ValueListenableBuilder<String>(
            valueListenable: _msgProgreso,
            builder: (_, msgp, __) {
              return Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Texto(txt: msgp, txtC: Colors.white, sz: 10)
                ],
              );
            },
          ),
        )
      ],
    );
  }

  // -----------------------CONTROLADOR----------------------------

  ///
  Future<void> _initWidget() async {

    if(!_isInit) {
      _isInit = true;
      _progressTotal = appWindow.size.width - 100;
      _pixPerTask = 0;
      _proc = context.read<ProcessProvider>();
    }

    // los task son los pasos que se requieren para enviar msg
    final tasks = BrowserTask.getTasks();
    _pixPerTask = (_progressTotal / tasks.length);
    await _formatearMsg();
  }

  ///
  Future<void> isPaused() async {

    if(_proc.isPause) {
      _isSending = false;
      do {
        await Future.delayed(const Duration(milliseconds: 500), (){
          _proc.termitente = !_proc.termitente;
        });
      } while (_proc.isPause);
    }
  }

  ///
  Future<void> _initProcesoDeEnvio(ScmEntity scm) async {
    
    if(!mounted){ return; }
    await isPaused();
    _isSending = true;
    _simula = {};

    //_simula = {'with': 'ok'};
    // _simula = {
    //   'with': 'err', 'secc': 'bskContac', 'tipo': 1
    // };

    if(_proc.isTest) {
      if(_proc.lstTestings.isEmpty) {
        final testers = await GetContentFile.getCurcsTesting();
        if(testers.isNotEmpty) {
          _proc.lstTestings = List<Map<String, dynamic>>.from(testers['testers']);
        }
      }
      final rnd = Random();
      int indx = -1;
      do {
        indx = rnd.nextInt(_proc.lstTestings.length);
      } while (_indexLastCurcTester == indx);
      _indexLastCurcTester = indx;
      _proc.receiverCurrent.receiver.curc = _proc.lstTestings[indx]['curc'];
      _proc.receiverCurrent.receiver.nombre = _proc.lstTestings[indx]['nombre'];
    }else{
      if(_proc.lstTestings.isNotEmpty) {
        _proc.lstTestings = [];
      }
    }

    String curcTo = scm.receiver.curc;
    if(scm.receiver.cargo == 'addCtac') {
      curcTo = BrowserTask.chatContacts;
    }
    _progressTasks.value = 0;
    _msgProgreso.value = 'Buscando Contacto';

    // Buscamos el contacto.
    if(_simula.isNotEmpty) {

      await _simulaProceso(scm, 'bskContac');

    }else{

      BrowserTask.buscarContacto(txt: curcTo)
        .listen((event) async {
        
        if(event.startsWith('ERROR')) {
          _skeepToNext = true;
          await _registrarError(event);
        }else{

          if(event == 'ok') {
            _skeepToNext = false;
            try {
              _progressTasks.value = _progressTasks.value + _pixPerTask;
            } catch (e) {
              return;
            }
            await BrowserTask.wait(500);
            await _entrarAlChat(scm);
          }
        }
      });
    }
  }

  ///
  Future<void> _entrarAlChat(ScmEntity scm) async {

    if(!mounted){ return; }
    await isPaused();
    bool isGrupo = false;

    String curcTo = scm.receiver.curc;
    if(scm.receiver.cargo == 'addCtac') {
      curcTo = BrowserTask.chatContacts;
      isGrupo = true;
    }
    _msgProgreso.value = 'Entrando al Chat';

    if(_simula.isNotEmpty) {

      await _simulaProceso(scm, 'chatDeCtc');

    }else{

      BrowserTask.entrarAlChat( curcTo, isGrup: isGrupo )
      .listen((event) async {

        if(event.startsWith('ERROR')) {
          await _registrarError(event);
          _skeepToNext = true;
        }else{

          if(event == 'ok') {

            _skeepToNext = false;
            try {
              _progressTasks.value = _progressTasks.value + _pixPerTask;
            } catch (e) {
              return;
            }
            await BrowserTask.wait(500);
            await _escribirMsg(scm);
          }
        }
      });
    }
  }

  ///
  Future<void> _escribirMsg(ScmEntity scm) async {

    if(!mounted){ return; }
    await isPaused();
    _msgProgreso.value = 'Escribiendo mensaje';

    if(_simula.isNotEmpty) {

      await _simulaProceso(scm, 'writeMsg');

    }else{

      BrowserTask.comparaCon = _getListTxtToCompare(
        isContac: (_msgC.isNotEmpty) ? true : false
      );
      List<String> msgSend = (_msgC.isNotEmpty)
        ? _msgC : _proc.getMensajeFormated();

      BrowserTask.escribirMsg(msgSend)
      .listen((event) async {

        if(event.startsWith('ERROR')) {
          _skeepToNext = true;
          await _registrarError(event);
        }else{

          if(event == 'ok') {
            _msgC = [];
            _skeepToNext = false;
            try {
              _progressTasks.value = _progressTasks.value + _pixPerTask;
            } catch (e) {
              return;
            }
            await BrowserTask.wait(500);
            await _enviarMsg(scm);
          }
        }
      });
    }
  }

  /// Este es la ultima tarea requerida para enviar un mensaje
  /// -> Si todo bien: _getNextReceiver
  /// -> Si hay Error: _registrarError
  Future<void> _enviarMsg(ScmEntity scm) async {

    if(!mounted){ return; }
    await isPaused();

    if(_proc.noSend) {
      _msgProgreso.value = 'Mensaje sin Envio';
      await _getNextReceiver(scm);
      return;
    }

    _msgProgreso.value = 'Enviando Mensaje';

    if(_simula.isNotEmpty) {

      await _simulaProceso(scm, 'btnSend');

    }else{

      String event = await BrowserTask.sendMensaje();
      if(event.startsWith('ERROR')) {
        _skeepToNext = true;
        await _registrarError(event);
      }else{

        if(event == 'ok') {
          _skeepToNext = false;
          try {
            _progressTasks.value = _progressTasks.value + _pixPerTask;
          } catch (_) {}
          await BrowserTask.wait(500);
          await _getNextReceiver(scm);
        }
      }
    }
  }

  /// Tomamos una lista de palabras las cuales son utilizadas para
  /// comparar el mensaje escrito final, y ver si este es integro.
  List<String> _getListTxtToCompare({bool isContac = false}) {

    if(isContac) {
      return ['contacto', 'inexistente'];
    }

    List<String> toCompare = [];
    List<String> items = _proc.receiverCurrent.receiver.nombre.toLowerCase().split(' ');
    for (var i = 0; i < items.length; i++) {
      toCompare.add(items[i].trim());
    }
    if(_proc.enProceso.target.containsKey('marca')) {
      items = _proc.enProceso.target['marca']['nombre'].toString().toLowerCase().split(' ');
      for (var i = 0; i < items.length; i++) {
        toCompare.add(items[i].trim());
      }
      items = _proc.enProceso.target['modelo']['nombre'].toString().toLowerCase().split(' ');
      for (var i = 0; i < items.length; i++) {
        toCompare.add(items[i].trim());
      }
    }else{
      for (var i = 0; i < _proc.msgCurrent.length; i++) {
        if(_proc.msgCurrent[i].contains('*')) {
          String tmp = _proc.msgCurrent[i].replaceAll('*', '');
          if(!tmp.contains('http')) {
            items = tmp.toLowerCase().split(' ');
            for (var i = 0; i < items.length; i++) {
              String lett = items[i].trim();
              if(lett.length > 3) {
                if(!lett.startsWith('_')) {
                  if(!lett.contains('.')) {
                    if(toCompare.length < 5){
                      toCompare.add(items[i].trim());
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    toCompare.add('autoparnet');
    return toCompare;
  }

  /// 
  Future<void>  _registrarError(String error) async {

    // Extraemos el tipo de error que se produjo.
    String tipoErr = BrowserTask.getTipoDeError(error);

    if(tipoErr == 'retry') {

      _proc.receiverCurrent.intents = _proc.receiverCurrent.intents+1;
      if(_proc.receiverCurrent.intents > 3) {
        _proc.receiverCurrent.errores.add(error);
        await _enviarToPapelera(_proc.receiverCurrent);
        return;
      }
      _initProcesoDeEnvio(_proc.receiverCurrent);
      return;
    }

    if(tipoErr == 'drash') {
      _proc.receiverCurrent.errores.add(error);
      await _enviarToPapelera(_proc.receiverCurrent);
    }

    if(tipoErr == 'contac') {
      await _enviarToContactos();
      _proc.receiverCurrent.errores.add(error);
      await _initProcesoDeEnvio(_proc.receiverCurrent);
    }

    if(tipoErr == 'stop') {
      await _detenerSistema(error);
    }

    // Avisarle a Harvi que haga una descarga del centinela desde remoto a local.
  }

  ///
  Future<void> _getNextReceiver(ScmEntity scm) async {

    if(!mounted){ return; }

    _msgProgreso.value = '';
    bool next = false;
    if(scm.errores.isEmpty) {
      next = true;
    }else{
      if(_proc.receiverCurrent.receiver.cargo == 'addCtac') {
        await _enviarToPapelera(scm);
        _skeepToNext = false;
        next = true;
      }else{
        await _finalizarEnvioActual(scm);
      }
    }

    if(next) {
      if(!_skeepToNext) {
        _prepareNext.value = true;
        _proc.reloadMsgAcction = '-> REGISTRANDO ENVIO';
        bool isFine = await _proc.setSendedInDB(scm);
        if(isFine) {
          _proc.reloadMsgAcction = '-> COLOCANDO EN ENVIADOS';
          await _cambiarDeFolder(scm.nFile, FoldStt.sended);
          _skeepToNextReceiver(scm);
        }else{
          _proc.reloadMsgAcction = '-> ERROR, NO SE GUARDÓ EN DB.';
        }
      }
    }
  }

  ///
  void _skeepToNextReceiver(ScmEntity scm) async {

    final nextFile = _buildNextFile(scm);
    if(nextFile.isNotEmpty) {

      _proc.reloadMsgAcction = '-> MARCANDO ARCHIVO PRINCIPAL';
      final content = await GetContentFile.getContentByFileAndFolder(
        fileName: nextFile, folder: FoldStt.wait
      );
      if(content.isNotEmpty) {
        await GetContentFile.changeMsgFromChildToMain(filename: nextFile);
      }
      await _updateDataMain(scm);
      _proc.reloadMsgAcction = '-> REVISANDO PRIORIDADES.';
      await _proc.buscamosCampaniaPrioritaria(onlyCheck: true);
    }else{
      _proc.reloadMsgAcction = '-> FINALIZANDO ENVIO';
      await _updateDataMain(scm);
      await _finalizarEnvioActual(scm);
    }
  }

  ///
  Future<void> _putNextEnEnvio() async {

    List<ScmEntity> rec = List<ScmEntity>.from(_proc.receiversCola);
    int ind = rec.indexWhere(
      (element) => element.idReceiver == _proc.receiverCurrent.idReceiver
    );
    if(ind != -1) {
      rec.removeAt(ind);
      _proc.receiversCola = rec;
      if(_proc.receiversCola.isNotEmpty) {
        _proc.receiverCurrent = ScmEntity();
        Future.delayed(const Duration(milliseconds: 500), (){
          _isSending = false;
          _proc.receiverCurrent = _proc.receiversCola.first;
        });
      }
    }
  }

  ///
  Future<void> _updateDataMain(ScmEntity scm) async {

    _proc.enProceso.toSend.remove(scm.idReceiver);
    _proc.enProceso.noSend.remove(scm.idReceiver);
    _proc.enProceso.sended.add(scm.idReceiver);

    await GetContentFile.updateSendersInFileData(
      {
        'toSend': _proc.enProceso.toSend,
        'sended': _proc.enProceso.sended,
        'noSend': _proc.enProceso.noSend
      },
      scm.data
    );
  }

  /// Calculamos el nombre del archivo siguiente 
  /// desde el mensaje actual.
  String _buildNextFile(ScmEntity scm) {

    if(scm.nextReceivers.isEmpty){ return ''; }
    final fileS = ScmFile();
    // cambiamos el main por el child
    String nextF = scm.nFile.replaceFirst(fileS.sufM, fileS.suf);
    final from = '${fileS.sF}${scm.idReceiver}${fileS.sF}';
    final to = '${fileS.sF}${scm.nextReceivers.first}${fileS.sF}';
    nextF = nextF.replaceFirst(from, to);
    return nextF;
  }

  ///
  Future<void> _enviarToPapelera(ScmEntity scm) async {

    _skeepToNext = true;
    _prepareNext.value = true;
    _proc.reloadMsgAcction = '-> REGISTRANDO ERROR';
    bool echo = await GetContentFile.saveData(scm.nFile, FoldStt.wait, scm.toJson());
    if(!echo) {
      final fileMain = scm.nFile.replaceFirst(_fileS.suf, _fileS.sufM);
      echo = await GetContentFile.saveData(fileMain, FoldStt.wait, scm.toJson());
    }
    bool isFine = await _proc.setSendedInDB(scm, stt: 'p');
    if(isFine) {
      await _cambiarDeFolder(scm.nFile, FoldStt.drash);
      _skeepToNextReceiver(scm);
    }else{
      _proc.reloadMsgAcction = '-> ERROR, NO SE GUARDÓ EN DB.';
    }
  }

  ///
  Future<void> _enviarToContactos() async {

    _msgC = await GetContentFile.getMsgOfCampaing('add_contact.txt');

    for (var i = 0; i < _msgC.length; i++) {
      if(_msgC[i].contains('_nombre_')) {
        _msgC[i] = _msgC[i].replaceFirst('_nombre_', _proc.receiverCurrent.receiver.nombre);
      }
      if(_msgC[i].contains('_empresa_')) {
        _msgC[i] = _msgC[i].replaceFirst('_empresa_', _proc.receiverCurrent.receiver.empresa);
      }
      if(_msgC[i].contains('_cel_')) {
        _msgC[i] = _msgC[i].replaceFirst('_cel_', _proc.receiverCurrent.receiver.celular);
      }
      if(_msgC[i].contains('_curc_')) {
        _msgC[i] = _msgC[i].replaceFirst('_curc_', _proc.receiverCurrent.receiver.curc);
      }
    }

    _proc.receiverCurrent.receiver.cargo = 'addCtac';
  }

  ///
  Future<void> _formatearMsg() async {

    switch (_proc.enProceso.src['class']) {
      case 'Ordenes':
        await _formatMsgOfOrden();
        break;
      default:
    }
  }

  ///
  Future<void> _formatMsgOfOrden() async {

    List<String> partes = _proc.msgCurrent;
    for (var i = 0; i < partes.length; i++) {
      if(partes[i].contains('_idOrden_')){
        partes[i] = partes[i].replaceAll('_idOrden_', '${_proc.enProceso.src['id']}');
      }

      if(partes[i].contains('_auto_')){
        String auto = _proc.enProceso.target['modelo']['nombre'];
        auto = '$auto ${_proc.enProceso.target['anio']}';
        auto = '$auto de ${_proc.enProceso.target['marca']['nombre']}';
        partes[i] = partes[i].replaceAll('_auto_', auto);
      }
    }
    _proc.setMsgCurrent(partes);
  }

  ///
  Future<void> _detenerSistema(String msg) async {

    _proc.isPause = true;
    _proc.terminalIsMini = false;
    _proc.addNewtaskTerminal('[ALERT] $msg');
  }

  ///
  Future<void> _cambiarDeFolder(
    String filename, FoldStt to
  ) async {
    
    bool changed = await GetContentFile.changeDeFolder(
      filename: filename, from: FoldStt.wait, to: to
    );
    if(!changed) {
      // Intentar con main
      final fileMain = filename.replaceFirst(_fileS.suf, _fileS.sufM);
      changed = await GetContentFile.changeDeFolder(
        filename: fileMain, from: FoldStt.wait, to: to
      );

      if(!changed) {
        _proc.terminalIsMini = false;
        _proc.addNewtaskTerminal('[ERROR] No se encontró $filename');
      }
    }
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  /// Al limpiar las variables el cron detecta que no hay nada en proceso y
  /// toma el siguiente mensaje de la cola en caso de existir y comienza un
  /// nuevo envio.
  Future<void>  _finalizarEnvioActual(ScmEntity scm) async {

    //  Marcar el archivo principal de la data del msg como sended_
    await GetContentFile.putFileDataWorkingAsSended(scm);
    _proc.cambiarDeCampaing();
    await _proc.buscamosCampaniaPrioritaria(onlyCheck: true);
    // if(mounted) {
    //   _proc.reloadMsgAcction = '-> LISTO Y EN ESPERA...';
    //   Routemaster.of(context).pop();
    // }
  }

  ///
  Future<void> _simulaProceso(ScmEntity scm, String proceso) async {

    await BrowserTask.wait(timeTestByStep);

    if(_simula['with'] == 'ok') {

      _skeepToNext = false;
      _progressTasks.value = _progressTasks.value + _pixPerTask;
      
      switch (proceso) {
        case 'bskContac':
          await _entrarAlChat(scm);
          break;
        case 'chatDeCtc':
          await _escribirMsg(scm);
          break;
        case 'writeMsg':
          await _enviarMsg(scm);
          break;
        case 'btnSend':
          await _getNextReceiver(scm);
          break;
        default:
      }
 
    }else{

      await _registrarError(
        BrowserTask.lstErrs[_simula['secc']][_simula['tipo']]
      );
    }
  }
}