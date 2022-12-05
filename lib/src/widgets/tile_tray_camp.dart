import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:scm/src/widgets/my_tool_tip.dart';

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

    if(dataTray.isEmpty) {
      return const SizedBox();
    }
    
    return Container(
      width: appWindow.size.width,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        border: Border.all(color: const Color.fromARGB(255, 57, 75, 83))
      ),
      child: Column(
        children: [
          Row(
            children: [
              _avatar(),
              Expanded(
                child: _dataCamp(),
              ),
            ],
          ),
          _pie()
        ],
      )
    );
  }

  ///
  Widget _avatar() {

    String idTarget = '0';
    if(dataTray.containsKey(dataTray['target'])) {
      idTarget = '${dataTray[dataTray['target']]['id']}';
    }else{
      if(dataTray.containsKey('data')) {
        if(dataTray['data'].containsKey['id']) {
          idTarget = '${dataTray['data']['id']}';
        }
      }
    }

    return Column(
      children: [
        Container(
          width: 45, height: 38,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 135, 136, 184),
            border: Border(
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
                    color: const Color.fromARGB(255, 46, 47, 49),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Texto(
                    txt: idTarget,
                    txtC: Colors.white, sz: 10,
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

    String nombre = dataTray['emiter']['nombre'];
    if(nombre.length > 25) {
      nombre = nombre.substring(0, 25);
      nombre = '$nombre...';
    }
    
    String remi = dataTray['remiter']['nombre'];
    if(remi.length > 12) {
      remi = remi.substring(0, 12);
      remi = '$remi...';
    }

    Map<String, dynamic> data = {};
    if(dataTray.containsKey(dataTray['target'])) {
      data = dataTray[dataTray['target']];
    }else{
      if(dataTray.containsKey('data')) {
        if(dataTray['data'].containsKey['id']) {
          data = dataTray['data'];
        }
      }
    }

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
              Texto(
                txt: '${data['modelo']}', sz: 13,
                txtC: const Color.fromARGB(255, 60, 78, 87),
                isBold: true
              ),
              const SizedBox(width: 10),
              Texto(
                txt: '${data['anio']}', sz: 13,
                txtC: const Color.fromARGB(255, 60, 78, 87),
                isBold: true
              ),
              const Spacer(),
              Texto(
                txt: '${data['marca']}',
                sz: 11, txtC: const Color.fromARGB(255, 31, 40, 44),
                isBold: true
              ),
              Texto(
                txt: '  Pzas. ${data['piezas']}',
                sz: 11, txtC: const Color.fromARGB(255, 31, 40, 44),
                isBold: true
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
                MyToolTip(
                  msg: dataTray['emiter']['empresa'],
                  child: Texto(
                    txt: 'E: $nombre', sz: 11.5, isBold: true,
                    txtC: const Color.fromARGB(255, 63, 67, 121)
                  ),
                ),
                const Spacer(),
                MyToolTip(
                  msg: dataTray['remiter']['nombre'],
                  child: Texto(
                    txt: 'R: $remi', sz: 11,
                    txtC: const Color.fromARGB(255, 63, 67, 121)
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  ///
  Widget _pie() {

    final f = _extractFecha(dataTray['created']);
    
    return Row(
      children: [
        Expanded(
          child: Texto(
            txt: dataTray['titulo'], sz: 13,
            txtC: const Color.fromARGB(255, 34, 45, 51),
            isBold: false
          )
        ),
        Texto(
          txt: 'R: ${dataTray['toSend']}',
          sz: 11, txtC: const Color.fromARGB(255, 37, 47, 53),
          isBold: true
        ),
        const SizedBox(width: 5),
        Texto(
          txt: 'T:${f['tiempo']}', sz: 11, isBold: true,
          txtC: const Color.fromARGB(255, 0, 0, 0)
        ),
        const SizedBox(width: 8),
      ],
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