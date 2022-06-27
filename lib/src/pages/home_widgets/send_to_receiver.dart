import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:scm/src/repository/to_server.dart';

import '../../providers/process_provider.dart';
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
  final ValueNotifier<double> _progressSended = ValueNotifier(0);
  final ValueNotifier<double> _progressFinished = ValueNotifier(0);
  final ValueNotifier<String> _msgProgreso = ValueNotifier('');

  late ProcessProvider _proc;
  double _progressTotal = 0;
  int timeTestByStep = 3000;
  bool _isInit = false;

  double _pixPerTask = 0;
  double _pixPerTaskFinish = 0;
  Map<String, dynamic> _simula = {};
  int _indexLastCurcTester = 0;
  // Colocamos el msg utilizado para enviarlo al chat de Contactos interno
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
        child: MyToolTip(msg: 'Receptor en Proceso', child: _body()),
      ),
    );
  }

  ///
  Widget _body() {

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
                  color: const Color.fromARGB(255, 169, 180, 221),
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

    if(_proc.receiverCurrent.idReceiver != 0) {
      Future.delayed(const Duration(milliseconds: 600), (){
        _initProcesoDeEnvio();
      });
    }
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
  Future<void> _initProcesoDeEnvio() async {
    
    final scm = _proc.receiverCurrent;
    if(!mounted){ return; }
    await isPaused();
    _simula = {};

    _simula = {'with': 'ok'};
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

    String curcTo = scm.curc;
    if(scm.receiver.cargo == 'addCtac') {
      curcTo = BrowserTask.chatContacts;
    }
    _progressTasks.value = 0;
    _msgProgreso.value = 'Buscando Contacto';

    // Buscamos el contacto.
    if(_simula.isNotEmpty) {

      await _simulaProceso('bskContac');

    }else{

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
    _msgProgreso.value = 'Escribiendo mensaje';

    if(_simula.isNotEmpty) {

      await _simulaProceso('writeMsg');

    }else{

      BrowserTask.comparaCon = _getListTxtToCompare(
        isContac: (_msgC.isNotEmpty) ? true : false
      );
      // List<String> msgSend = (_msgC.isNotEmpty)
      //   ? _msgC : _proc.getMensajeFormated();
      List<String> msgSend = [];
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
      _proc.currentFileReveiver, FoldStt.wait, _proc.receiverCurrent.toJson(),
    );
    switch (tipoErr) {
      case 'retry':
        if(_proc.receiverCurrent.intents > 3) {
          await _enviarToPapelera();
        }else{
          _initProcesoDeEnvio();
        }
        break;
      case 'drash':
        await _enviarToPapelera();
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
  Future<void> _getNextReceiver() async {

    if(!mounted){ return; }
    List<String> taskFinish = ['Guardando Registro'];
    List<int> acc = [0];

    if(_proc.receiverCurrent.errores.isNotEmpty) {
      if(_proc.receiverCurrent.receiver.cargo == 'addCtac') {
        // El receiver current se envio a contactos por ello
        // el archivo se envia a papelera
        taskFinish.add('Enviando a PAPELERA');
        acc.add(1);
      }
    }

    bool isRegisterInBd = false;
    if(acc.contains(1)) {
      _msgProgreso.value = taskFinish[1];
      await _enviarToPapelera();
      isRegisterInBd = true;
    }else{
      taskFinish.add('-');
    }
    taskFinish.add('Registrando B.D.');
    taskFinish.add('Receiver a Sended.');
    taskFinish.add('Guardando datos en cache.');
    taskFinish.add('Revisando prioridades.');

    _pixPerTaskFinish = (_progressTotal / taskFinish.length);

    _msgProgreso.value = taskFinish[2];
    _progressFinished.value = _pixPerTaskFinish * 2;
    // Si es true es que se envio a papelera anteriormente
    // por lo tanto el reg. en la BD ya se realizó.
    if(!isRegisterInBd) {
      await ToServer.regEnvioInBD(
        _proc.receiverCurrent.idCamp, _proc.receiverCurrent.idReceiver
      );
    }else{
      ToServer.result['abort'] = false;
    }

    if(!ToServer.result['abort']){
      ToServer.clean();

      _msgProgreso.value = taskFinish[3];
      _progressFinished.value = _pixPerTaskFinish * 3;
      await GetContentFile.changeDeFolder(
        filename: _proc.currentFileReveiver, 
        from: FoldStt.wait, to: FoldStt.sended
      );

      _msgProgreso.value = taskFinish[4];
      _progressFinished.value = _pixPerTaskFinish * 4;
      _proc.enProceso.noSend.remove(_proc.currentFileReveiver);
      _proc.enProceso.sended.add(_proc.currentFileReveiver);
      await GetContentFile.saveData(
        ScmPaths.extractNameFile(_proc.currentFileProcess),
        FoldStt.tray, _proc.enProceso.toJson(),
      );

      _msgProgreso.value = taskFinish[5];
      _progressFinished.value = _pixPerTaskFinish * 5;
      _proc.currentFileReveiver = '';
    }
  }

  ///
  Future<void> _enviarToPapelera() async {

    await ToServer.regEnvioInBD(
      _proc.receiverCurrent.idCamp, _proc.receiverCurrent.idReceiver,
      stt: 'p'
    );
    if(!ToServer.result['abort']) {
      await GetContentFile.changeDeFolder(
        filename: _proc.currentFileReveiver, 
        from: FoldStt.wait, to: FoldStt.drash
      );
    }
  }

  /// Preparamos mensaje para enviar el receiver a contactos,
  /// ta que no fue encontrado en la lista de chats
  Future<void> _buildMsgContacts() async {

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
        String auto = _proc.enProceso.data['modelo']['nombre'];
        auto = '$auto ${_proc.enProceso.data['anio']}';
        auto = '$auto de ${_proc.enProceso.data['marca']['nombre']}';
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
  Future<void> _simulaProceso(String proceso) async {

    await BrowserTask.wait(timeTestByStep);

    if(_simula['with'] == 'ok') {

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