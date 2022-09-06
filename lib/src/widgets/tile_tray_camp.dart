import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../services/my_utils.dart';
import 'texto.dart';

class TileTrayCamp extends StatelessWidget {

  final int idCurrent;
  final Map<String, dynamic> dataTray;
  const TileTrayCamp({
    Key? key,
    required this.idCurrent,
    required this.dataTray,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      width: appWindow.size.width,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        border: Border.all(color: const Color.fromARGB(255, 57, 75, 83))
      ),
      child: Row(
        children: [
          _avatar(),
          Expanded(
            child: _dataCamp(),
          ),
        ],
      ),
    );
  }

  ///
  Widget _avatar() {

    bool isCurrent = false;
    if(dataTray['id'] == idCurrent) {
      isCurrent = true;
    }
    if(dataTray.containsKey('isCurrent')) {
      isCurrent = dataTray['isCurrent'];
    }

    return Column(
      children: [
        Container(
          width: 45, height: 38,
          decoration: BoxDecoration(
            color: (isCurrent)
            ? const Color.fromARGB(255, 90, 91, 124)
            : const Color.fromARGB(255, 135, 136, 184),
            border: const Border(
              right: BorderSide(color: Color.fromARGB(255, 76, 99, 110))
            )
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                top: 0,
                child: Icon(
                  Icons.email, size: 30, color: Color.fromARGB(255, 150, 207, 235),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 2
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 79, 93, 133),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Texto(
                    txt: '${dataTray['id']}', txtC: Colors.white, sz: 10,
                  ),
                )
              )
            ],
          )
        )
      ],
    );
  }

  ///
  Widget _dataCamp() {

    bool isPrio = false;
    bool isCurrent = false;
    if(dataTray['id'] == idCurrent) {
      isPrio = true;
      isCurrent = true;
    }

    if(dataTray.containsKey('isCurrent')) {
      isCurrent = dataTray['isCurrent'];
    }
    if(dataTray.containsKey('isPrio')) {
      isPrio = dataTray['isPrio'];
    }

    final f = _extractFecha(dataTray['createdAt']);
    String empresa = dataTray['emiter']['empresa'].toUpperCase();
    if(empresa.length > 25) {
      empresa = empresa.substring(0, 25);
      empresa = '$empresa...';
    }
    int cut = 15;
    if(dataTray['id'] > 9999) {
      cut = 10;
    }
    String campaing = dataTray['campaing']['titulo'];
    if(campaing.length > cut) {
      campaing = campaing.substring(0, cut);
      campaing = '$campaing...';
    }
    final sended = dataTray['toSend'].length - dataTray['noSend'].length;
    
    return Container(
      height: 38,
      padding: const EdgeInsets.only(
        left: 5, right: 5
      ),
      decoration: const BoxDecoration(
        color: Colors.grey,
        border: Border(
          left: BorderSide(color: Color.fromARGB(255, 195, 196, 207))
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              if(isPrio)
                ...[
                  const Icon(Icons.start, size: 15, color: Colors.yellowAccent),
                  const SizedBox(width: 4)
                ],
              Expanded(
                child: Texto(
                  txt: empresa, sz: 13,
                  txtC: const Color.fromARGB(255, 60, 78, 87),
                  isBold: (isCurrent) ? true : false,
                ),
              ),
              Texto(
                txt: '$sended-${dataTray['toSend'].length}',
                sz: 11, txtC: const Color.fromARGB(255, 31, 40, 44),
                isBold: (isCurrent) ? true : false,
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 3),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              border: Border(
                top: BorderSide(color: Colors.black.withOpacity(0.3))
              )
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Texto(
                  txt: 'Prio.: ${dataTray['campaing']['priority']}', sz: 11.5,
                  txtC: const Color.fromARGB(255, 63, 67, 121)
                ),
                const SizedBox(width: 8),
                Texto(
                  txt: campaing, sz: 13,
                  txtC: const Color.fromARGB(255, 37, 47, 53)
                ),
                const Spacer(),
                Texto(
                  txt: f['tiempo'], sz: 11, isBold: true,
                  txtC: const Color.fromARGB(255, 37, 47, 53)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  ///
  Map<String, dynamic> _extractFecha(dynamic fecha) {

    var date = DateTime.now();
    if(fecha.runtimeType == String) {
      date = DateTime.parse(fecha);
    }else{
      date = fecha['createdAt'];
    }
    return MyUtils.getFecha(fecha: date);
  }

}