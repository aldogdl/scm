import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../../entity/scm_entity.dart';
import '../../providers/process_provider.dart';
import '../../repository/to_server.dart';
import '../../services/get_content_files.dart';
import '../../services/puppetter/browser_task.dart';
import '../../services/scm/scm_paths.dart';
import '../../widgets/my_tool_tip.dart';
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
  final ValueNotifier<double> _progressFinished = ValueNotifier(0);
  final ValueNotifier<String> _msgProgreso = ValueNotifier('');

  late ProcessProvider _proc;
  double _progressTotal = 0;
  int timeTestByStep = 1500;
  bool _isInit = false;

  double _pixPerTask = 0;
  double _pixPerTaskFinish = 0;
  Map<String, dynamic> _simula = {};
  int _indexLastCurcTester = 0;
  // Colocamos el msg utilizado para enviarlo al chat de Contactos interno
  List<String> _msgC = [];
  int _idRcurrent = 0;

  @override
  void initState() {
    _initWidget();
    super.initState();
  }

  @override
  void dispose() {
    _progressTasks.dispose();
    _progressFinished.dispose();
    _msgProgreso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

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
        child: MyToolTip(
          msg: 'Receptor en Proceso',
          child: Selector<ProcessProvider, ScmEntity>(
            selector: (_, prov) => prov.receiverCurrent,
            builder: (_, nr, child) {

              if(_idRcurrent != nr.idReceiver) {
                _idRcurrent = nr.idReceiver;
                Future.delayed(const Duration(milliseconds: 200), (){
                  if(mounted) {
                    _msgProgreso.value = 'Iniciando...';
                    Future.delayed(const Duration(milliseconds: 400), (){
                      _initProcesoDeEnvio();
                    });
                  }
                });
              }
              return _body(child!);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 11),
              child: Center(
                child: Icon(
                  Icons.settings_input_svideo_sharp,
                  size: 50, color: Colors.grey
                ),
              ),
            ),
          )
        ),
      ),
    );
  }

  ///
  Widget _body(Widget child) {

    double alto = 18;

    return Column(
      children: [
        const SizedBox(height: 8),
        _tituloOrdenProgress(),
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
        const SizedBox(height: 2),
        if(_proc.receiverCurrent.idReceiver == 0)
          child
        else
          TileContacts(
            title: '-> ${_proc.receiverCurrent.receiver.empresa}',
            nombre: _proc.receiverCurrent.nombre,
            subTi: _proc.receiverCurrent.receiver.celular,
            celular: _proc.receiverCurrent.receiver.celular,
            curc: _proc.receiverCurrent.curc,
            isCurrent: true,
          ),
        const SizedBox(height: 3),
      ],
    );
  }

  ///
  Widget _tituloOrdenProgress() {

    String tit = 'En espera...';
    if(_proc.enProceso.id != 0) {
      tit = _proc.enProceso.campaing.titulo;
    }

    return Container(
      width: appWindow.size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: Colors.black,
      child: Center(
        child: Texto(
          txt: '[C.${_proc.enProceso.id}] ${tit.toUpperCase()}',
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
            valueListenable: _progressFinished,
            builder: (_, cant, __) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                width: cant,
                height: alto,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 38, 102, 44),
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
      _pixPerTaskFinish = 0;
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
      do {
        await Future.delayed(const Duration(milliseconds: 500), (){
          _proc.termitente = !_proc.termitente;
        });
      } while (_proc.isPause);
    }
  }

  ///
  Future<void> _refreshPage() async {

    final nav = Navigator.of(context);
    if(nav.canPop()) { nav.pop(); }
  }

  ///
  Future<void> _initProcesoDeEnvio() async {
    
    if(_idRcurrent == 0) {
      if(mounted) {
        _progressTasks.value = 0;
        _progressFinished.value = 0;
        _msgProgreso.value = 'En espera...';
      }
      return;
    }

    final scm = _proc.receiverCurrent;
    if(!mounted){ return; }
    await isPaused();
    if(_proc.isRefresh) {
      _refreshPage();
      return;
    }
    _simula = {};

    // _simula = {'with': 'ok'};
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
      scm.curc = _proc.lstTestings[indx]['curc'];
      scm.nombre = _proc.lstTestings[indx]['nombre'];
    }else{
      if(_proc.lstTestings.isNotEmpty) {
        _proc.lstTestings = [];
      }
    }

    String curcTo = scm.curc;
    if(scm.receiver.cargo == 'addCtac') {
      curcTo = BrowserTask.chatContacts;
    }
    _progressTasks.value = 0;
    _progressFinished.value = 0;

    // Buscamos el contacto.
    if(_simula.isNotEmpty) {

      _msgProgreso.value = 'Buscando Contacto';
      await _simulaProceso('bskContac');

    }else{

      _msgProgreso.value = 'Buscando Contacto';
      BrowserTask.buscarContacto(txt: curcTo).listen((event) async {
        
        if(event.startsWith('ERROR')) {
          await _registrarError(event);
        }else{

          if(event == 'ok') {
            try {
              _progressTasks.value = _progressTasks.value + _pixPerTask;
            } catch (e) {
              return;
            }
            await BrowserTask.wait(500);
            await _entrarAlChat();
          }
        }
      });
    }
  }

  ///
  Future<void> _entrarAlChat() async {

    if(!mounted){ return; }
    await isPaused();
    if(_proc.isRefresh) {
      _refreshPage();
      return;
    }
    bool isGrupo = false;

    String curcTo = _proc.receiverCurrent.curc;
    if(_proc.receiverCurrent.receiver.cargo == 'addCtac') {
      curcTo = BrowserTask.chatContacts;
      isGrupo = true;
    }
    
    _msgProgreso.value = 'Entrando al Chat';
    if(_simula.isNotEmpty) {

      await _simulaProceso('chatDeCtc');
    }else{

      BrowserTask.entrarAlChat(curcTo, isGrup: isGrupo)
      .listen((event) async {

        if(event.startsWith('ERROR')) {
          await _registrarError(event);
        }else{

          if(event == 'ok') {

            try {
              _progressTasks.value = _progressTasks.value + _pixPerTask;
            } catch (e) {
              return;
            }
            await BrowserTask.wait(500);
            await _escribirMsg();
          }
        }
      });
    }
  }

  ///
  Future<void> _escribirMsg() async {

    if(!mounted){ return; }
    await isPaused();
    if(_proc.isRefresh) {
      _refreshPage();
      return;
    }
    _msgProgreso.value = 'Escribiendo mensaje';

    if(_simula.isNotEmpty) {

      await _simulaProceso('writeMsg');

    }else{

      BrowserTask.comparaCon = _getListTxtToCompare(
        isContac: (_msgC.isNotEmpty) ? true : false
      );

      List<String> msgSend = (_msgC.isNotEmpty)
        ? _msgC : _getMsgOfReceiver();

      BrowserTask.escribirMsg(msgSend).listen((event) async {

        if(event.startsWith('ERROR')) {
          await _registrarError(event);
        }else{

          if(event == 'ok') {
            _msgC = [];
            try {
              _progressTasks.value = _progressTasks.value + _pixPerTask;
            } catch (e) {
              return;
            }
            BrowserTask.comparaCon = [];
            await BrowserTask.wait(500);
            await _enviarMsg();
          }
        }
      });
    }
  }

  /// Este es la ultima tarea requerida para enviar un mensaje
  /// -> Si todo bien: _getNextReceiver
  /// -> Si hay Error: _registrarError
  Future<void> _enviarMsg() async {

    if(!mounted){ return; }
    await isPaused();
    if(_proc.isRefresh) {
      _refreshPage();
      return;
    }
    if(_proc.noSend) {
      _msgProgreso.value = 'Mensaje sin Envio';
      await _getNextReceiver();
      return;
    }

    _msgProgreso.value = 'Enviando Mensaje';

    if(_simula.isNotEmpty) {

      await _simulaProceso('btnSend');

    }else{

      String event = await BrowserTask.sendMensaje();
      if(event.startsWith('ERROR')) {
        await _registrarError(event);
      }else{

        if(event == 'ok') {
          try {
            _progressTasks.value = _progressTasks.value + _pixPerTask;
          } catch (_) {}
          await BrowserTask.wait(500);
          await _getNextReceiver();
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
    List<String> items = _proc.receiverCurrent.nombre.toLowerCase().split(' ');
    for (var i = 0; i < items.length; i++) {
      toCompare.add(items[i].trim());
    }
    if(_proc.enProceso.data.containsKey('marca')) {
      items = _proc.enProceso.data['marca']['nombre'].toString().toLowerCase().split(' ');
      for (var i = 0; i < items.length; i++) {
        toCompare.add(items[i].trim());
      }
      items = _proc.enProceso.data['modelo']['nombre'].toString().toLowerCase().split(' ');
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
  Future<void> _registrarError(String error) async {

    // Extraemos el tipo de error que se produjo.
    String tipoErr = BrowserTask.getTipoDeError(error);
    _proc.receiverCurrent.intents = _proc.receiverCurrent.intents+1;
    _proc.receiverCurrent.errores.add(error);
    await GetContentFile.saveData(
      _proc.currentFileReceiver, FoldStt.wait, _proc.receiverCurrent.toJson(),
    );
    
    switch (tipoErr) {
      case 'retry':
        if(_proc.receiverCurrent.intents > 3) {
          await _getNextReceiver(toDrash: true);
        }else{
          _initProcesoDeEnvio();
        }
        break;
      case 'drash':
        await _getNextReceiver(toDrash: true);
        break;
      case 'contac':
        _buildMsgContacts().then((_) async {
          await _initProcesoDeEnvio();
        });
        break;
      case 'stop':
        await _detenerSistema(error);
        break;
      default:
    }
  }

  ///
  Future<void> _getNextReceiver({bool toDrash = false}) async {

    if(!mounted){ return; }
    if(_proc.isRefresh) {
      _refreshPage();
      return;
    }
    String stt = 'i';
    FoldStt fold = FoldStt.sended;
    if(toDrash) {
      stt = 'p';
      fold = FoldStt.drash;
    }
    List<String> taskFinish = ['Deteniendo CRON FILES'];

    taskFinish.add('Enviando a PAPELERA');
    taskFinish.add('Registrando B.D.');
    taskFinish.add('Receiver a Sended.');
    taskFinish.add('Guardando datos en cache.');
    taskFinish.add('Revisando prioridades.');

    _pixPerTaskFinish = (_progressTotal / taskFinish.length);
    _msgProgreso.value = taskFinish[0];
    _progressFinished.value = _pixPerTaskFinish * 1;
    await _proc.stopCronFiles();

    if(_proc.receiverCurrent.errores.isNotEmpty) {
      if(_proc.receiverCurrent.receiver.cargo == 'addCtac') {
        // El receiver current se envio a contactos, por ello
        // el archivo se envia a papelera
        stt = 'p';
        fold = FoldStt.drash;
      }
    }

    if(stt == 'p') {
      _msgProgreso.value = taskFinish[1];
      _progressFinished.value = _pixPerTaskFinish * 1;
      await BrowserTask.wait(700);
    }

    _msgProgreso.value = taskFinish[2];
    _progressFinished.value = _pixPerTaskFinish * 2;

    await ToServer.regEnvioInBD(
      _proc.receiverCurrent.idCamp,
      _proc.receiverCurrent.idReceiver, stt: stt
    );

    if(!ToServer.result['abort']){
      ToServer.clean();

      _msgProgreso.value = taskFinish[4];
      _progressFinished.value = _pixPerTaskFinish * 4;
      _proc.enProceso.noSend.remove(_proc.currentFileReceiver);
      if(stt == 'p') {
        _proc.enProceso.drash.add(_proc.currentFileReceiver);
      }else{
        _proc.enProceso.sended.add(_proc.currentFileReceiver);
      }
      await GetContentFile.saveData(
        ScmPaths.extractNameFile(_proc.currentFileProcess),
        FoldStt.tray, _proc.enProceso.toJson(),
      );
      await BrowserTask.wait(700);

      _msgProgreso.value = taskFinish[3];
      _progressFinished.value = _pixPerTaskFinish * 3;
      await GetContentFile.changeDeFolder(
        filename: _proc.currentFileReceiver, 
        from: FoldStt.wait, to: fold
      );
      
      _msgProgreso.value = taskFinish[5];
      _progressFinished.value = _pixPerTaskFinish * 5;
      await BrowserTask.wait(500);
      _proc.currentFileReceiver = '';
      _progressFinished.value = _progressTotal;
      _proc.buscamosCampaniaPrioritaria();
    }
  }

  /// Preparamos mensaje para enviar el receiver a contactos,
  /// ta que no fue encontrado en la lista de chats
  Future<void> _buildMsgContacts() async {

    _msgC = await GetContentFile.getMsgOfCampaing('add_contact.txt');
    final rec = _proc.receiverCurrent;

    for (var i = 0; i < _msgC.length; i++) {
      if(_msgC[i].contains('_nombre_')) {
        _msgC[i] = _msgC[i].replaceFirst('_nombre_', rec.nombre);
      }
      if(_msgC[i].contains('_empresa_')) {
        _msgC[i] = _msgC[i].replaceFirst('_empresa_', rec.receiver.empresa);
      }
      if(_msgC[i].contains('_cel_')) {
        _msgC[i] = _msgC[i].replaceFirst('_cel_', rec.receiver.celular);
      }
      if(_msgC[i].contains('_curc_')) {
        _msgC[i] = _msgC[i].replaceFirst('_curc_', rec.curc);
      }
    }

    rec.receiver.cargo = 'addCtac';
  }

  ///
  Future<void> _formatearMsg() async {

    switch (_proc.enProceso.target) {
      case 'orden':
        await _formatMsgOfOrden();
        break;
      default:
    }
  }

  /// Le colocamos los datos personales al mensaje
  List<String> _getMsgOfReceiver() {
    
    var partes = List<String>.from(_proc.msgCurrent);

    for (var i = 0; i < partes.length; i++) {

      if(partes[i].contains('_idCtc_')){
        partes[i] = partes[i].replaceAll('_idCtc_', '${_proc.receiverCurrent.idReceiver}');
      }
      if(partes[i].contains('_nombre')) {
        partes[i] = partes[i].replaceAll('_nombre', _proc.receiverCurrent.nombre);
      }
    }
    return partes;
  }

  /// Sustituimos solo el auto y el IdOrden el cual es general
  /// para todos los receivers de esta campaña
  Future<void> _formatMsgOfOrden() async {

    var partes = List<String>.from(_proc.msgCurrent);

    for (var i = 0; i < partes.length; i++) {

      if(partes[i].contains('_auto_')){
        String auto = _proc.enProceso.data['modelo']['nombre'];
        auto = '$auto ${_proc.enProceso.data['anio']}';
        auto = '$auto de ${_proc.enProceso.data['marca']['nombre']}';
        partes[i] = partes[i].replaceAll('_auto_', auto);
      }

      if(partes[i].contains('_idOrden_')) {
        partes[i] = partes[i].replaceAll('_idOrden_', '${_proc.enProceso.src['id']}');
      }
    }
    _proc.setMsgCurrent(List<String>.from(partes));
  }

  ///
  Future<void> _detenerSistema(String msg) async {

    _proc.isPause = true;
    _proc.terminalIsMini = false;
    _proc.addNewtaskTerminal('[ALERT] $msg');
  }

  ///
  Future<void> _simulaProceso(String proceso) async {

    if(!mounted){ return; }
    await BrowserTask.wait(timeTestByStep);

    if(_simula['with'] == 'ok') {

      if(_proc.isRefresh) {
        _refreshPage();
        return;
      }
      _progressTasks.value = _progressTasks.value + _pixPerTask;
      
      switch (proceso) {
        case 'bskContac':
          await _entrarAlChat();
          break;
        case 'chatDeCtc':
          await _escribirMsg();
          break;
        case 'writeMsg':
          await _enviarMsg();
          break;
        case 'btnSend':
          await _getNextReceiver();
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