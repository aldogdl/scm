import 'package:flutter/material.dart';

import '../entity/scm_entity.dart';
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

    String curc = receiver.receiver.curc;
    curc = curc.replaceAll('anet', '').toUpperCase();

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
              msg: '[AVO] -> ${receiver.rName}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Texto(
                    txt: receiver.nombre,
                    txtC: const Color.fromARGB(255, 177, 177, 177)
                  ),
                  Texto(
                    txt: receiver.receiver.empresa, sz: 11,
                    txtC: const Color.fromARGB(255, 149, 151, 243)
                  )
                ],
              )
            ),
            const Spacer(),
            Texto(
              txt: curc, sz: 12,
              txtC: const Color.fromARGB(255, 145, 255, 0)
            )
          ],
        ),
        Divider(color: Colors.grey.withOpacity(0.5),)
      ],
    );
  }

}