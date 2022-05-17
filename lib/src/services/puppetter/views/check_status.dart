import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/provider.dart';

import '../providers/browser_provider.dart';
import '../../../services/my_utils.dart';
import '../../../services/puppetter/browser_task.dart';
import '../../../widgets/texto.dart';

class CheckStatus extends StatefulWidget {

  final ValueChanged<void> onNext;
  const CheckStatus({
    Key? key,
    required this.onNext
  }) : super(key: key);

  @override
  State<CheckStatus> createState() => _CheckStatusState();
}

class _CheckStatusState extends State<CheckStatus> {
  
  bool _isInit = false;
  bool _isloading = false;
  bool _isFirtTime = true;
  List<Map<String, dynamic>> checkings = [];


  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      BrowserTask.init(context.read<BrowserProvider>());
      checkings = BrowserTask.getTasks();
    }

    return Column(
      children: [
        Icon(Icons.done_all_outlined, size: 70, color: Colors.blue.withOpacity(0.3)),
        const Texto(txt: 'Checa el STATUS', isBold: true, sz: 15, isCenter: true),
        const Divider(height: 5, color: Colors.green),
        const Texto(
          txt: 'Permite que el sistema revice que todo esté '
          'correcto, y comenzar con la inicialización '
          'del Servidor Central del Mensajería.',
          isCenter: true,
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () async {

            if(_isFirtTime) {
              _isFirtTime = false;
            }else{
              checkings.map((e) => e['stt'] = 0).toList();
              setState(() {});
              context.read<BrowserProvider>().isOk = false;
              await Future.delayed(const Duration(milliseconds: 500));
            }
            await _checkSystem();
          },
          icon: const Icon(Icons.settings),
          label: Texto(
            txt: (_isFirtTime) ? 'Revisar Sistema' : 'Volver a Revisar'
          )
        ),
        const SizedBox(height: 20),
        const Texto(
          txt: 'ACCIONES AUTOMÁTICAS', isCenter: true, txtC: Colors.amber,
        ),
        const Divider(height: 10, color: Colors.green),
        Container(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10
          ),
          constraints: BoxConstraints.expand(
            height: appWindow.size.height * 0.22
          ),
          color: Colors.black.withOpacity(0.3),
          child: ListView.builder(
            itemCount: checkings.length,
            itemBuilder: (_, inx) => _tileTask(inx)
          ),
        ),
        const Spacer(),
        const SizedBox(height: 10),
        if(_isloading)
          Selector<BrowserProvider, String>(
            selector: (_, prov) => prov.titleCurrent,
            builder: (_, title, __) {
              if(title.isEmpty) {
                return const SizedBox(
                  width: 30, height: 30,
                  child: CircularProgressIndicator(),
                );
              }
              return const SizedBox();
            }
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: (context.watch<BrowserProvider>().isOk)
          ? () {
            _isloading = false;
            widget.onNext(null);
          }
          : null,
          child: Texto(
            txt: (context.watch<BrowserProvider>().isOk)
            ? 'SIGUIENTE' : 'EN ESPERA', txtC: Colors.white,
          )
        ),
        const SizedBox(height: 10),
        Texto(
          txt: 'PiB: ${context.watch<BrowserProvider>().pib}', txtC: Colors.white,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  ///
  Widget _tileTask(int inx) {

    IconData icon = (checkings[inx]['stt'] < 1) ? Icons.done : Icons.done_all;
    Color clr = (checkings[inx]['stt'] < 1) ? Colors.orange : Colors.blue;
    if(checkings[inx]['stt'] == 2) {
      icon= Icons.close;
      clr = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 15, color: clr),
          const SizedBox(width: 5),
          Texto(
            txt: checkings[inx]['task'],
            isCenter: false, txtC: const Color.fromARGB(255, 202, 202, 202), sz: 13,
          )
        ],
      ),
    );
  }

  ///
  Future<void> _checkSystem() async {
    
    int task = checkings.indexWhere((element) => element['stt'] == 0);
    
    if(task != -1) {
      if(checkings[task].containsKey('acc')) {

        switch (checkings[task]['acc']) {

          case 'bskContac':
            BrowserTask.buscarContacto(txt: 'Contactos').listen((event) {
              if(!event.startsWith('ERROR')) {
                checkings[task]['stt'] = 1;
                _checkSystem();
                setState(() {});
              }else{
                checkings[task]['stt'] = 2;
                setState(() {});
              }
            });
            break;
          case 'entraChat':
            BrowserTask.entrarAlChat('Contactos', isGrup: true).listen((event) {
              if(!event.startsWith('ERROR')) {
                checkings[task]['stt'] = 1;
                _checkSystem();
              }else{
                checkings[task]['stt'] = 2;
              }
              setState(() {});
            });
            break;
          case 'checkBoxWriteMsg':

            Map<String, dynamic> fecha = MyUtils.getFecha();
            String msg = 'Muy ${fecha['saludo']}, Nuevo comienzo del SCM '
            'hoy es: ${fecha['completa']}...';
            BrowserTask.comparaCon = ['nuevo', 'comienzo'];
            
            BrowserTask.escribirMsg([msg]).listen((event) {
              if(!event.startsWith('ERROR')) {
                checkings[task]['stt'] = 1;
                _checkSystem();
              }else{
                checkings[task]['stt'] = 2;
              }
              setState(() {});
            });
            break;
          case 'sendMsg':

            String result = await BrowserTask.sendMensaje();
            if(!result.startsWith('ERROR')) {
              checkings[task]['stt'] = 1;
              _checkSystem();
            }else{
              checkings[task]['stt'] = 2;
            }
            setState(() {});
            break;
          default:
            context.read<BrowserProvider>().isOk = false;
        }
      }
    }else{
      bool allOk = true;
      for (var i = 0; i < checkings.length; i++) {
        if(checkings[i]['stt'] != 1) {
          allOk = false;
          break;
        } 
      }
      context.read<BrowserProvider>().isOk = allOk;
    }
  }
}