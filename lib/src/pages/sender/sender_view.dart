import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scm/src/widgets/indicador_cola.dart';

import 'views/fin_process.dart';
import 'views/init_process.dart';
import 'views/bsk_contact.dart';
import 'views/search_contact.dart';
import 'views/write_msg.dart';
import '../../providers/process_provider.dart';
import '../../providers/terminal_provider.dart';
import '../../services/puppetter/vars_puppe.dart';
import '../../services/get_content_files.dart';
import '../../services/puppetter/libs/task_shared.dart';
import '../../services/puppetter/libs/lib_fin_process.dart';
import '../../widgets/texto.dart';
import '../../widgets/tile_contacts.dart';

class SenderView extends StatefulWidget {

  final bool isCheck;
  const SenderView({
    Key? key,
    this.isCheck = false
  }) : super(key: key);

  @override
  State<SenderView> createState() => _SenderViewState();
}

class _SenderViewState extends State<SenderView> {

  final _receptor= ValueNotifier<String>('');

  late final PageController _ctrPage;
  late final TerminalProvider _consol;
  late final ProcessProvider _pprov;

  int _cantPages = 0;
  bool _lockYield = false;
  bool _isInit = false;
  int _currentPageProcess = -1;
  int _intentosInternos = 1;

  @override
  void initState() {

    // Empieza a contar desde el cero
    // La ultima no la contamos, para usarla al pausar
    _cantPages = 5;
    _ctrPage   = PageController(initialPage: (_cantPages+1));

    WidgetsBinding.instance.addPostFrameCallback((_) async {

      if(widget.isCheck) {
        _pprov.isTest = true;
      }else{
        if(_consol.terminalIsMini) {
          _consol.terminalIsMini = false;
        }
        if(!_pprov.isPause) {
          Future.delayed(const Duration(milliseconds: 1000), () async {
            _currentPageProcess = 0;
            await _anim(_currentPageProcess);
          });
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _ctrPage.dispose();
    _receptor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _consol = context.read<TerminalProvider>();
      _pprov  = context.read<ProcessProvider>();
      _pprov.isProcessOnErr = false;
      Future.delayed(const Duration(milliseconds: 250), (){
        _consol.taskTerminal = [];
        _pprov.isActiveRefresh = true;

        if(_pprov.receiverCurrent.curc.isNotEmpty) {
          _pprov.curcProcess = _pprov.receiverCurrent.curc;
          _pprov.nombreProcess = _pprov.receiverCurrent.nombre;
          _receptor.value = _pprov.curcProcess;
        }
      });
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 0.41,
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
        child: Column(
          children: [
            _indicadorRefresh(),
            _pages(),
            const SizedBox(height: 15),
            Expanded(
              child: (widget.isCheck)
                ? _showErrForTest('Probando') : _tileForSend(),
            )
          ],
        )
      ),
    );
  }

  ///
  Widget _indicadorRefresh() {

    return Selector<ProcessProvider, bool>(
      selector: (_, prov) => prov.isActiveRefresh,
      builder: (_, val, __) {

        if(_pprov.isRefresh && !val) {

          int pageRef = (_cantPages+2);
          if(_ctrPage.page != pageRef) {
            Future.microtask(() async {
              await _anim(pageRef).then((value) => _refrescar());
            });
          }
        }

        return IndicadorCola(
          height: 1,
          onOff: (_pprov.isRefresh) ? 'off' : 'on',
          colorOn: Colors.grey.withOpacity(0.3),
          colorOff: const Color.fromARGB(255, 31, 202, 96)
        );
      },
    );
  }
  
  ///
  Widget _pages() {

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.05,
      color: const Color.fromARGB(255, 34, 34, 34),
      child: LayoutBuilder(
        builder: (_, BoxConstraints constraints) {
          return PageView(
            controller: _ctrPage,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _initProcess(constraints.maxWidth),
              _bskContact(constraints.maxWidth),
              _searchContact(constraints.maxWidth),
              _writeMsg(constraints.maxWidth),
              _finProcess(constraints.maxWidth),
              _pageErrores(constraints.maxWidth),
              _pagePausa(constraints.maxWidth),
              _pageRefresh(constraints.maxWidth)
            ],
          );
        },
      )
    );
  }

  /// page 0
  Widget _initProcess(double mw) {

    _lockYield = false;
    return InitProcess(
      maxW: mw,
      onFinish: (res) {
        
        _procesarYield(res, 0, 1, Colors.grey);
      }
    );
  }

  /// page 1
  Widget _bskContact(double mw) {

    _lockYield = false;
    return BskContact(
      maxW: mw,
      onFinish: (res) => _procesarYield(res, 1, 2, Colors.green),
    );
  }

  /// page 2
  Widget _searchContact(double mw) {

    _lockYield = false;
    return SearchContact(
      maxW: mw,
      onFinish: (res) => _procesarYield(
        res, 2, 3, const Color.fromARGB(255, 64, 148, 67)
      ),
    );
  }

  /// page 3
  Widget _writeMsg(double mw) {

    _lockYield = false;
    return WriteMsg(
      maxW: mw,
      onFinish: (res) => _procesarYield(
        res, 3, (_cantPages-1), const Color.fromARGB(255, 56, 129, 58)
      ),
    );
  }

  /// page 4
  Widget _finProcess(double mw) {

    _lockYield = false;
    return FinProcess(
      maxW: mw,
      onFinish: (res) => _procesarYield(
        res, 4, (_cantPages+1), Colors.grey
      ),
    );
  }

  /// Page 5
  Widget _pageErrores(double mw) {

    _lockYield = false;
    return Container(
      width: mw,
      color: Colors.red,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.error_outline_sharp),
          SizedBox(width: 8),
          Texto(txt: 'Procesar Insidencia', txtC: Colors.white)
        ],
      ),
    );
  }

  /// Hidden Page 6 -> Pausa el proceso
  Widget _pagePausa(double mw) {

    return Container(
      width: mw,
      color: Colors.blueGrey,
      child: Selector<ProcessProvider, bool>(
        selector: (_, prov) => prov.isPause,
        builder: (_, isPause, child) {

          if(!isPause && !_pprov.isRefresh) {
            Future.delayed(const Duration(milliseconds: 1000), () {
              Future.microtask(() async {
                if(_currentPageProcess == -1) {
                  _currentPageProcess = 0;
                }
                await _anim(_currentPageProcess);
              });
            });
          }

          return child!;
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.motion_photos_pause_outlined),
            SizedBox(width: 8),
            Texto(txt: 'Sistema en Pausa', txtC: Colors.white)
          ],
        ),
      )
    );
  }

  /// Hidden Page 7 -> Refresh el proceso
  Widget _pageRefresh(double mw) {

    return Container(
      width: mw,
      color: const Color.fromARGB(255, 0, 91, 196),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          Expanded(
            child: Center(
              child: Texto(
                txt: 'Refrescando Sistema',
                txtC: Colors.white, isCenter: true,
              )
            ),
          ),
          SizedBox(
            height: 2,
            child: LinearProgressIndicator()
          )
        ],
      )
    );

  }

  ///
  Widget _tileForSend() {

    return ValueListenableBuilder<String>(
      valueListenable: _receptor,
      builder: (_, recep, child) {

        if(recep.isEmpty) { return child!; }

        return TileContacts(
          idCamp: _pprov.receiverCurrent.idCamp,
          target: _pprov.enProceso.target,
          idTarget: _pprov.enProceso.data['id'],
          curc: _pprov.receiverCurrent.curc,
          nombre: _pprov.receiverCurrent.nombre,
          title: '-> ${_pprov.receiverCurrent.receiver.empresa}',
          subTi: _pprov.receiverCurrent.receiver.celular,
          celular: _pprov.receiverCurrent.receiver.celular,
          isCurrent: true,
        );
      },
      child: const Center(
        child: Icon(
          Icons.contact_mail_outlined,
          size: 70, color: Color.fromARGB(255, 87, 87, 87)
        ),
      )
    );    
  }

  ///
  Widget _showErrForTest(String err) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () async => await _anim(_currentPageProcess),
          icon: const Icon(Icons.rotate_left_rounded)
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Texto(txt: err, sz: 12),
        )
      ],
    );
  }
  
  ///
  void _putInScreen() {

    Future.delayed(const Duration(milliseconds: 250), () {
      _receptor.value = _pprov.receiverCurrent.curc;
    });
  }

  ///
  void _procesarYield
    (String res, int fromPage, int toPage, Color bg) async
  {

    if(!_lockYield) {

      if(_pprov.isRefresh) {
        _lockYield = true;
        await _anim((_cantPages+2));
        return;
      }
      
      if(_pprov.isPause) {
        _lockYield = true;
        _currentPageProcess = fromPage;
        await _anim((_cantPages+1));
        Future.microtask(() {
          _consol.addErr('> PAUSA > PAUSA > PAUSA <');
        });
        return;
      }

      if(res.startsWith('√ Listo')) {

        if(_pprov.isProcessOnErr) {
          Future.microtask(() {
            _onError(res, fromPage, toPage, bg, 'err');
          });
          return;
        }else{
          Future.microtask(() {
            _onFinish(res, fromPage, toPage, bg);
          });
          return;
        }

      }else{

        if(res.contains('Listo')) {
          if(_pprov.isProcessOnErr) {
            if(toPage == (_cantPages-1)) {
              Future.microtask(() {
                _onError(res, fromPage, toPage, bg, 'err');
              });
              return;
            }
          }
          Future.microtask(() {
            _onListo(res, fromPage, toPage, bg);
          });
          return;
        }
      }

      if(res.startsWith('ERROR')) {
        Future.microtask(() {
          _onError(res, fromPage, toPage, bg, 'way');
        });
      }
    }

    return;
  }

  ///
  Future<void> _onListo
    (String res, int fromPage, int toPage, Color bg) async
  {
    _lockYield = true;
    if(fromPage == 0) {
      res = await _checkDataInit();
      if(res != 'ok') {
        Future.delayed(const Duration(milliseconds: 1000), (){
          context.read<TerminalProvider>().addTask(res);
        });
        _lockYield = false;
        return;
      }
    }

    _pprov.receiverCurrent.intents = 0;
    await _anim(toPage);
    _lockYield = false;
    return;
  }

  ///
  Future<void> _onError
    (String res, int fromPage, int toPage, Color bg, String from) async
  {
    _lockYield = true;
    _currentPageProcess = fromPage;

    if(from == 'way') {
      if(_pprov.isProcessOnErr) {
        // Si ubo error pero estoy procesando acciones sobre otro error
        // significa que el error ocurrio cuando:
        // a) Se esta enviado al chat de Contactos
        // b) Se esta enviado una notificación de alerta
        // Por lo tanto hacemos otro intento desde el inicio.

        // Si sobre pasa los limites de intentos, enviar a papelera y continuar
        // con el siguiente receptor.
        if(_intentosInternos < intentos) {
          _currentPageProcess = 1;
          _intentosInternos++;
          Future.microtask(() {
            _consol.addWar('Repetir Acc. Intentos $_intentosInternos/$intentos');
          });
          await _anim(_currentPageProcess);
          _lockYield = false;
          return;
        }else{
          _intentosInternos = 1;
        }
      }
    }

    if(from == 'way') {
      await _anim(_cantPages);
      await _sleep();
    }
    _startCmdsOfErrors();
    _lockYield = false;
    return;
  }

  ///
  Future<void> _onFinish
    (String res, int fromPage, int toPage, Color bg) async
  {
    _lockYield = true;

    // Si el proceso ya termino y no hay mas receptores
    if(res == 'close') {

      if(!_consol.terminalIsMini) {
        _consol.clean();
      }

      Future.delayed(const Duration(milliseconds: 1000), (){
        final nav = Navigator.of(context);
        if(nav.canPop()) {
          nav.pop();
        }
        return;
      });
    }

    Future.microtask(() {
      _finalizarProcesoActual();
    });

    _lockYield = false;
    return;
  }

  ///
  Future<String> _checkDataInit() async {

    String res = 'ok';
    await _sleep();
    _consol.addDiv(s: 'o');

    if(!_pprov.isTest) {
      if(_pprov.receiverCurrent.curc.isNotEmpty) {
        _pprov.curcProcess = _pprov.receiverCurrent.curc;
        _pprov.nombreProcess = _pprov.receiverCurrent.nombre;
      }
    }else{
      if(_pprov.indexLastCurcTester != -1) {
        if(_pprov.receiverCurrent.curc.isNotEmpty) {
          if(_pprov.curcProcess == _pprov.receiverCurrent.curc) {
            _pprov.curcProcess = _pprov.lstTestings[_pprov.indexLastCurcTester]['curc'];
            _pprov.nombreProcess = _pprov.lstTestings[_pprov.indexLastCurcTester]['nombre'];
          }
        }
      }
    }

    if(_pprov.curcProcess.isEmpty) {
      res = 'Sin DATOS a Procesar';
    }else{
      _consol.addOk('Datos a Procesar Correctos');
    }

    if(_pprov.msgCurrentFormat.isEmpty) {
      res = 'Mensaje Sin Formato';
    }else{
      _consol.addOk('Mensaje Listo y Formateado');
    }

    if(res != 'ok') {
      _consol.addErr(res);
    }else{
      Future.delayed(const Duration(milliseconds: 350), () {
        _putInScreen();
      });
    }

    return res;
  }

  /// Proceso de ERRORES
  Future<void> _startCmdsOfErrors() async {

    Future.microtask(() async {
      await tituloSecc(_consol, 'Procesando Error en Consola');
    });

    if(_pprov.receiverCurrent.cmds.first == CmdType.retryThis) {
      
      if(_pprov.receiverCurrent.intents < intentos) {
        _pprov.receiverCurrent.cmds.removeAt(0);
        _consol.addTask('Repetir acción. Intento ${_pprov.receiverCurrent.intents}/$intentos');
        _sleep(timer: 1000);
        await _anim(_currentPageProcess);
        return;
      }else{
        _consol.addTask('[A PAPELERA] por Intentos ${_pprov.receiverCurrent.intents}/$intentos');
        _pprov.receiverCurrent.cmds.clear();
        _pprov.receiverCurrent.cmds.add(CmdType.notifRemite);
        _pprov.receiverCurrent.cmds.add(CmdType.papelera);
      }
    }

    if(_pprov.receiverCurrent.cmds.first == CmdType.contactanos) {
      
      _currentPageProcess = 1;
      _pprov.isProcessOnErr = true;
      _pprov.receiverCurrent.cmds.removeAt(0);
      _consol.addTask('[A $chatContacts] ${_pprov.receiverCurrent.nombre}');
      await _prepareNotiffContacto();
      _pprov.curcProcess = chatContacts;
      _pprov.nombreProcess = '[A $chatContacts] ${_pprov.receiverCurrent.nombre}';

      await _anim(_currentPageProcess);
      return;
    }

    if(_pprov.receiverCurrent.cmds.first == CmdType.notifRemite) {
      
      _currentPageProcess = 1;
      _pprov.isProcessOnErr = true;
      _pprov.receiverCurrent.cmds.removeAt(0);
      await _prepareNotiffRemite();
      
      _consol.addTask('NOTIFICACIÓN DE ALERTA A:');
      _consol.addOk('^^^^ ${_pprov.nombreProcess}');
      await _sleep();

      await _anim(_currentPageProcess);
      return;
    }

    if(_pprov.receiverCurrent.cmds.first == CmdType.papelera) {

      _pprov.receiverCurrent.cmds.removeAt(0);
      Future.microtask(() {
        _consol.addTask('[A PAPELERA] ${_pprov.receiverCurrent.nombre}');
      });

      final lib = LibFinProcess(
        forceDrash: true,
        pprov: _pprov,
        console: _consol,
        incProgress: (_) {},
        onFinish: (fin) {}
      );

      final res = await lib.makeWithErr();
      if(res.startsWith('√ Listo')) {
        _finalizarProcesoActual();
      }else{
        _consol.addWar('Ocurrio un ERROR Inesperado');
        _sleep();
        _consol.addTask(res);
      }
    }
    return;
  }

  ///
  Future<void> _refrescar() async {

    final nav = Navigator.of(context);
    if(!_pprov.isRefresh) { return; }
    
    Future.microtask(() => _pprov.isActiveRefresh = false);
    await _sleep(timer: 1000);

    _pprov.fileBeforeRefresh = {
      'idRegDb'     : _pprov.idRegDb,
      'campJson'    : _pprov.enProceso.toJson(),
      'campFile'    : _pprov.currentFileProcess,
      'receiverFile': _pprov.currentFileReceiver
    };
    await _sleep(timer: 250);
    _pprov.cleanProcess();
    _pprov.cleanCampaingCurrent();
    _pprov.cleanReloadMsgAcction();
    await _sleep(timer: 250);
    _consol.taskTerminal.clear();
    _consol.terminalIsMini = true;
    await _sleep(timer: 250);
    _pprov.isActiveRefresh = false;
    await _sleep(timer: 250);
    _pprov.reloadMsgAcction = 'Recargando Sistema...';
    
    if(nav.canPop()) {
      nav.pop();
    }
    return;
  }

  ///
  Future<void> _prepareNotiffRemite() async {

    Future.microtask(() {
      _consol.addWar('Cambiando a [${_pprov.receiverCurrent.rCurc}]');
    });
    _pprov.curcProcess = _pprov.receiverCurrent.rCurc;
    _pprov.nombreProcess = _pprov.receiverCurrent.rName;
    
    var errs = List<String>.from(_pprov.receiverCurrent.errores);

    List<String> colErr = [];
    // Organizamos los errores
    for (var i = 0; i < errs.length; i++) {
      colErr.add('[X] _${errs[i]}_.');
      colErr.add('_sp_');
    }

    var msg = await getMsgBy(msgForAlerts);
    msg = replaceAutoAndIdOrden(_pprov, msg);
    // Partimos en dos partes el msg
    List<String> parteUp = [];
    List<String> parteDown = [];
    for (var i = 0; i < msg.length; i++) {
      if(msg[i].contains('_errores_')) {
        break;
      }
      parteUp.add(msg[i]);
    }

    bool isAdd = false;
    for (var i = 0; i < msg.length; i++) {
      if(msg[i].contains('_errores_')) {
        isAdd = true;
        continue;
      }
      if(isAdd) {
        if(msg[i].contains('_nombre_')) {
          msg[i] = msg[i].replaceAll('_nombre_', _pprov.nombreProcess);
        }
        if(!msg[i].contains('_errores_')) {
          parteDown.add(msg[i]);
        }
      }
    }
    msg = [];
    msg.addAll(parteUp);
    msg.addAll(colErr);
    msg.addAll(parteDown);

    _pprov.msgCurrentFormat = List<String>.from(msg);

    msg = []; errs= [];
  }

  ///
  Future<void> _prepareNotiffContacto() async {

    _consol.addOk('Cambiando a [$chatContacts]');
    var msg = await _getMsgContacts();    
    _pprov.msgCurrentFormat = List<String>.from(msg);

    msg = [];
  }

  ///
  Future<void> _finalizarProcesoActual() async {

    final nav = Navigator.of(context);
    _consol.addOk('Finalizando Proceso Actual.');
    _pprov.cleanProcess();
    _pprov.cleanCampaingCurrent(fromSender: true);
    _currentPageProcess = 0;
    _consol.taskTerminal = [];
    await _sleep();

    await _pprov.buscamosCampaniaPrioritaria(
      console: _consol, inFromSender: true
    );

    if(_consol.taskTerminal.first.contains('En espera')) {
      _consol.addOk('Cerrando Servicio.');
      await _sleep(timer: 1000);
      _consol.terminalIsMini = true;
      await _sleep();
      if(nav.canPop()) {
        nav.pop();
      }else{
        //print('No pudo hacer pop al finalizar');
      }
      return;
    }

    if(_consol.taskTerminal.first.contains('Iniciando')) {

      if(_consol.terminalIsMini) {
        _consol.terminalIsMini = false;
      }
      await _sleep();
      if(_pprov.receiverCurrent.curc.isNotEmpty) {
        _pprov.curcProcess = _pprov.receiverCurrent.curc;
        _pprov.nombreProcess = _pprov.receiverCurrent.nombre;
        _receptor.value = _pprov.curcProcess;
      }
      await _sleep();
      await _anim(_currentPageProcess);
      return;
    }

    _receptor.value = '';
    return;
  }

  /// Preparamos mensaje para enviar el receiver a contactos,
  /// ya que no fue encontrado en la lista de chats
  Future<List<String>> _getMsgContacts() async {

    final rec = _pprov.receiverCurrent;

    var msg = await GetContentFile.getMsgOfCampaing(msgForContacts);

    for (var i = 0; i < msg.length; i++) {
      if(msg[i].contains('_nombre_')) {
        msg[i] = msg[i].replaceFirst('_nombre_', rec.nombre);
      }
      if(msg[i].contains('_empresa_')) {
        msg[i] = msg[i].replaceFirst('_empresa_', rec.receiver.empresa);
      }
      if(msg[i].contains('_cel_')) {
        msg[i] = msg[i].replaceFirst('_cel_', rec.receiver.celular);
      }
      if(msg[i].contains('_curc_')) {
        msg[i] = msg[i].replaceFirst('_curc_', rec.curc);
      }
    }

    return msg;
  }

  ///
  Future<void> _anim(int toPage, {bool jump = true}) async {

    if(!widget.isCheck) {
      if(toPage < _cantPages) {
        _currentPageProcess = toPage;
      }
      if(_ctrPage.page == toPage){
        _ctrPage.jumpToPage(_cantPages+1);
      }
      _sleep();
      if(jump) {
        _ctrPage.jumpToPage(toPage);
      }else{
        await _ctrPage.animateToPage(toPage, duration: tim, curve: crv);
      }
    }
  }

  ///
  Future<void> _sleep({int timer = 500}) async => await Future.delayed(Duration(milliseconds: timer));
  
  ///
  Duration get tim => const Duration(milliseconds: 350);
  
  ///
  Cubic get crv => Curves.easeIn;

}