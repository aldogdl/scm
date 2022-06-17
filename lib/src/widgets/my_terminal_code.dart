import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:scm/src/providers/process_provider.dart';
import 'package:scm/src/services/puppetter/browser_task.dart';
import 'package:scm/src/widgets/texto.dart';

class MyTerminalCode extends StatefulWidget {

  const MyTerminalCode({
    Key? key,
  }) : super(key: key);

  @override
  State<MyTerminalCode> createState() => _MyTerminalCodeState();
}

class _MyTerminalCodeState extends State<MyTerminalCode> {

  final ScrollController _scroll = ScrollController();
  final TextEditingController _ctrCode = TextEditingController();
  bool _isInit = false;

  late Future _getErrs;
  late final ProcessProvider _procProv;
  List<Map<String, dynamic>> lstErrs = [];
  String _verListaDe = 'secciones';
  String _verErroresDe = '';
  int _cantTestings = 0;


  @override
  void initState() {
    _getErrs = _recErrores();
    super.initState();
  }
  
  @override
  void dispose() {
    _ctrCode.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _procProv = context.read<ProcessProvider>();
    }

    return Column(
      children: [

        TextField(
          controller: _ctrCode,
          onSubmitted: (String? sentencia) async {
            await _speelSentencia(sentencia ?? '');
          },
          onEditingComplete: () async {
            await _speelSentencia(_ctrCode.text);
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: '<SENTENCIAS>',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.2)
            )
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: FutureBuilder(
              future: _getErrs,
              builder: (_, AsyncSnapshot snap) {
                return _buildLstErrs();
              }
            )
          )
        )
      ],
    );
  }

  ///
  Widget _buildLstErrs() {

    List<dynamic> lista = [];

    switch (_verListaDe) {
      case 'secciones':
        lista = lstErrs;
        break;
      case 'errores':
        final result = lstErrs.firstWhere((element) => element['secc'] == _verErroresDe);
        if(result.isNotEmpty) {
          lista = result['errs'];
        }else{
          lista = ['No se encontró errores'];
        }
        break;
      default:
    }

    if(_verListaDe == 'results') {

      // Ejemplo de codigo
      // envia 2 ordenes a remitentes 1 con error 1 y el segundo con ok
      // envia 2 remite 1-error-1 2-ok
      return StreamBuilder<Map<String, dynamic>>(
        stream: _initTest(),
        initialData: const {'acc':'Prueba', 'res':'Inciando...'},
        builder: (_, AsyncSnapshot snap) {
          return _tileResults(snap.data);
        }
      );
    }

    return Scrollbar(
      controller: _scroll,
      thumbVisibility: true,
      radius: const Radius.circular(3),
      trackVisibility: true,
      child: ListView.builder(
        controller: _scroll,
        itemCount: lista.length,
        itemBuilder: (_, index) {
          switch (_verListaDe) {
            case 'errores':
              return _tileErr(index, List<String>.from(lista));
            default:
              return _tileSecc(index);
          }
        },
      )
    );
  }

  ///
  Widget _tileSecc(int i) {

    return Texto(
      txt: '${lstErrs[i]['ind']}.- ${lstErrs[i]['secc']}'
    );
  }

  ///
  Widget _tileErr(int i, List<String> lst) {

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: Texto(
        txt: '${i+1}.- ${lst[i]}', sz: 12, txtC: const Color.fromARGB(255, 238, 146, 139),
      ),
    );
  }

  ///
  Widget _tileResults(Map<String, dynamic> result) {

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Texto(
            txt: '${result['acc']}', sz: 12, txtC: const Color.fromARGB(255, 238, 146, 139),
          ),
          Texto(
            txt: '${result['res']}', sz: 12, txtC: Colors.amber,
          ),
        ],
      )
    );
  }

  ///
  Stream<Map<String, dynamic>> _initTest() async* {

    await for (var item in _acciones()) {
      yield item;
    }
  }

  ///
  Stream<Map<String, dynamic>> _acciones() async* {

    for (var i = 0; i < _cantTestings; i++) {

      String response = '';
      BrowserTask.buscarContacto().listen((event) {
        if(!event.startsWith('ERROR')) {
          response = event;
        }else{
          response = 'aca adentro sin error';
        }
      });
      await Future.delayed(const Duration(milliseconds: 3000));
      yield {
        'acc': 'probando conexión',
        'res': response,
      };
    }
  }

  ///
  Future<void> _speelSentencia(String code) async {

    code = code.toLowerCase().trim();
    List<String> sentencia = code.split(' ');
    if(sentencia.isEmpty) {
      return;
    }

    switch (sentencia.first) {

      case 'ver':
        if(sentencia.length == 1) {
          sentencia.add('none');
        }
        int? secc = int.tryParse(sentencia[1]);
        if(secc != null) {
          secc = secc - 1;
          _verErroresDe = lstErrs[secc]['secc'];
          _verListaDe = 'errores';
        }else{
          _verErroresDe = '';
          _verListaDe = 'secciones';
        }
        setState(() {});
        break;

      case 'envia':
        sentencia.removeAt(0);
        int? secc = int.tryParse(sentencia[0]);
        if(secc != null) {

          _cantTestings = secc-1;
          _procProv.isTest = true;
          sentencia.removeAt(0);
          sentencia.removeAt(0);
          //_procProv.lstTestings = sentencia;
          _verErroresDe = '';
          _verListaDe = 'results';
          
        }else{
          _verErroresDe = '';
          _verListaDe = 'secciones';
        }
        setState(() {});
        break;
      default:
    }
  }

    ///
  Future<void> _recErrores() async {

    int ind = 1;
    BrowserTask.lstErrs.forEach((key, value) {
      lstErrs.add({
        'ind': ind,
        'secc':key,
        'errs':List<String>.from(value)
      });
      ind++;
    });
  }

  ///
  Map<String, dynamic> sentencias() {

    return {
      'ver':{
        'help': 'Vemos los errores de la seccion seleccionada',
        'sintax': '> ver #seccion',
      },
      'envia':{
        'help': 'Vemos los errores de la seccion seleccionada',
        'sintax': '> ver #seccion',
        'cmds': {
          'remite': {
            'help':'',
            'params': {
              'err':'',
              'ok':''
            },
            'sintax':'',
          }
        },
      }
    };
  }

}