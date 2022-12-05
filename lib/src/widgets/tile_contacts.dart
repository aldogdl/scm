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
          Row(
            children: [
              Texto(
                txt: title,
                txtC: colorSubT,
                isBold: (isDark) ? true : false
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5, vertical: 2
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 46, 47, 49),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Texto(
                  txt: '$idTarget', txtC: Colors.white, sz: 10,
                ),
              )
            ],
          ),
          const Divider(height: 12),
          if(target.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Texto(txt: 'Campaña: $idCamp', sz: 13, txtC: const Color.fromARGB(255, 170, 170, 170) ),
                const Spacer(),
                Texto(txt: 'Tipo: ${target.toUpperCase()}', sz: 12, txtC: const Color.fromARGB(255, 170, 170, 170)),
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