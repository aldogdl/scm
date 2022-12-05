import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bsk_contact.dart';
import 'search_contact.dart';
import 'write_msg.dart';
import '../../../../providers/process_provider.dart';
import '../../../../providers/terminal_provider.dart';
import '../../../../widgets/texto.dart';

class SenderProcess extends StatefulWidget {

  final double maxWidth;
  const SenderProcess({
    Key? key,
    required this.maxWidth
  }) : super(key: key);

  @override
  State<SenderProcess> createState() => _SenderProcessState();
}

class _SenderProcessState extends State<SenderProcess> {

  late final PageController _ctrPage;
  late final TerminalProvider _consol;
  late final ProcessProvider _pprov;

  int _cantPages = 0;
  int intentos = 0;
  bool _lockYield = false;
  bool _isInit = false;
  Timer? _timerPause;

  @override
  void initState() {

    // Empieza a contar desde el cero
    // La ultima no la contamos, para usarla al pausar
    _cantPages = 3;
    _ctrPage   = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _consol.taskTerminal.clear();
    });

    super.initState();
  }

  @override
  void dispose() {
    _ctrPage.dispose();
    if(_timerPause != null) {
      _timerPause!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _consol = context.read<TerminalProvider>();
      _pprov  = context.read<ProcessProvider>();
    }
    
    return PageView(
      controller: _ctrPage,
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _bskContact(),
        _searchContact(),
        _writeMsg(),
        _enEspera(),
        _emptyPage()
      ],
    );
  }

  /// page 0
  Widget _bskContact() {

    _lockYield = false;
    return BskContact(
      maxW: widget.maxWidth,
      onFinish: (res) => _procesarYield(res, 0, 1),
    );
  }

  /// page 1
  Widget _searchContact() {

    _lockYield = false;
    return SearchContact(
      maxW: widget.maxWidth,
      onFinish: (res) => _procesarYield(res, 1, 2),
    );
  }

  /// page 2
  Widget _writeMsg() {

    _lockYield = false;
    return WriteMsg(
      maxW: widget.maxWidth,
      onFinish: (res) => _procesarYield(res, 2, 0),
    );
  }

  /// page 3
  Widget _enEspera() {

    return const Padding(
      padding: EdgeInsets.only(top: 10),
      child: Texto(
        txt: 'EN ESPERA ;P',
        isCenter: true,
      )
    );
  }

  /// page 4
  Widget _emptyPage() {

    return const Padding(
      padding: EdgeInsets.only(top: 10),
      child: SizedBox()
    );
  }

  ///
  void _procesarYield
    (String res, int fromPage, int toPage) async
  {

    if(!_lockYield) {

      if(_pprov.lastProcess.containsKey(fromPage)) {
        final l = List<String>.from(_pprov.lastProcess[fromPage]!);
        l.add(res);
        _pprov.lastProcess[fromPage] = l;
      }else{
        _pprov.lastProcess = {fromPage : [res]};
      }
      
      if(_pprov.receiverCurrent != null) {
        // Revisamos si existen errores registrados
        if(_pprov.receiverCurrent!.errores.isNotEmpty) {
          _lockYield = true;
          await _finalizarEnvioActual('de ERROR');
          return;
        }
      }

      /// Este listo es para el proceso final
      if(res.contains('Listo')) {

        if(res.startsWith('√')) {
          _lockYield = true;
          await _finalizarEnvioActual('de √ Listo');
          return;
        }else{
          _lockYield = true;
          Future.microtask(() {
            _onListo(res, fromPage, toPage);
          });
        }
      }else{

        if(_pprov.isPause) {
          _lockYield = true;
          _timerPause = Timer.periodic(const Duration(seconds: 1), _isNotPause);
          await _anim(_cantPages);
          Future.microtask(() {
            _consol.addErr('> PAUSA > PAUSA > PAUSA <');
          });
          return;
        }
      }
    }

    return;
  }

  ///
  Future<void> _onListo
    (String res, int fromPage, int toPage) async
  {
    await _anim(toPage);
    _lockYield = false;
    return;
  }
  
  /// Fin del envio del receiver, es necesario cambiar la sig.
  /// en caso de que no halla mas, terminamos con la campaña
  Future<void> _finalizarEnvioActual(String from) async {

    await _anim(_cantPages+1);
    await _pprov.updateFilesFinSendReceiver(_consol);
    final res = await _pprov.getNextReceiver(_consol);
    _pprov.lastProcess = {};
    Future.microtask(() async {
      if(res) { await _anim(0); }
    });
  }

  ///
  Future<void> _anim(int toPage, {bool jump = true}) async {

    if(_ctrPage.page == toPage && toPage == _cantPages){
      _ctrPage.jumpToPage(_cantPages+1);
    }
    _sleep();
    if(jump) {
      _ctrPage.jumpToPage(toPage);
    }else{
      await _ctrPage.animateToPage(toPage, duration: tim, curve: crv);
    }
  }

  // ///
  // Future<String> _checkIsPause() async {

  //   String res = 'EN ESPERA :P';
  //   print('en _checkIsPause');
  //   print(_pprov.isPause);
  //   if(_pprov.isPause) {
  //     print('entro');
  //     _timerPause = Timer.periodic(const Duration(seconds: 1), _isNotPause);
  //     res = 'EN PAUSA }<';
  //   }
  //   return res;
  // }

  ///
  void _isNotPause(_) async {

    if(!_pprov.isPause) {
      _timerPause!.cancel();
      _lockYield = false;
      await _anim(_pprov.lastProcess.keys.first);
    }
  }

  ///
  Future<void> _sleep({int timer = 500}) async => await Future.delayed(Duration(milliseconds: timer));
  
  ///
  Duration get tim => const Duration(milliseconds: 350);
  
  ///
  Cubic get crv => Curves.easeIn;
}