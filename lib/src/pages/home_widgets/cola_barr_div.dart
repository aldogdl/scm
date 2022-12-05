import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scm/src/providers/process_provider.dart';

import '../../widgets/texto.dart';

class ColaBarrDiv extends StatelessWidget {

  const ColaBarrDiv({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5
      ),
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5)
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            color: Colors.black,
            offset: Offset(0, 1)
          )
        ]
      ),
      child: Row(
        children: [
          const Icon(Icons.send, size: 13, color: Colors.purple),
          const SizedBox(width: 10),
          Selector<ProcessProvider, String>(
            selector: (_, provi) => provi.tituloColaBarr,
            builder: (_, s, __) {
              return Texto(txt: s, txtC: Colors.black, sz: 12);
            },
          ),
          const Spacer(),
          Row(
            children: [
              Selector<ProcessProvider, int>(
                selector: (_, provi) => provi.sended,
                builder: (_, s, __) {
                  return Texto(
                    txt: '$s ',
                    txtC: Colors.black, sz: 12
                  );
                },
              ),
              Selector<ProcessProvider, int>(
                selector: (_, provi) => provi.enTray,
                builder: (_, s, __) {
                  return Texto(
                    txt: 'de $s Campañas',
                    txtC: Colors.black, sz: 12
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}