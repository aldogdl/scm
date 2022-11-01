import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:scm/src/pages/portada_page.dart';

import 'layout_page.dart';
import '../services/get_paths.dart';
import '../config/sng_manager.dart';
import '../providers/socket_conn.dart';
import '../vars/globals.dart';
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

  final GlobalKey<FormState> _frmKey = GlobalKey<FormState>();
  final TextEditingController _curc = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final FocusNode _fcurc = FocusNode();
  final FocusNode _fpass = FocusNode();

  late final SocketConn _sock;
  bool _showPass = true;
  bool _otroUser = false;
  bool _isInit = false;
  bool _absorbing = false;
  bool _hasLan = true;

  String _defaultCurc = 'Cargando';
  String _defaultUser = 'Cargando';
  List<String> items = ['Cargando'];
  final  _users = ValueNotifier<Map<String, dynamic>>({});

  @override
  void dispose() {
    _curc.dispose();
    _pass.dispose();
    _fcurc.dispose();
    _fpass.dispose();
    _users.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_initWidget);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

    if (!_isInit) {
      _isInit = true;
      _sock = context.read<SocketConn>();
      _sock.setMsgWithoutNotified('Autentícate por favor.');
    }

    return LayoutPage(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: appWindow.size.height,
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            _body(),
            if(!_hasLan)
              Positioned.fill(
                child: GlassContainer.frostedGlass(
                  width: appWindow.size.width,
                  height: appWindow.size.height,
                  child: _sinRedLan()
                ),
              )
          ],
        )
      )
    );
  }

  ///
  Widget _body() {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
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
              const SizedBox(height: 30),
              _formularioLogin(),
              const ExcludeFocus(child: CheckBoxConnection()),
              const SizedBox(height: 10),
              _btnLogin(),
              const Spacer(),
              _reconectarHarbi(),
            ],
          ),
        ),
        const Texto(
          txt: 'SCM',
          txtC: Color.fromARGB(255, 61, 54, 54),
          sz: 80, isCenter: true, isBold: true,
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

              return (users.isNotEmpty) ?_dropUsers() : _txtUser();
            }
          ),
          const SizedBox(height: 20),
          if (_otroUser) ...[
            _txtUser(),
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
  Widget _dropUsers() {

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

            final us = _users.value.values.where(
              (element) => element['nombre'] == val
            ).toList();
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

  ///
  Widget _txtUser() {

    return DecorationField.fieldBy(
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
              if (_globals.ipHarbi.isEmpty) {
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
    // try {
    //   await _sock.getNameRed();
    // } catch (e) {
    //   showDialog(
    //     context: context,
    //     builder: (_) => const SimpleDialog(
    //       insetPadding: EdgeInsets.all(20),
    //       alignment: Alignment.center,
    //       children: [
    //         Texto(
    //           txt: 'Por favor, es necesario que estés conectado '
    //           'a algúna RED por medio de Cable o WiFi.\nDespués '
    //           'será necesario que reinicies el programa.',
    //           isCenter: true,
    //         )
    //       ],
    //     )
    //   );
    //   return;
    // }

    _absorbing = false;
    _pass.text = '';
    await _checkRedLan();
    final uss = await _getUserFromFile();
    List<String> lstCurcs = [];
    if (uss.isNotEmpty && items.length == 1) {
      items.clear();
      uss.forEach((key, value) {
        lstCurcs.add(value['curc']);
        items.add(value['nombre']);
      });
      items.add('Usar Otro Usuario');
    }

    _defaultUser = items.first;
    _defaultCurc = (lstCurcs.isNotEmpty) ? lstCurcs.first : '';
    Future.microtask(() => _users.value = uss);
  }

  ///
  Future<void> _checkRedLan() async {

    _sock.msgErr = await _sock.getIpToHarbiFromServer();
    if(!_sock.msgErr.startsWith('ERROR')) {
      _sock.msgErr = 'AUTENTÍCATE POR FAVOR';
    }

    Future.delayed(const Duration(microseconds: 300), (){
      setState(() {});
    });
  }

  ///
  Future<void> _autenticar() async {

    if (_frmKey.currentState!.validate()) {
      final nav = Navigator.of(context);

      if(_curc.text.isEmpty) {
        _curc.text = _defaultCurc;
      }
      setState(() { _absorbing = true; });
      await Future.delayed(const Duration(milliseconds: 300));

      _sock.isLoged = false;
      _sock.msgErr = 'Revisando conexión con Harbi';
      _sock.msgErr = await _sock.probandoConnWithHarbi();
      
      if(_sock.msgErr.startsWith('ERROR')) {
        setState(() { _absorbing = false; });
        return;
      }

      _sock.msgErr = 'Validando Credenciales';
      final data = {
        'username': _curc.text.toLowerCase().trim(),
        'password': _pass.text.toLowerCase().trim()
      };
      await _hidratarUserFromFile(data);

      bool isValid = await _sock.hacerLoginFromServer(data);
      if(!isValid) {
        _sock.msgErr = '[X] Credenciales Invalidas';
        setState(() {
          _absorbing = false;
        });
        return;
      }

      await _hidratarFileFromUser(data);
      _sock.makeFirstConnection().then((_) async {
        if(_sock.idConn != 0) {
          await _sock.makeRegistroUserToHarbi();
          _sock.isLoged = true;
          nav.pushReplacement(
            MaterialPageRoute(
              builder: (_) => const PortadaPage()
            )
          );
        }
      });
    }
  }

  ///
  Future<void> _hidratarUserFromFile(Map<String, dynamic> data) async {

    final users = await _getUserFromFile();
    if(users.isNotEmpty) {
      users.forEach((key, value) {
        if(value['curc'] == data['username']) {
          var us = Map<String, dynamic>.from(value);
          if(!us.containsKey('password')) {
            us['password'] = data['password'];
          }
          _globals.user.fromFile(us);
        }
      });
    }
  }

  ///
  Future<void> _hidratarFileFromUser(Map<String, dynamic> data) async {

    String uri = await GetPaths.getFileByPath('connpass');
    List<Map<String, dynamic>> users = [];

    final regs = File(uri);
    if(regs.existsSync()) {
      
      final content = regs.readAsStringSync();
      if(content.isNotEmpty) {

        final c = json.decode(content);

        if(c.runtimeType == List<dynamic>) {
          users = List<Map<String, dynamic>>.from(c);
          final has = users.indexWhere((e) => e['curc'] == data['username']);
          if(has != -1) {
            users[has] = _globals.user.userToJson();
          }else{
            users.add(_globals.user.userToJson());
          }
        }else{
          users.add(_globals.user.userToJson());
        }
      }
    }else{
      users.add(_globals.user.userToJson());
    }

    regs.writeAsStringSync(json.encode(users));
  }

  ///
  Future<Map<String, dynamic>> _getUserFromFile() async {

    Map<String, dynamic> users = {};
    String uri = await GetPaths.getFileByPath('connpass');
    final regs = File(uri);
    if (regs.existsSync()) {
      final content = regs.readAsStringSync();
      if(content.isNotEmpty) {
        final c = json.decode(content);
        if(c.runtimeType == List<dynamic>) {
          for (var i = 0; i < c.length; i++) {
            users.putIfAbsent(c[i]['curc'], () => c[i]);
          }
          return users;
        }
        users = Map<String, dynamic>.from(c);
      }
    }
    return users;
  }
}