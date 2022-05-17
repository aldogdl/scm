import 'dart:convert';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:routemaster/routemaster.dart';

import 'layout_page.dart';
import '../config/sng_manager.dart';
import '../entity/request_event.dart';
import '../providers/socket_conn.dart';
import '../providers/process_provider.dart';
import '../services/puppetter/views/check_status.dart';
import '../services/puppetter/views/open_browser.dart';
import '../services/puppetter/views/open_whastapp.dart';
import '../services/get_paths.dart';
import '../vars/globals.dart';
import '../vars/scroll_config.dart';
import '../widgets/decoration_field.dart';
import '../widgets/checkbox_connection.dart';
import '../widgets/texto.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  final Globals _globals = getSngOf<Globals>();
  final PageController _ctrPage = PageController();

  final GlobalKey<FormState> _frmKey = GlobalKey<FormState>();
  final TextEditingController _curc = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final FocusNode _fcurc = FocusNode();
  final FocusNode _fpass = FocusNode();
  final _info = NetworkInfo();

  late final SocketConn _sock;
  bool _showPass = true;
  bool _otroUser = false;
  bool _isInit = false;
  int _intentosConn = 1;
  bool _absorbing = false;
  bool _hasLan = true;

  String _defaultUser = 'Cargando';
  List<String> items = ['Cargando'];
  final ValueNotifier<Map<String, dynamic>> _users =
      ValueNotifier<Map<String, dynamic>>({});

  @override
  void dispose() {
    _curc.dispose();
    _pass.dispose();
    _fcurc.dispose();
    _fpass.dispose();
    _users.dispose();
    _ctrPage.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback(_initWidget);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

    if (!_isInit) {
      _isInit = true;
      _sock = context.read<SocketConn>();
      _sock.setMsgWithoutNotified('Buscando Conexiones');
    }

    return LayoutPage(

      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            constraints: BoxConstraints.expand(
              width: appWindow.size.width,
              height: appWindow.size.height,
            ),
            child: _body()
          ),
          if(!_hasLan)
            Positioned.fill(
              child: GlassContainer.frostedGlass(
                width: appWindow.size.width,
                height: appWindow.size.height,
                child: _sinRedLan()
              ),
            )
        ],
      ),
    );
  }

  ///
  Widget _body() {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _pagesViewer(),
        const Spacer(),
        const Texto(
          txt: 'SCM',
          txtC: Color.fromARGB(255, 61, 54, 54),
          sz: 90, isCenter: true, isBold: true,
        ),
        const Texto(txt: 'SERVIDOR CENTRAL DE MENSAJERÍA', txtC: Colors.blue),
      ],
    );
  }

  ///
  Widget _sinRedLan() {

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Texto(
            txt: 'Revisa la conexión a la red interna, se detectó una '
            'interrupción en el sistema por falta de conectividad.',
            sz: 19, isCenter: true, txtC: Color.fromARGB(255, 212, 212, 212),
          ),
        ),
        Icon(
          Icons.wifi_off_sharp, size: 250,
          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1)
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: (){
                    setState(() {
                      _hasLan = true;
                    });
                  },
                  icon: const Icon(Icons.close),
                  label: const Texto(txt: 'CONTINUAR SIN CONEXIÓN')
                ),
                TextButton.icon(
                  onPressed: () async => await _checkRedLan(),
                  icon: const Icon(Icons.refresh),
                  label: const Texto(txt: 'PROBAR NUEVAMENTE')
                ),
              ]
            ),
          ],
        )
      ],
    );
  }

  ///
  Widget _pagesViewer() {

    return Container(
      constraints: BoxConstraints.expand(
        height: appWindow.size.height * 0.69
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withOpacity(0.1),
        border: Border.all(
          color: Colors.grey.withOpacity(0.4)
        )
      ),
      child: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: PageView(
          controller: _ctrPage,
          children: [
            OpenBrowser(
              onNext: (_) {
                _ctrPage.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn
                );
              }
            ),
            OpenWhastapp(
              onNext: (_) {
                _ctrPage.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn
                );
              }
            ),
            CheckStatus(
              onNext: (_) {
                if(!_sock.isLoged){
                  _ctrPage.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn
                  );
                }
              }
            ),
            _pageLogin()
          ],
        ),
      ),
    );
  }

  ///
  Widget _pageLogin() {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(height: 30),
        Icon(Icons.account_circle_rounded, size: 70, color: Colors.blue.withOpacity(0.3)),
        Texto(
          txt: context.watch<SocketConn>().msgErr,
          txtC: Colors.blue, isCenter: true,
        ),
        const SizedBox(height: 40),
        _formularioLogin(),
        const CheckBoxConnection(),
        const SizedBox(height: 10),
        _btnLogin(),
        const Spacer(),
        _reconectarHarbi(),
      ],
    );
  }

  ///
  Widget _formularioLogin() {

    return Form(
      key: _frmKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ValueListenableBuilder<Map<String, dynamic>>(
            valueListenable: _users,
            builder: (_, users, __) {
              if (users.isNotEmpty && items.length == 1) {
                items.clear();
                users.forEach((key, val) => items.add(val['nombre']));
                items.add('Usar Otro Usuario');
                _curc.text = users.values.first['curc'];
                _defaultUser = users.values.first['nombre'];
              }

              return DecorationField.dropBy(
                items: items,
                fco: _fcurc,
                help: 'Selecciona quien éres',
                iconoPre: Icons.account_circle_rounded,
                onChange: (val) {
                  if (val != null) {
                    if (val.contains('Otro')) {
                      _curc.text = '';
                      setState(() {
                        _otroUser = true;
                      });
                    } else {
                      final us = _users.value.values.where((element) {
                        return element['nombre'] == val;
                      }).toList();
                      if (us.isNotEmpty) {
                        _curc.text = us.first['curc'];
                      }
                      if (_otroUser) {
                        setState(() {
                          _otroUser = false;
                        });
                      }
                    }
                  }
                },
                orden: 1,
                defaultValue: _defaultUser,
              );
            }
          ),
          const SizedBox(height: 20),
          if (_otroUser) ...[
            DecorationField.fieldBy(
              ctr: _curc,
              fco: _fcurc,
              help: 'Ingresa tu CURC',
              iconoPre: Icons.account_circle_rounded,
              orden: 2,
              isPass: false,
              showPass: true,
              onPressed: (val) {},
              validate: (String? val) {
                if (val != null) {
                  if (val.length >= 3) {
                    return null;
                  }
                }
                return 'Este campo es Requerido';
              }
            ),
            const SizedBox(height: 20),
          ],
          DecorationField.fieldBy(
            ctr: _pass,
            fco: _fpass,
            help: 'Ingresa tu Contraseña',
            iconoPre: Icons.security,
            orden: 3,
            isPass: true,
            showPass: _showPass,
            onPressed: (val) => setState(() {
                  _showPass = val;
            }),
            validate: (String? val) {
              if (val != null) {
                if (val.length >= 3) {
                  return null;
                }
              }
              return 'Este campo es Requerido';
            }
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  ///
  Widget _btnLogin() {

    return Container(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.1,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      width: appWindow.size.width * 0.5,
      height: 35,
      child: AbsorbPointer(
        absorbing: _absorbing,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.green),
          ),
          onPressed: () => _autenticar(),
          child: const Texto(
            txt: 'AUTENTICARME', txtC: Colors.black, isBold: true
          )
        ),
      ),
    );
  }

  ///
  Widget _reconectarHarbi() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Texto(txt: 'HARBI: ${_globals.ipHarbi}'),
          ),
        ),
        if (_globals.ipHarbi.isEmpty)
          IconButton(
            onPressed: () async {
              bool hasIp = await _sock.getIpConnectionToHarbi();
              if (hasIp) {
                _sock.msgErr = 'Identifícate por favor';
              }
            },
            iconSize: 18,
            color: Colors.white,
            icon: const Icon(Icons.refresh)
          )
      ],
    );
  }

  ///
  Future<void> _initWidget(_) async {

    _pass.text = '';
    try {
      await _sock.getNameRed();
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => const SimpleDialog(
          insetPadding: EdgeInsets.all(20),
          alignment: Alignment.center,
          children: [
            Texto(
              txt: 'Por favor, es necesario que estés conectado '
              'a algúna RED por medio de Cable o WiFi.\nDespués '
              'será necesario que reinicies el programa.',
              isCenter: true,
            )
          ],
        )
      );
      return;
    }

    String uri = await GetPaths.getFileByPath('connpass');
    File filepass = File(uri);
    if (filepass.existsSync()) {
      _users.value = Map<String, dynamic>.from(json.decode(filepass.readAsStringSync()));
    }
    _absorbing = false;
    _pass.text = '';

    await _checkRedLan();
  }

  ///
  Future<void> _checkRedLan() async {

    String? ip = await _info.getWifiIP();
    if(ip == null || ip.isEmpty) {
      _hasLan = false;
    }else{
      _hasLan = true;
    }
    Future.delayed(const Duration(microseconds: 300), (){
      setState(() {});
    });
  }

  ///
  Future<void> _autenticar() async {

    if (_frmKey.currentState!.validate()) {
      
      setState(() {
        _absorbing = true;
      });
      await Future.delayed(const Duration(milliseconds: 300));

      _sock.isLoged = false;
      _sock.msgErr = 'Recuperando datos de Conexión';
      bool hasIp = await _sock.getIpConnectionToHarbi(
        pass: _pass.text.toLowerCase().trim(),
        ipNew: (_intentosConn > 1) ? _globals.myIp : '0'
      );
      if (hasIp) {
        _sock.msgErr = 'Identifícate por favor';
      }
      if(_sock.msgErr.contains('ERROR')) {
        setState(() {
          _absorbing = false;
        });
        return;
      }

      bool isConnected = await _sock.ping();

      if (!isConnected) {
        if (_globals.ipHarbi.isEmpty) {
          _sock.msgErr = 'Desconocida la IP de HARBI';
        } else {
          if(_intentosConn == 1) {
            _intentosConn = 2;
            _sock.msgErr = 'Probando con mi IP';
            _autenticar();
          }else{
            _sock.msgErr = 'No hay conexión con HARBI';
            setState(() { _absorbing = false; });
          }
        }
      } else {
        await validarCredenciales();
      }
    }
  }

  ///
  Future<void> validarCredenciales() async {

    _sock.msgErr = 'Validando Credenciales';

    final data = {
      'username': _curc.text.toLowerCase().trim(),
      'password': _pass.text.toLowerCase().trim()
    };
    if (_otroUser) {
      data['only_check'] = '1';
    }
    bool abort = await _sock.awaitResponseSocket(
      event: RequestEvent(
        event: 'connection', fnc: 'exite_user_local', data: data
      ),
      msgInit: 'Haciendo login en local',
      msgExito: 'Login Autorizado'
    );

    if (!_sock.msgErr.contains('Error')) {
      if (abort) {
        await _hacerLoginFromServer(data);
      } else {
        
        _globals.password = data['password']!;
        _globals.curc = data['username']!;
        setState(() {
          _absorbing = false;
        });
        _sock.isLoged = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          Routemaster.of(context).pop();
          context.read<ProcessProvider>().reloadMsgAcction =
          'Bienvenid@ ${context.read<SocketConn>().username}';
        });
      }
    } else {
      if (_sock.msgErr.contains('Inexistente')) {
        await _hacerLoginFromServer(data);
      }
    }
  }

  ///
  Future<void> _hacerLoginFromServer(Map<String, dynamic> data) async {

    _globals.tkServ = '';
    bool abort = await _sock.awaitResponseSocket(
      event: RequestEvent(
        event: 'connection', fnc: 'make_login_server', data: data
      ),
      msgInit: 'Buscando Credenciales',
      msgExito: 'Login Autorizado');

    if (abort) {
      _sock.msgErr = 'Credenciales Invalidas';
    } else {
      _sock.isLoged = true;
      _globals.password = data['password']!;
      _globals.curc = data['username']!;
      setState(() {
        _absorbing = false;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        Routemaster.of(context).pop();
        context.read<ProcessProvider>().reloadMsgAcction =
          'Bienvenid@ ${_sock.username}';
      });
    }
  }
}