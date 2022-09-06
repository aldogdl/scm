import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../body_process.dart';
import '../../../providers/process_provider.dart';
import '../../../providers/terminal_provider.dart';
import '../../../services/puppetter/libs/vars_search_contact.dart';
import '../../../services/puppetter/libs/lib_fin_process.dart';
import '../../../widgets/texto.dart';

class FinProcess extends StatefulWidget {

  final double maxW;
  final ValueChanged<String> onFinish;
  const FinProcess({
    Key? key,
    required this.maxW,
    required this.onFinish,
  }) : super(key: key);

  @override
  State<FinProcess> createState() => _FinProcessState();
}

class _FinProcessState extends State<FinProcess> {

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
          color: const Color.fromARGB(255, 45, 102, 47),
          incProgress: val,
          child: child!,
        );
      },
      child: _procesar(),
    );
  }

  ///
  Widget _procesar() {
    
    late LibFinProcess lib;
    late final ProcessProvider pprov;

    if(!_isInit) {
      _isInit = true;
      _cantPerStep = widget.maxW / FindCtac.values.length;
      pprov  = context.read<ProcessProvider>();

      lib = LibFinProcess(
        forceDrash: false,
        pprov: pprov,
        console: context.read<TerminalProvider>(),
        incProgress: (_) => addP(),
        onFinish: (fin) => widget.onFinish(fin)
      );
    }

    return StreamBuilder<String>(
      stream: lib.make(),
      initialData: '',
      builder: (_, AsyncSnapshot res) {

        widget.onFinish(res.data);
        return Texto(
          txt: res.data, sz: 15,
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