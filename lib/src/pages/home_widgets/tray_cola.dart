import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/provider.dart';
import 'package:scm/src/widgets/my_tool_tip.dart';
import 'package:scm/src/widgets/texto.dart';

import '../../entity/proceso_entity.dart';
import '../../services/get_content_files.dart';
import '../../providers/process_provider.dart';
import '../../services/scm/scm_paths.dart' show FoldStt, ScmPaths;
import '../../widgets/indicador_cola.dart';
import '../../widgets/tile_tray_camp.dart';
import '../../vars/scroll_config.dart';
import '../../widgets/sin_data.dart';

class TrayCola extends StatefulWidget {

  const TrayCola({Key? key}) : super(key: key);

  @override
  State<TrayCola> createState() => _TrayColaState();
}

class _TrayColaState extends State<TrayCola> {

  final ScrollController _ctrScrollMain = ScrollController();
  late final ProcessProvider _proc;

  bool _isInit = false;
  bool isLock = false;
  List<Map<String, dynamic>> _lstCamps = [];
  Map<String, dynamic> _campCurr = {};

  @override
  void dispose() {
    _ctrScrollMain.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _proc = context.read<ProcessProvider>();
    }

    return Selector<ProcessProvider, int>(
      selector: (_, prov) => prov.refreshTray,
      builder: (_, val, child) {

        if(val <= 0 && _proc.enProceso.id == 0) {
          return child!;
        }

        return FutureBuilder(
          future: _recuperarTray(),
          builder: (_, AsyncSnapshot snap) {
            
            if(snap.connectionState == ConnectionState.done) {
              return _buildLstCampaings();
            }
            return child!;
          }
        );
      },
      child: _sinData(),
    );
  }

  ///
  Widget _sinData() {
    return const SinData(
      msg: '', main: 'NADA EN LA BANDEJA',
      withTit: false,
    );
  }

  ///
  Widget _buildLstCampaings() {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(3),
      constraints: BoxConstraints.expand(
        width: appWindow.size.width
      ),
      color: const Color.fromARGB(255, 20, 20, 20),
      child: Column(
        children: [
          _indicador(),
          TileTrayCamp(
            idCurrent: _proc.enProceso.id,
            dataTray: _campCurr
          ),
          Expanded(
            child: _listaDeTrayEnCola(),
          )
        ],
      )
    );
  }

  ///
  Widget _listaDeTrayEnCola() {
    
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: Scrollbar(
        controller: _ctrScrollMain,
        thumbVisibility: true,
        radius: const Radius.circular(3),
        trackVisibility: true,
        child: ListView.builder(
          padding: const EdgeInsets.only(right: 15, top: 5),
          controller: _ctrScrollMain,
          itemCount: _lstCamps.length,
          itemBuilder: (_, int index) => _tileTrayEnCola(index)
        )
      )
    );
  }

  ///
  Widget _indicador() {

    return Selector<ProcessProvider, int>(
      selector: (_, prov) => prov.enTray,
      builder: (_, trigger, __) {
        
        String onOff = 'off';
        if(trigger != _lstCamps.length) {
          onOff = 'on';
          //_recuperarTrayAgaing();
        }

        return IndicadorCola(
          onOff: onOff,
          colorOn: Colors.yellow,
          colorOff: const Color.fromARGB(255, 97, 90, 90)
        );
      }
    );
  }

  ///
  Widget _tileTrayEnCola(int index) {

    final target = _lstCamps[index]['target'];

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 3),
            Texto(
              txt: '${index+1}.-',
              txtC: const Color.fromARGB(255, 63, 132, 223),
            ),
            const SizedBox(width: 5),
            Texto(
              txt: '${_lstCamps[index][target]['modelo']} ${_lstCamps[index][target]['anio']}',
              txtC: const Color.fromARGB(255, 54, 100, 56), isBold: true,
            ),
            const Spacer(),
            Texto(
              txt: 'Ord.: ${_lstCamps[index][target]['id']}',
              sz: 12, isBold: true,
            ),
          ],
        ),
        Row(
          children: [
            MyToolTip(
              msg: 'AVO: ${_lstCamps[index]['remiter']['nombre']}',
              child: const Icon(
                Icons.account_circle, size: 15, color: Color.fromARGB(255, 129, 129, 129),
              )
            ),
            const SizedBox(width: 8),
            Texto(
              txt: '${_lstCamps[index]['emiter']['nombre']}',
              txtC: const Color.fromARGB(255, 70, 82, 121),
              sz: 11, isBold: true,
            ),
            const Spacer(),
            Texto(
              txt: 'de: ${_lstCamps[index]['emiter']['empresa']}',
              txtC: const Color.fromARGB(255, 90, 90, 90),
              sz: 12, isBold: true,
            ),
          ],
        ),
        const Divider(height: 10)
      ],
    );
  }
  
  /// Recuperamos todas las campañas que estan en tray
  Future<void> _recuperarTray() async {

    if(isLock){ return; }
    isLock = true;

    _lstCamps = [];
    _campCurr = {};
    List<String> files = GetContentFile.getFilesTraySortPriority();
    
    if(files.isNotEmpty) {
      for (var i = 0; i < files.length; i++) {
        final procc = ProcesoEntity();
        _campCurr = await GetContentFile.getContentByFileAndFolder(
          fileName: files[i], folder: FoldStt.tray
        );
        procc.fromJson(_campCurr);
        if(files[i].startsWith(ScmPaths.prefixFldWrk)) {
          _campCurr = procc.toJsonMini();
        }else{
          _lstCamps.add(procc.toJsonMini());
        }
      }
    }
    files = [];
    isLock = false;
  }

}