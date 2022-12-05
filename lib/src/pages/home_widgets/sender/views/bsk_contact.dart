import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../body_process.dart';
import '../stream_process.dart';
import '../../../../providers/process_provider.dart';
import '../../../../providers/terminal_provider.dart';
import '../../../../services/puppetter/libs/lib_bsk_ctac.dart';
import '../../../../services/puppetter/providers/browser_provider.dart';

class BskContact extends StatefulWidget {

  final double maxW;
  final ValueChanged<String> onFinish;
  const BskContact({
    Key? key,
    required this.maxW,
    required this.onFinish
  }) : super(key: key);

  @override
  State<BskContact> createState() => _BskContactState();
}

class _BskContactState extends State<BskContact> {

  final _incProgress = ValueNotifier<double>(0);

  double _cantPerStep = 0.0;

  @override
  void dispose() {
    _incProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return ValueListenableBuilder<double>(
      valueListenable: _incProgress,
      builder: (_, val, child) {

        return BodyProcess(
          incProgress: val,
          color: Colors.green,
          child: child!,
        );
      },
      child: _procesar(),
    );
  }

  ///
  Widget _procesar() {

    _cantPerStep = widget.maxW / TaskContac.values.length;
    final lib = LibBskCtac(
      incProgress: (_) => addP(),
      wprov: context.read<BrowserProvider>(),
      pprov: context.read<ProcessProvider>(),
      console: context.read<TerminalProvider>(),
    );

    return StreamProcess(
      make: lib.make(),
      initialData: 'Caja de Busqueda...',
      onYield: (String res) => widget.onFinish(res)
    );
  }

  /// Incrementamos la barra de progreeso
  void addP() {
    if(mounted) {
      _incProgress.value = _incProgress.value + _cantPerStep;
    }
  }

}