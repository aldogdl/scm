import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../body_process.dart';
import '../stream_process.dart';
import '../../../providers/terminal_provider.dart';
import '../../../providers/process_provider.dart';
import '../../../services/puppetter/libs/vars_search_contact.dart';
import '../../../services/puppetter/libs/lib_search_ctac.dart';
import '../../../services/puppetter/providers/browser_provider.dart';

class SearchContact extends StatefulWidget {

  final double maxW;
  final ValueChanged<String> onFinish;
  const SearchContact({
    Key? key,
    required this.maxW,
    required this.onFinish
  }) : super(key: key);

  @override
  State<SearchContact> createState() => _SearchContactState();
}

class _SearchContactState extends State<SearchContact> {

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
    
    late LibSeachCtac lib;
    late ProcessProvider pprov;
    if(!_isInit) {
      _isInit = true;
      _cantPerStep = widget.maxW / FindCtac.values.length;
      pprov = context.read<ProcessProvider>();
      lib = LibSeachCtac(
        wprov: context.read<BrowserProvider>(),
        pprov: pprov,
        console: context.read<TerminalProvider>(),
        incProgress: (_) => addP()
      );
    }

    return StreamProcess(
      make: lib.make(),
      initialData: 'Buscando ${pprov.receiverCurrent.curc}',
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