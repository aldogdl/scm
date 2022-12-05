import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../providers/process_provider.dart';
import '../providers/terminal_provider.dart';
import '../services/puppetter/browser_conn.dart';
import '../services/puppetter/providers/browser_provider.dart';
import '../widgets/my_terminal_code.dart';


class MyTerminal extends StatefulWidget {

  const MyTerminal({Key? key}) : super(key: key);

  @override
  State<MyTerminal> createState() => _MyTerminalState();
}

class _MyTerminalState extends State<MyTerminal> {

  final ScrollController _scroll = ScrollController();

  bool _isInit = false;
  late final TerminalProvider _provR;
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
    }

    return Stack(
      children: [
        Positioned(
          child: Container(
            width: appWindow.size.width -55,
            height: appWindow.size.height * 0.154,
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _conteoRev(),
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
          ),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: Container(
            width: 30, height: 25,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 51, 51, 51),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5)
              )
            ),
            child: IconButton(
              padding: const EdgeInsets.all(0),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(
                maxHeight: 18
              ),
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              onPressed: () => _provR.taskTerminal = [],
            ),
          ),
        )
      ],
    );
  }
  
  ///
  Widget _conteoRev() {
    
    return Selector<ProcessProvider, bool>(
      selector: (_, prov) => prov.isStopCronFiles,
      builder: (context, isStop, child) {
        
        if(isStop){
          const Divider(color: Colors.grey, height: 2);
        }

        return Selector<ProcessProvider, int>(
          selector: (_, prov) => prov.timer,
          builder: (ctx, tiempo, __) {

            final prov = ctx.read<ProcessProvider>();
            if(tiempo >= 96){
              Future.microtask(() => prov.resetTimer());
            }
            final v = ((tiempo+3) / 100);
            return LinearProgressIndicator(
              value: v,
              backgroundColor: Colors.black,
              color: Colors.green,
              minHeight: 2,
            );
          },
        );
      },
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
        padding: const EdgeInsets.only(
          right: 8, left: 8, top: 5
        ),
        controller: _scroll,
        itemCount: tasks.length,
        itemBuilder: (_, index) => _tileTask(tasks[index])
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

    if(task.startsWith('>')) {
      txtc = const Color.fromARGB(255, 164, 171, 177);
    }
    
    if(task.startsWith('X')) {
      txtc = const Color.fromARGB(255, 228, 118, 110);
    }

    if(task.startsWith('√')) {
      txtc = const Color.fromARGB(255, 15, 123, 247);
    }

    if(task.startsWith('<>')) {
      txtc = const Color.fromARGB(255, 15, 123, 247);
      return TextButton(
        onPressed: () => _determinarFuncion(task),
        style: ButtonStyle(
          alignment: Alignment.centerLeft,
          padding: MaterialStateProperty.all(
            const EdgeInsets.all(0)
          )
        ),
        child: Text(
          task,
          textScaleFactor: 1,
          textAlign: TextAlign.left,
          style: GoogleFonts.inconsolata(
            textStyle: const TextStyle(
              fontSize: 13,
              color: Colors.yellow,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w300
            )
          ),
        )
      );
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
            fontWeight: FontWeight.w300
          )
        ),
      )
    );
  }

  ///
  void _determinarFuncion(String label) async {

    if(label.contains('WhatsApp')) {
      await _revisandoConectividad();
    }
    if(label.contains('[W]')) {
      _provR.taskTerminal.clear();
      await Future.delayed(const Duration(milliseconds: 250));
      await _reconectandoWhats();
    }
  }

  ///
  Future<void> _reconectandoWhats() async {

    _provR.addTask('Reconectando Sistema de Mensajería');
    final connProv = context.read<BrowserProvider>();
    final procProv = context.read<ProcessProvider>();
    connProv.isOkCp = false;
    procProv.systemIsOk = procProv.systemIsOk + 1;
    return;
  }

  ///
  Future<void> _revisandoConectividad() async {

    _provR.addTask('Revisando Conectividad');
    final connProv = context.read<BrowserProvider>();
    final procProv = context.read<ProcessProvider>();
    String check = await BrowserConn.checarConectividad(
      connProv.browser, connProv.pagewa, connProv.titleCurrent
    );
    if(check.isEmpty) {
      _provR.addOk('Conexión Sistema Exitoso');
      _provR.addTask('Inicializando Monitoreo');
      connProv.isOkCp = true;
      procProv.systemIsOk = 1000;
    }else{
      _provR.addWar(check);
      _provR.addAcc('Revisa de nuevo WhatsApp');
    }
    return;
  }
}