import 'package:flutter/material.dart';

import '../../entity/proceso_entity.dart';
import '../../services/get_content_files.dart';
import '../../widgets/sin_data.dart';
import '../../widgets/tile_task.dart';

class PapeleraPage extends StatefulWidget {

  const PapeleraPage({Key? key}) : super(key: key);

  @override
  State<PapeleraPage> createState() => _PapeleraPageState();
}

class _PapeleraPageState extends State<PapeleraPage> {

  final ScrollController _ctrScrollMain = ScrollController();
  
  late Future<void> _recAllEnPapelera;
  List<ProcesoEntity> _lstPapelera = [];

  @override
  void initState() {
    _recAllEnPapelera = _getAllMensajes();
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
      future: _recAllEnPapelera,
      builder: (_, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          if(_lstPapelera.isEmpty) {
            return const SinData(msg: 'ningún mensajes en...', main: 'Papelera');
          }else{
            return Padding(
              padding: const EdgeInsets.all(3),
              child: _lstEnPapelera(),
            );
          }
        }
        return const Center(
          child: SizedBox(
            width: 30, height: 30,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  ///
  Widget _lstEnPapelera() {

    return Scrollbar(
      controller: _ctrScrollMain,
      isAlwaysShown: true,
      radius: const Radius.circular(3),
      showTrackOnHover: true,
      trackVisibility: true,
      child: ListView.builder(
        padding: const EdgeInsets.only(right: 10),
        controller: _ctrScrollMain,
        itemCount: _lstPapelera.length,
        itemBuilder: (_, int i) {
          return TileTask(
            proc: _lstPapelera[i],
            accType: 'papelera',
            index: i,
            onChangeFolder: (int index) {
              setState(() {
                _lstPapelera.removeAt(index);
              });
            },
          );
        },
      )
    );
  }
  
  ///
  Future<void> _getAllMensajes() async {
    _lstPapelera = await GetContentFile.getAllMesajesDelFolder('scm_drash');
  }
}