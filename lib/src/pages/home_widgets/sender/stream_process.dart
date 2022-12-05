import 'package:flutter/material.dart';

import '../../../widgets/texto.dart';

class StreamProcess extends StatelessWidget {

  final Stream<String> make;
  final String initialData;
  final ValueChanged<String> onYield;

  const StreamProcess({
    Key? key,
    required this.make,
    required this.initialData,
    required this.onYield
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<String>(
      stream: make,
      initialData: initialData,
      builder: (_, AsyncSnapshot res) {

        String txt = res.data ?? initialData;
        if(res.data.toString().startsWith('ERROR')) {
          txt = 'UPS! Ocurrio un Error...';
        }
        onYield(res.data);
        return Texto(
          txt: txt, sz: 15,
          txtC: const Color.fromARGB(255, 223, 223, 223),
          isCenter: true,
        );
      },
    );
  }
}