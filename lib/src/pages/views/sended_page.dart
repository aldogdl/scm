import 'package:flutter/material.dart';

import '../../entity/proceso_entity.dart';
import '../../services/get_content_files.dart';
import '../../widgets/sin_data.dart';
import '../../widgets/tile_task.dart';

class SendedPage extends StatefulWidget {

  const SendedPage({Key? key}) : super(key: key);

  @override
  State<SendedPage> createState() => _SendedPageState();
}

class _SendedPageState extends State<SendedPage> {

  final ScrollController _ctrScrollMain = ScrollController();
  
  late Future<void> _recAllSended;
  List<ProcesoEntity> _lstSended = [];

  @override
  void initState() {
    _recAllSended = _getAllMensajes();
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
      future: _recAllSended,
      builder: (_, AsyncSnapshot snapshot) {

        if(snapshot.connectionState == ConnectionState.done) {
          if(_lstSended.isEmpty) {
            return const SinData(msg: 'ningún mensajes en...', main: 'Enviados');
          }else{
            return Padding(
              padding: const EdgeInsets.all(3),
              child: _buildLstSended(),
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
  Widget _buildLstSended() {

    return Scrollbar(
      controller: _ctrScrollMain,
      isAlwaysShown: true,
      radius: const Radius.circular(3),
      showTrackOnHover: true,
      trackVisibility: true,
      child: ListView.builder(
        padding: const EdgeInsets.only(right: 10),
        controller: _ctrScrollMain,
        itemCount: _lstSended.length,
        itemBuilder: (_, int i) {
          return TileTask(
            proc: _lstSended[i],
            accType: 'sended',
            index: i,
            onChangeFolder: (int index) {
              setState(() {
                _lstSended.removeAt(index);
              });
            },
          );
        },
      )
    );
  }
  
  ///
  Future<void> _getAllMensajes() async {
    _lstSended = await GetContentFile.getAllMesajesDelFolder('scm_sended');
  }
}