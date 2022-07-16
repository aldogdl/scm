import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scm/src/widgets/my_terminal_code.dart';
import 'package:scm/src/widgets/my_terminal_header.dart';

import '../providers/process_provider.dart';
import '../widgets/texto.dart';

class MyTerminal extends StatefulWidget {

  const MyTerminal({Key? key}) : super(key: key);

  @override
  State<MyTerminal> createState() => _MyTerminalState();
}

class _MyTerminalState extends State<MyTerminal> {

  final ScrollController _scroll = ScrollController();

  bool _isInit = false;
  late final ProcessProvider _provW;
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
      _provW = context.watch<ProcessProvider>();
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
              context.read<ProcessProvider>().taskTerminal = [];
            },
            onViewCode: (_) {
              if(context.read<ProcessProvider>().terminalIsMini) {
                context.read<ProcessProvider>().terminalIsMini = !_provW.terminalIsMini;
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
            ? Selector<ProcessProvider, List<String>>(
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
          right: 10,
          top: (!_provW.terminalIsMini) ? 5 : 10
        ),
        controller: _scroll,
        itemCount: tasks.length,
        itemBuilder: (_, index) => _tileTask(tasks[index]),
      )
    );
  }

  ///
  Widget _tileTask(String task) {

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

    return Texto(txt: task, txtC: txtc, sz: 13.5);

  }
}