import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/provider.dart';

import '../../entity/proceso_entity.dart';
import '../../services/get_content_files.dart';
import '../../providers/process_provider.dart';
import '../../services/scm/scm_paths.dart' show FoldStt;
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
  List<Map<String, dynamic>> _lstCamps = [];
  late Future _getTray;

  @override
  void initState() {
    _getTray = _recuperarTray();
    super.initState();
  }

  @override
  void dispose() {
    _ctrScrollMain.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _getTray,
      builder: (_, AsyncSnapshot snap) {

        if(snap.connectionState == ConnectionState.done) {
          if(_lstCamps.isNotEmpty) {
            return _buildLstCampaings();
          }
        }

        return _sinData();
      }
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
      color: const Color.fromARGB(255, 97, 90, 90),
      child: Column(
        children: [
          _indicador(),
          Expanded(
            child: _lista(),
          )
        ],
      )
    );
  }

  ///
  Widget _lista() {
    
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
          itemBuilder: (_, int index) {

            return TileTrayCamp(
              idCurrent: _proc.enProceso.id,
              dataTray: _lstCamps[index]
            );
          }
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
          _recuperarTrayAgaing();
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
  Future<void> _recuperarTray() async {

    if(!_isInit) {
      _isInit = true;
      _proc = context.read<ProcessProvider>();
    }
    
    if(_lstCamps.length != _proc.enTray) {
      _lstCamps = await GetContentFile.getAllCampaingsWithDataMini();
    }
  }

  ///
  Future<void> _recuperarTrayAgaing() async {

    List<Map<String, dynamic>> lstCamps = [];
    final list = GetContentFile.getFilesTraySortPriority();
    final files = List<String>.from(list['lst']);
    
    if(files.isNotEmpty){
      Map<String, dynamic> current = {};

      for (var i = 0; i < files.length; i++) {
        
        final proc = ProcesoEntity();
        String filename = files[i];
        bool isCurrent = false;

        if(list.containsKey('currentWithoutWork')) {
          if(list['currentWithoutWork'].isNotEmpty) {
            if(list['currentWithoutWork'] == files[i]) {
              if(list.containsKey('currentWithWork')) {
                filename = list['currentWithWork'];
              }else{
                filename = files[i];
              }
              isCurrent = true;
            }
          }
        }

        proc.fromJson(
          await GetContentFile.getContentByFileAndFolder(
            fileName: filename, folder: FoldStt.tray
          )
        );

        Map<String, dynamic> json = proc.toJsonMini();
        
        json['isPrio'] = (i == 0) ? true : false;
        json['isCurrent'] = isCurrent;

        if(!json['isCurrent']) {
          lstCamps.add(json);
        }else{
          current = json;
        }
      }

      if(current.isNotEmpty) {
        lstCamps.insert(0, current);
      }
      current = {};
    }

    _lstCamps = List<Map<String, dynamic>>.from(lstCamps);
    if(mounted) {
      if(lstCamps.isNotEmpty){
        setState(() {});
      }
    }
    lstCamps = [];
  }
}