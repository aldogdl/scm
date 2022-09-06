import 'package:flutter/material.dart';

import '../services/my_utils.dart';
import 'texto.dart';

class TileContacts extends StatelessWidget {

  final int idCamp;
  final String title;
  final String nombre;
  final String subTi;
  final String celular;
  final String curc;
  final String target;
  final int idTarget;
  final bool isCurrent;
  final bool isDark;

  const TileContacts({
    Key? key,
    required this.title,
    required this.nombre,
    required this.subTi,
    required this.celular,
    required this.curc,
    required this.idCamp,
    this.target = '',
    this.idTarget = 0,
    this.isCurrent = false,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    bool isBold = (subTi.contains('curc')) ? true : false;
    Color colorSubT = (isDark) ? const Color.fromARGB(255, 29, 29, 29) : const Color.fromARGB(255, 149, 151, 243);
    colorSubT = (subTi.contains('CURC')) ? Colors.white : colorSubT;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Texto(
            txt: title,
            txtC: colorSubT,
            isBold: (isDark) ? true : false
          ),
          const Divider(height: 6),
          if(target.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Texto(txt: 'Tipo: ${target.toUpperCase()}', sz: 12, txtC: const Color.fromARGB(255, 155, 154, 154)),
                const SizedBox(width: 8),
                Texto(txt: 'Id: $idTarget', sz: 12, txtC: const Color.fromARGB(255, 155, 154, 154) ),
                const SizedBox(width: 8),
                Texto(txt: 'Campaña: $idCamp', sz: 13, txtC: const Color.fromARGB(255, 22, 199, 28) ),
              ]
            ),
          Texto(txt: nombre,
            txtC: Colors.white
          ),
          if(isCurrent)
            Row(
              children: [
                if(subTi.startsWith('Enviando'))
                  Texto(
                    txt: subTi,
                    txtC: const Color.fromARGB(255, 73, 219, 78)
                  )
                else
                  Texto(
                    txt: 'Cel: ${MyUtils.formatTel(subTi)}',
                    txtC: const Color.fromARGB(255, 73, 219, 78)
                  ),
                const Spacer(),
                Texto(
                  txt: curc,
                  sz: 16,
                  txtC: Colors.yellow
                ),
              ],
            )
          else
            Row(
              children: [
                Texto(
                  txt: subTi,
                  txtC: colorSubT,
                  isBold: isBold,
                ),
                const Spacer(),
                Texto(
                  txt: MyUtils.formatTel(celular),
                  txtC: (isDark) ? const Color.fromARGB(255, 0, 0, 0) : Colors.blue,
                  isBold: (isDark) ? true : false
                ),
              ],
            )
        ],
      ),
    );
  }
}