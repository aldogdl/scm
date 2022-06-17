import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:network_info_plus/network_info_plus.dart';

import '../config/sng_manager.dart';
import '../services/my_http.dart';
import '../services/get_paths.dart';
import '../vars/globals.dart';
import '../entity/request_event.dart';

class SocketConn extends ChangeNotifier {

  final Globals globals = getSngOf<Globals>();

  final info = NetworkInfo();
  final String _app = 'SCM';

  String pin = '';
  IOWebSocketChannel? _socket;
  IOWebSocketChannel get socket => _socket!;

  bool _isLocalConn = true;
  bool get isLocalConn => _isLocalConn;
  set isLocalConn(bool conn) {
    _isLocalConn = conn;
    globals.isLocalConn = _isLocalConn;
    notifyListeners();
  }

  bool _isLoged = false;
  bool get isLoged => _isLoged;
  set isLoged(bool logined) {
    _isLoged = logined;
    notifyListeners();
  }

  bool _isConectedSocked = false;
  bool get isConnectedSocked => _isConectedSocked;
  void setIsConnectedSocked(bool conn) => _isConectedSocked = conn;

  String _username = 'Anónimo';
  String get username => _username;
  set username(String connected) {
    _username = connected;
    notifyListeners();
  }

  ///
  String _msgCron = 'X';
  String get msgCron => _msgCron;
  void setMsgCronWithoutNotified(String msg) {
    _msgCron = msg;
  }

  set msgCron(String msg) {
    _msgCron = msg;
    notifyListeners();
  }

  ///
  List<Map<String, dynamic>> _manifests = [];
  List<Map<String, dynamic>> get manifests => _manifests;
  set manifests(List<Map<String, dynamic>> msg) {
    _manifests = msg;
    notifyListeners();
  }

  void addManifest(Map<String, dynamic> msg) {
    _manifests.insert(0, msg);
    notifyListeners();
  }

  /// Usado para notificar en el status bar un cambio de version del centinela
  bool _alertCV = false;
  bool get alertCV => _alertCV;
  set alertCV(bool msg) {
    _alertCV = msg;
    notifyListeners();
  }

  ///
  String _msgErr = '';
  String get msgErr => _msgErr;
  void setMsgWithoutNotified(String msg) {
    _msgErr = msg;
  }

  set msgErr(String msg) {
    _msgErr = msg;
    notifyListeners();
  }

  ///
  int _idConn = 0;
  int get idConn => _idConn;
  set idConn(int conn) {
    _idConn = conn;
    notifyListeners();
  }

  /// Utilizado para indicar una nueva ip para la base de datos o servidor local
  String _hasErrWithIpDbLocal = '';
  String get hasErrWithIpDbLocal => _hasErrWithIpDbLocal;
  set hasErrWithIpDbLocal(String clv) {
    _hasErrWithIpDbLocal = clv;
    notifyListeners();
  }

  String _verCentiCurrent = '0';

  ///
  void cerrarConection() {
    setIsConnectedSocked(false);
    globals.ipHarbi = '';
    globals.password = '';
    username = 'Anónimo';
    idConn = 0;
    _verCentiCurrent = '0';
    close();
  }

  ///
  void close() {
    if (_socket != null) {
      _socket!.sink.close(status.normalClosure);
    }
    setIsConnectedSocked(false);
    _socket == null;
  }

  ///
  Future<void> getNameRed() async {

    if (globals.myIp.isEmpty) {
      globals.wifiName = await info.getWifiName() ?? 'Oculta';
      globals.myIp = await info.getWifiIP() ?? '';
      notifyListeners();
    }
  }

  ///
  Future<bool> ping() async {

    int intentos = 1;
    bool abort = false;
    bool isCon = checkConeccion();

    if (!isCon) {
      if (globals.ipHarbi.isEmpty) {
        await getIpConnectionToHarbi();
      }
      _socket = null;
      pin = '';

      await Future.doWhile(() async {
        await _conectar();
        await Future.delayed(const Duration(milliseconds: 1000));
        if (pin == 'ok') {
          return false;
        }
        if (intentos >= 5) {
          abort = true;
          msgErr = 'No se alcanzó una conexión con HARBI';
          return false;
        }
        intentos++;
        return true;
      });
    }

    abort = false;
    intentos = 1;
    final event = RequestEvent(event: 'ping', fnc: 'make', data: {});
    await Future.doWhile(() async {
      send(event);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (msgErr.startsWith('ping')) {
        if (msgErr == 'ping-ok') {
          return false;
        } else {
          abort = true;
          return false;
        }
      }

      if (intentos >= 3) {
        abort = true;
        return false;
      }
      intentos++;
      return true;
    });

    return !abort;
  }

  /// Retorna true si la las variables de conexion estan correctas.
  bool checkConeccion() {

    bool isCon = isConnectedSocked;

    if (_socket == null) {
      isCon = false;
    } else {
      if (_socket!.innerWebSocket != null) {
        if (_socket!.innerWebSocket!.readyState == 3) {
          isCon = false;
        }
      } else {
        isCon = false;
      }
    }
    return isCon;
  }

  ///
  void xRevisarConectarAHarbi(RequestEvent event) {
    if (event.event == 'initConnection' && !isConnectedSocked) {
      if (event.data.containsKey('password')) {
        if (event.data['password'].isEmpty) {
          msgErr = 'Necesitas Password';
          return;
        } else {
          globals.password = event.data['password'];
          if (event.data.containsKey('username')) {
            globals.curc = event.data['username'];
          }
        }
      }
      _socket = null;
    }

    if (event.event == 'initConnection' && isConnectedSocked) {
      close();
      return;
    }
  }

  ///
  void send(RequestEvent event) async {

    event = await _fillMetaData(event);
    try {
      _socket!.sink.add(event.toSend());
    } catch (e) {
      msgErr = 'Se desconecto HARBI';
      return;
    }
  }

  ///
  Future<RequestEvent> _fillMetaData(RequestEvent event) async {

    var data = Map<String, dynamic>.from(event.data);
    data['id'] = idConn;
    data['app'] = _app;
    data['user'] = username;
    data['ip'] = globals.myIp;

    if (data.containsKey('username')) {
      if (data['username'].isEmpty) {
        data['username'] = globals.curc;
      }
    } else {
      data['username'] = globals.curc;
    }

    if (data.containsKey('password')) {
      if (data['password'].isEmpty) {
        data['password'] = globals.curc;
      }
    } else {
      data['password'] = globals.password;
    }
    event.data = data;
    return event;
  }

  /// Return TRUE si ubo un error o los intentos se agotaron
  Future<bool> awaitResponseSocket({
    required RequestEvent event,
    required String msgInit,
    required String msgExito
  }) async {
    
    bool abort = true;
    int intentos = 1;
    msgErr = msgInit;
    send(event);
    await Future.doWhile(() async {
      if (msgErr == msgExito) {
        abort = false;
        return false;
      }
      if (msgErr.contains('Error')) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 1000));
      if (intentos >= 5) {
        return false;
      }
      intentos++;
      return true;
    });

    return abort;
  }

  ///
  Future<void> _conectar() async {

    msgErr = 'Contactando a HARBI';
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      _socket = IOWebSocketChannel.connect(
          Uri.parse('ws://${globals.ipHarbi}:${globals.portHarbi}/socket'));
    } catch (e) {
      msgErr = 'Error al Intentar conectar a HARBI';
      return;
    }

    msgErr = 'Esperando Respuesta de Conexión';
    await Future.delayed(const Duration(milliseconds: 1000));
    if(isConnectedSocked){ return; }
    
    _socket!.stream.listen((event) {
      pin = 'ok';
      if(!isConnectedSocked) {
        setIsConnectedSocked(true);
      }
      _determinarEvento(Map<String, dynamic>.from(json.decode(event)));
    });
  }

  ///
  Future<void> _determinarEvento(Map<String, dynamic> response) async {

    if (response.containsKey('connId')) {
      idConn = response['connId'];
      return;
    }

    if (response.containsKey('event')) {
      if (response['event'] == 'ping') {
        _msgErr = (response['fnc'] == 'ok') ? 'ping-ok' : 'ping-er';
        return;
      }

      if (response['event'] == 'from_centinela') {
        await _determinarFncCentinela(
            response['fnc'], Map<String, dynamic>.from(response['data']));
        return;
      }

      await _determinarFunction(
          response['fnc'], Map<String, dynamic>.from(response['data']));
      return;
    }

    cerrarConection();
  }

  ///
  Future<void> _determinarFunction(
    String fnc, Map<String, dynamic> params
  ) async {

    switch (fnc) {
      case 'set_data_connx':
        _registrarVariablesDeUsuario(params);
        msgErr = (params.containsKey('err')) ? params['err'] : 'No Autorizado';
        break;
      case 'make_login':
        _registrarVariablesDeUsuario(params);
        msgErr =
            (params.containsKey('err')) ? params['err'] : 'Login Autorizado';
        break;
      case 'update_colaborador':
        msgErr = params['msg'];
        break;
      case 'get_data_ctz':
        break;
      case 'new_contact':
        msgErr =
            (params.containsKey('err')) ? 'new_contact-er' : 'new_contact-ok';
        break;
      default:
        _msgErr = 'Sin Función';
    }
  }

  ///
  Future<void> _determinarFncCentinela(
    String fnc, Map<String, dynamic> params
  ) async {

    switch (fnc) {
      case 'update':
        msgCron = 'CAMBIO DE V: ${params['to_version']}';
        alertCV = true;
        addManifest(params);
        msgErr = (params.containsKey('err'))
            ? params['err']
            : 'ERROR al Descargar CENTINELA FILE';
        break;
      case 'cron':
        if(params['vers'] != _verCentiCurrent) {
          _verCentiCurrent = params['vers'];
          msgCron = '${params['time']} V: ${params['vers']}';
        }
        break;
      default:
        _msgErr = 'Sin Acción';
    }
  }

  ///
  void _registrarVariablesDeUsuario(Map<String, dynamic> params) {

    if (params.containsKey('nombre')) {
      username = params['nombre'];
      globals.curc = params['curc'];
      globals.idUser = params['id'];
      globals.roles = List<String>.from(params['roles']);
    }
  }

  /// Recuperamos la Ip de Harbi, pero siempre tiene que ser desde el servidor
  /// remoto, ya que no sabemos desde que maquina se esta corriendo la SCP.
  Future<bool> getIpConnectionToHarbi({String pass = '', String ipNew = '0'}) async {

    String url = '';
    if(pass.isNotEmpty) {

      String uri = 'home-controller/get-data-connection/$pass/';
      if (GetPaths.env == 'dev') {
        url = 'http://autoparnet.loc/$uri';
      }else{
        url = 'https://autoparnet.com/$uri';
      }

      if(globals.isLocalConn) {
        url = await GetPaths.getDominio();
        url = '$url$uri';
      }
      
      try {
        await MyHttp.get(url);
      } catch (e) {
        Uri uri = Uri.parse(url);
        if(e.toString().contains(uri.host)) {
          msgErr = '${uri.host}, no respode.';
        }else{
          msgErr = 'Sin Respuesta del Servidor';
        }
        return false;
      }
      
      final tipoR = MyHttp.result['body'].runtimeType;
      
      if(tipoR == String) {
        if(MyHttp.result['body'].contains('ERROR')) {
          msgErr = MyHttp.result['body'];
          return false;
        }
      }
      
      if(MyHttp.result['msg'] == 'ok') {
        
        if(MyHttp.result['body'].isEmpty) {
          msgErr = 'Credenciales Invalidas';
          return false;
        }

        String ipH = '';
        try {
          ipH = utf8.decode(base64Decode(MyHttp.result['body']));
        } catch (e) {
          Uri uri = Uri.parse(url);
          if(e.toString().contains(uri.host)) {
            msgErr = '${uri.host}, no respode.';
          }else{
            msgErr = 'Sin Respuesta del Servidor';
          }
          return false;
        }
        
        final tipoR = MyHttp.result['body'].runtimeType;
        
        if(tipoR == String) {
          if(MyHttp.result['body'].contains('ERROR')) {
            msgErr = MyHttp.result['body'];
            return false;
          }
        }
        
        if(ipH.contains(':')) {
          final partes = List<String>.from(ipH.split(':'));
          globals.ipHarbi = (ipNew != '0') ? ipNew : partes.first;
          globals.portHarbi = partes.last;
        }
        
        if(globals.ipHarbi.contains('.')) {

          msgErr = 'Probando Conexión';
          await MyHttp.get('http://${globals.ipHarbi}:${globals.portHarbi}/internal/get_ipdb');
          
          if(MyHttp.result.containsKey('base_r')) {
            globals.ipDbs = Map<String, dynamic>.from(MyHttp.result);
            MyHttp.clean();
            msgErr = 'Conexión via API exitosa';
            return true;
          }else{
            msgErr = 'No hay conexión con HARBI';
          }
        }
        return false;
      }else{
        msgErr = 'Necesitas Iniciar primeramente a HARBI';
      }
      return false;
    }

    String pathCon = await GetPaths.getFileByPath('harbi_connx');
    final file = File(pathCon);
    if (file.existsSync()) {
      final contenido =  Map<String, dynamic>.from(json.decode(file.readAsStringSync()));
      if (contenido.isNotEmpty) {
        globals.ipHarbi = contenido['ipHarbi'];
        globals.portHarbi = '${contenido['ptoHarbi']}';
      }
    }
    return (globals.ipHarbi.contains('.')) ? true : false;
  }
}
