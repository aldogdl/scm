import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entity/scm_entity.dart';
import '../providers/process_provider.dart';
import 'my_tool_tip.dart';
import 'texto.dart';

class TileAwaitCamp extends StatelessWidget {

  final ScmEntity receiver;
  final int index;
  final Widget childCheck;
  const TileAwaitCamp({
    Key? key,
    required this.receiver,
    required this.index,
    required this.childCheck,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20, height: 15,
                  child: childCheck,
                ),
                const SizedBox(height: 2),
                Texto(
                  txt: '# $index', sz: 12, isCenter: true,
                  txtC: const Color.fromARGB(255, 145, 255, 0)
                ),
              ],
            ),
            const SizedBox(width: 8),
            MyToolTip(
              msg: '-> ${receiver.nombre}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Texto(
                    txt: receiver.nombre,
                    txtC: const Color.fromARGB(255, 224, 224, 224)
                  ),
                  Texto(
                    txt: receiver.receiver.empresa, sz: 11,
                    txtC: const Color.fromARGB(255, 149, 151, 243)
                  )
                ],
              )
            ),
            const Spacer(),
            Selector<ProcessProvider, bool>(
              selector: (_, prov) => prov.isPause,
              builder: (_, val, __) {
                return Texto(
                  txt: (val) ? 'En Pausa' : 'En cola', sz: 12,
                  txtC: const Color.fromARGB(255, 145, 255, 0)
                );
              },
            ),
          ],
        ),
        Divider(color: Colors.grey.withOpacity(0.5),)
      ],
    );
  }
}