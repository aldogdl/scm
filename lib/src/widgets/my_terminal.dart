import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:scm/src/providers/process_provider.dart';

import '../providers/terminal_provider.dart';
import '../widgets/my_terminal_code.dart';
import '../widgets/my_terminal_header.dart';


class MyTerminal extends StatefulWidget {

  const MyTerminal({Key? key}) : super(key: key);

  @override
  State<MyTerminal> createState() => _MyTerminalState();
}

class _MyTerminalState extends State<MyTerminal> {

  final ScrollController _scroll = ScrollController();

  bool _isInit = false;
  late final TerminalProvider _provR;
  late final TerminalProvider _provW;
  String seccion = 'terminal';

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _provR= context.read<TerminalProvider>();
      _provW = context.watch<TerminalProvider>();
    }

    return Container(
      width: appWindow.size.width -55,
      height: _provW.terminalIsMini
      ? appWindow.size.height * 0.05
      : appWindow.size.height * 0.3,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TerminalHeader(
            onClean: (_) {
              _provR.taskTerminal = [];
            },
            onViewCode: (_) {
              if(_provR.terminalIsMini) {
                _provR.terminalIsMini = !_provW.terminalIsMini;
              }
              setState(() {
                seccion = (seccion == 'code') ? 'terminal' : 'code';
              });
            }
          ),
          if(!_provW.terminalIsMini)
            const Divider(color: Colors.grey, height: 1),
          Expanded(
            child: (seccion == 'terminal')
            ? Selector<TerminalProvider, List<String>>(
              selector: (_, provi) => provi.taskTerminal,
              builder: (_, tasks, __) => _resultados(tasks),
            )
            : const MyTerminalCode()
          )
        ],
      ),
    );
  }
  
  ///
  Widget _resultados(List<String> tasks) {

    return Scrollbar(
      controller: _scroll,
      thumbVisibility: true,
      radius: const Radius.circular(3),
      trackVisibility: true,
      child: ListView.builder(
        padding: EdgeInsets.only(
          right: 8, left: 8,
          top: (!_provW.terminalIsMini) ? 5 : 10
        ),
        controller: _scroll,
        itemCount: tasks.length,
        itemBuilder: (_, index) => Selector<ProcessProvider, bool>(
          selector: (_, prov) => prov.isProcessOnErr,
          builder: (_, val, __) => _tileTask(tasks[index], val)
        ),
      )
    );
  }

  ///
  Widget _tileTask(String task, bool isProcessOnErr) {

    const per = '[Er]';
    Color txtc = const Color.fromARGB(255, 255, 193, 7);
    
    if(task.startsWith('[CRON')) {
      txtc = const Color.fromARGB(255, 33, 150, 243);
    }
    if(task.startsWith('[ERROR')) {
      txtc = const Color.fromARGB(255, 245, 127, 118);
    }
    if(task.startsWith('[ALERTA')) {
      txtc = const Color.fromARGB(255, 117, 104, 28);
    }

    if(task.startsWith('>')) {
      txtc = const Color.fromARGB(255, 164, 171, 177);
      if(isProcessOnErr){
        txtc = const Color.fromARGB(255, 5, 243, 152);
        task = '$task $per';
      }
    }
    
    if(task.startsWith('X')) {
      txtc = const Color.fromARGB(255, 228, 118, 110);
      if(isProcessOnErr){
        txtc = const Color.fromARGB(255, 255, 147, 139);
        task = '$task $per';
      }
    }

    if(task.startsWith('√')) {
      txtc = const Color.fromARGB(255, 102, 189, 240);
      if(isProcessOnErr){
        txtc = const Color.fromARGB(255, 10, 140, 216);
        task = '$task $per';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        task,
        textScaleFactor: 1,
        textAlign: TextAlign.left,
        style: GoogleFonts.inconsolata(
          textStyle: TextStyle(
            fontSize: 13,
            color: txtc,
            letterSpacing: 1.1,
            fontWeight: FontWeight.normal
          )
        ),
      )
    );

  }
}