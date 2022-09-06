import 'package:flutter/material.dart';
import 'package:scm/src/services/get_content_files.dart';
import 'package:scm/src/widgets/sin_data.dart';

import '../../entity/proceso_entity.dart';

class AwaitPage extends StatefulWidget {
  
  const AwaitPage({Key? key}) : super(key: key);

  @override
  State<AwaitPage> createState() => _AwaitPageState();
}

class _AwaitPageState extends State<AwaitPage> {

  final ScrollController _ctrScrollMain = ScrollController();
  late Future<void> _recAllEnEspera;
  List<ProcesoEntity> _lstEspera = [];

  @override
  void initState() {
    _recAllEnEspera = _getAllMensajes();
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
      future: _recAllEnEspera,
      builder: (_, AsyncSnapshot snapshot) {
        
        if(snapshot.connectionState == ConnectionState.done) {
          if(_lstEspera.isEmpty) {
            return const SinData(msg: 'ningún mensajes en...', main: 'Espera');
          }else{
            return Container(
              color: const Color.fromARGB(255, 43, 43, 43),
              padding: const EdgeInsets.all(3),
              child: _lstEnEspera(),
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
  Widget _lstEnEspera() {

    return Scrollbar(
      controller: _ctrScrollMain,
      thumbVisibility: true,
      radius: const Radius.circular(3),
      trackVisibility: true,
      child: ListView.builder(
        padding: const EdgeInsets.only(right: 10),
        controller: _ctrScrollMain,
        itemCount: _lstEspera.length,
        itemBuilder: (_, int i) {
          return const SizedBox();
        },
      )
    );
  }
  
  ///
  Future<void> _getAllMensajes() async {

    if(_lstEspera.isEmpty) {
      _lstEspera = await GetContentFile.getAllMesajesDelFolder('scm_await');
    }
  }

}