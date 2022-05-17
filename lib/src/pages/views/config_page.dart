import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../../config/sng_manager.dart';
import '../../entity/request_event.dart';
import '../../providers/process_provider.dart';
import '../../providers/socket_conn.dart';
import '../../widgets/my_terminal_header.dart';
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
  String _seccion = 'more';
  bool _isInit = false;

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _sock = context.read<SocketConn>();
    }

    return _body();
  }

  ///
  Widget _body() {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const TituloSeccion(titulo: 'Configuración'),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 10),
              if(context.read<SocketConn>().isLoged)
                SizedBox(
                  height: 25, width: 100,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.green
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10
                        )
                      )
                    ),
                    onPressed: () => setState(() {
                      _seccion = (_seccion == 'info') ? 'more' : 'info';
                    }),
                    child: Texto(
                      txt: (_seccion == 'more')
                      ? 'VER MAS...'
                      : 'VER DATA',
                      txtC: Colors.black,
                      sz: 13,
                    )
                  ),
                ),
              const Spacer(),
              const CheckBoxConnection(),
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
            ..._moreIfo()
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
  Widget _tileBtnAcc({
    required IconData icon,
    required String label,
    required Function fnc
  }) {

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: TextButton.icon(
          icon: Icon(icon),
          label: Texto(txt: label),
          onPressed: () => fnc(),
        ),
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
  List<Widget> _moreIfo() {

    if(_seccion == 'more') {
      return _infoConn();
    }else{
      return _otros();
    }
  }

  ///
  List<Widget> _otros() {

    return [
      _tileBtnAcc(
        icon: Icons.sensors_off_rounded,
        label: (!context.watch<ProcessProvider>().isStopedByUserRemoto)
        ? '[SCM] Detener Monitoreo Remoto'
        : '[SCM] Re-Iniciar Monitoreo Remoto',
        fnc: () => _stopWatchRemoto(
          context.read<ProcessProvider>()
        )
      ),
      _tileBtnAcc(
        icon: Icons.remove_red_eye,
        label:  (!context.watch<ProcessProvider>().isStopedByUserFiles)
        ? '[SCM] Detener Monitoreo  de Archivos'
        : '[SCM] Re-Iniciar Monitoreo  de Archivos',
        fnc: () => _stopWatchFiles(
          context.read<ProcessProvider>()
        ),
      ),
      _tileBtnAcc(
        icon: Icons.cleaning_services_rounded,
        label: '[HARBI] Limpiar Pantalla',
        fnc: () => _harbiClsScreen()
      ),
      _tileBtnAcc(
        icon: Icons.connect_without_contact,
        label: '[HARBI] Ping ( Prueba de conexión )',
        fnc: () => _harbiPing()
      ),
      const Spacer(),
      Container(
        width: appWindow.size.width,
        height: MediaQuery.of(context).size.height * 0.15,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TerminalHeader(
              showClose: false,
              onViewCode: (_){},
              onClean: (_) {
                _sock.msgErr = '';
              }
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Texto(
                  txt: context.watch<SocketConn>().msgErr,
                  txtC: Colors.blueGrey,
                ),
              )
            )
          ],
        ),
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
        val: '${_globals.idUser}'
      ),
      _tileDataConn(
        ico: Icons.circle, tit: 'Clave única de registro C.:',
        val: _globals.curc
      ),
    ];
  }

  ///  
  Future<void> _stopWatchRemoto(ProcessProvider prov) async {
    prov.isStopedByUserRemoto = !prov.isStopedByUserRemoto;
  }

  ///    
  Future<void> _stopWatchFiles(ProcessProvider prov) async {
    prov.isStopedByUserFiles = !prov.isStopedByUserFiles;
  }

  ///
  void _harbiPing() async {
    await _sock.ping();
  }

  ///
  void _harbiClsScreen() {
    _sock.send(RequestEvent(event: 'cls', fnc: '', data: {}));
  }
}