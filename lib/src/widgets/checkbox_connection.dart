import 'package:flutter/material.dart';

import '../config/sng_manager.dart';
import '../vars/globals.dart';
import 'texto.dart';

class CheckBoxConnection extends StatefulWidget {

  const CheckBoxConnection({Key? key}) : super(key: key);

  @override
  State<CheckBoxConnection> createState() => _CheckBoxConnectionState();
}

class _CheckBoxConnectionState extends State<CheckBoxConnection> {
  
  final Globals _globals = getSngOf<Globals>();
  
  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Texto(txt: 'Trabajar con Internet'),
        const SizedBox(width: 5),
        Checkbox(
          value: !_globals.isLocalConn,
          activeColor: Colors.transparent,
          onChanged: (val) {
            setState(() {
              val = (val == null) ? _globals.isLocalConn : val;
              _globals.isLocalConn = !val!;
            });
          }
        ),
      ],
    );
  }
}