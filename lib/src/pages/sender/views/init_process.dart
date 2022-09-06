import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../body_process.dart';
import '../../../widgets/texto.dart';
import '../../../providers/terminal_provider.dart';
import '../../../providers/process_provider.dart';
import '../../../services/puppetter/libs/lib_init_process.dart';
import '../../../services/puppetter/libs/vars_search_contact.dart';

class InitProcess extends StatefulWidget {

  final double maxW;
  final ValueChanged<String> onFinish;
  const InitProcess({
    Key? key,
    required this.maxW,
    required this.onFinish,
  }) : super(key: key);

  @override
  State<InitProcess> createState() => _InitProcessState();
}

class _InitProcessState extends State<InitProcess> {

  final _incProgress = ValueNotifier<double>(0);

  bool _isInit = false;
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
          color: const Color.fromARGB(255, 64, 148, 67),
          incProgress: val,
          child: child!,
        );
      },
      child: _procesar(),
    );
  }

  ///
  Widget _procesar() {
    
    late LibInitProcess lib;
    if(!_isInit) {
      _isInit = true;
      _cantPerStep = widget.maxW / FindCtac.values.length;
      final prov = context.read<ProcessProvider>();

      lib = LibInitProcess(
        incProgress: (_) => addP(),
        pprov: prov,
        console: context.read<TerminalProvider>(),
        onFinish: (fin) => widget.onFinish(fin)
      );
    }

    return StreamBuilder<String>(
      stream: lib.make(),
      initialData: 'Recuperar Datos',
      builder: (_, AsyncSnapshot<String> res) {

        widget.onFinish(res.data!);
        return Texto(
          txt: res.data!, sz: 15,
          txtC: const Color.fromARGB(255, 223, 223, 223),
          isCenter: true,
        );
      },
    );
  }

  /// Incrementamos la barra de progreeso
  void addP() {
    if(mounted) {
      _incProgress.value = _incProgress.value + _cantPerStep;
    }
  }

}