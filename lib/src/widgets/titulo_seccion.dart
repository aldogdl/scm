import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scm/src/providers/socket_conn.dart';
import 'package:scm/src/widgets/texto.dart';

class TituloSeccion extends StatelessWidget {

  final String titulo;
  const TituloSeccion({
    Key? key,
    required this.titulo
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        const Divider(color: Color.fromARGB(255, 65, 65, 65), height: 1),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 24, 24, 24),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            )
          ),
          child: Row(
            children: [
              Expanded(
                child: Texto(
                  txt: titulo,
                  txtC: Colors.green,
                  isBold: true, isCenter: true,
                  sz: 16,
                ),
              ),
              IconButton(
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(
                  maxHeight: 20, maxWidth: 20
                ),
                onPressed: () {
                  context.read<SocketConn>().isShowConfig = false;
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.close, color: Colors.white, size: 18,
                )
              )
            ],
          )
        ),
      ],
    );
  }
}