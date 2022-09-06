import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'texto.dart';
import '../providers/terminal_provider.dart';

class TerminalHeader extends StatelessWidget {

  final bool showClose;
  final ValueChanged<void> onClean;
  final ValueChanged<void> onViewCode;
  const TerminalHeader({
    Key? key,
    required this.onClean,
    required this.onViewCode,
    this.showClose = true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final provW = context.watch<TerminalProvider>();

    return Container(
      padding: const EdgeInsets.all(5),
      color: const Color(0xFFFFFFFF).withOpacity(0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(showClose)
            Texto(
              txt: '[${provW.taskTerminal.length}] LA TERMINAL',
              txtC: Colors.grey, sz: 13, isBold: false
            )
          else
            const Texto(
              txt: 'LA TERMINAL',
              txtC: Colors.grey, sz: 13, isBold: false
            ),
          const Spacer(),
          IconButton(
            padding: const EdgeInsets.all(0),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(
              maxHeight: 18
            ),
            onPressed: () => onViewCode(null),
            icon: const Icon(Icons.code, size: 18)
          ),
          IconButton(
            padding: const EdgeInsets.all(0),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(
              maxHeight: 18
            ),
            onPressed: () => onClean(null),
            icon: const Icon(Icons.delete_sweep_outlined, size: 18)
          ),
          if(showClose)
            IconButton(
              padding: const EdgeInsets.all(0),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(
                maxHeight: 18
              ),
              onPressed: () => context.read<TerminalProvider>().terminalIsMini = !provW.terminalIsMini,
              icon: Icon(
                (!provW.terminalIsMini) ? Icons.close : Icons.home_max_outlined,
                size: 18,
              )
            ),
        ],
      ),
    );
  }
}