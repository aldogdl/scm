import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../../config/sng_manager.dart';
import '../../providers/socket_conn.dart';
import '../../widgets/titulo_seccion.dart';
import '../../vars/globals.dart';
import '../../widgets/checkbox_connection.dart';
import '../../widgets/texto.dart';

class ConfigPage extends StatefulWidget {

  const ConfigPage({Key? key}) : super(key: key);

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {

  final Globals _globals = getSngOf<Globals>();

  late SocketConn _sock;
  bool _isInit = false;

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _sock = context.read<SocketConn>();
    }

    return Container(
      width: appWindow.size.width,
      height: appWindow.size.height,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const TituloSeccion(titulo: 'Configuración'),
          const SizedBox(height: 8),
          Row(
            children: const [
              Spacer(),
              CheckBoxConnection(),
            ],
          ),
          _tileDataConn(
            ico: Icons.circle, tit: 'Nombre de la RED:',
            val: _globals.wifiName
          ),
          _tileDataConn(
            ico: Icons.circle, tit: 'La IP de este Dipositivo:',
            val: _globals.myIp
          ),
          if(!_sock.isLoged)
            ..._sinLogged()
          else
            ..._infoConn()
        ],
      ),
    );
  }

  ///
  Widget _tileDataConn({
    required IconData ico,
    required String tit,
    required String val,
  }) {

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 5
      ),
      constraints: BoxConstraints.expand(
        width: appWindow.size.width,
        height: 38
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Colors.amber),
              const SizedBox(width: 10),
              Texto(txt: tit),
              const Spacer(),
              Texto(txt: val, txtC: Colors.white),
            ],
          )
        ],
      ),
    );
  }

  ///
  List<Widget> _sinLogged() {

    return [
      const SizedBox(height: 50),
      Icon(Icons.unpublished_rounded, size: 100, color: Colors.white.withOpacity(0.1)),
      const SizedBox(height: 10),
      const Texto(
        txt: 'Necesitas autenticarte para recabar más información',
        sz: 18, isCenter: true,
      )
    ];
  }

  ///
  List<Widget> _infoConn() {

    late Uri uri;
    String serverRemoto = 'Sin Datos';
    if(_globals.ipDbs.containsKey('base_r')) {
      uri= Uri.parse(_globals.ipDbs['base_r']);
      serverRemoto = uri.host;
    }

    String serverLocal = 'Sin Datos';
    if(_globals.ipDbs.containsKey('base_l')) {
      uri= Uri.parse(_globals.ipDbs['base_l']);
      serverLocal = uri.host;
    }

    String puertoHarbi = 'Sin Datos';
    if(_globals.ipDbs.containsKey('port_h')) {
      puertoHarbi = '${_globals.ipDbs['port_h']}';
    }

    return [

      _tileDataConn(
        ico: Icons.circle, tit: 'La IP de HARBI:',
        val: _globals.ipHarbi
      ),
      _tileDataConn(
        ico: Icons.circle, tit: 'ID de Conexión a HARBI:',
        val: '${_sock.idConn}'
      ),
      _tileDataConn(
        ico: Icons.circle, tit: 'Url Remota:',
        val: serverRemoto
      ),
      _tileDataConn(
        ico: Icons.circle, tit: 'Url Local:',
        val: serverLocal
      ),
      _tileDataConn(
        ico: Icons.circle, tit: 'Puerto a HARBI:',
        val: puertoHarbi
      ),
      _tileDataConn(
        ico: Icons.circle, tit: 'ID REG UNICO:',
        val: '${_globals.user.id}'
      ),
      _tileDataConn(
        ico: Icons.circle, tit: 'Clave única de registro C.:',
        val: _globals.user.curc
      ),
    ];
  }

}