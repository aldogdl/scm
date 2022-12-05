import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../body_process.dart';
import '../../../../providers/socket_conn.dart';
import '../../../../providers/terminal_provider.dart';
import '../../../../providers/process_provider.dart';
import '../../../../services/puppetter/libs/lib_check_conn.dart';
import '../../../../services/puppetter/providers/browser_provider.dart';
import '../../../../widgets/texto.dart';

class ChkConn extends StatefulWidget {

  final double maxW;
  const ChkConn({
    Key? key,
    required this.maxW,
  }) : super(key: key);

  @override
  State<ChkConn> createState() => _ChkConnState();
}

class _ChkConnState extends State<ChkConn> {

  @override
  Widget build(BuildContext context) {
    
    return BodyProcess(
      color: const Color.fromARGB(255, 64, 148, 67),
      incProgress: 0,
      child: _procesar()
    );
  }

  ///
  Widget _procesar() {
    
    final conn = context.read<BrowserProvider>();
    final proc = context.read<ProcessProvider>();
    context.read<SocketConn>().isShowConfig = false;

    final lib = LibCheckConn(
      connProv: conn,
      procProv: proc,
      console: context.read<TerminalProvider>(),
    );

    return StreamBuilder<String>(
      stream: lib.make(),
      initialData: 'Probando Conexiones',
      builder: (_, AsyncSnapshot<String> res) {
        
        return Texto(
          txt: res.data!, sz: 15,
          txtC: const Color.fromARGB(255, 223, 223, 223),
          isCenter: true,
        );
      },
    );
  }

}