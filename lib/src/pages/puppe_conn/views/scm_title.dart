import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scm/src/pages/login_page.dart';
import 'package:scm/src/pages/portada_page.dart';

import '../../../providers/socket_conn.dart';
import '../../../widgets/texto.dart';

class ScmTitle extends StatelessWidget {

  final ValueChanged<void> onClose;
  const ScmTitle({
    Key? key,
    required this.onClose
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Texto(
                txt: 'SCM',
                txtC: Color.fromARGB(255, 61, 54, 54),
                sz: 80, isCenter: true, isBold: true,
              ),
              Positioned(
                top: 0, left: 0,
                child: IconButton(
                  onPressed: () {
                    final nav = Navigator.of(context);
                    final sock = context.read<SocketConn>();

                    if(nav.canPop()) {
                      nav.pop();
                    }else{
                      Widget child = const PortadaPage();
                      if(!sock.isLoged) {
                        child = const LoginPage();
                      }
                      nav.pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => child
                        )
                      );
                    }
                    onClose(null);
                  },
                  icon: const Icon(Icons.close, color: Color.fromARGB(255, 236, 167, 39),)
                )
              )
            ],
          ),
        ),
        const Texto(txt: 'SERVIDOR CENTRAL DE MENSAJERÍA', txtC: Colors.blue),
        const SizedBox(height: 10)
      ],
    );
  }
}