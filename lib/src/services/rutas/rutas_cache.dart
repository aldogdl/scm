import 'dart:io';
import 'dart:convert';

import '../../services/get_paths.dart';

class RutasCache {

  String lastRuta = '';
  final Map<String, dynamic> _rutas = {};
  Map<String, dynamic> get rutas => _rutas;

  ///
  Future<Map<String, dynamic>> getRuta(String ruta) async {
    if(_rutas.containsKey(ruta)) {
      return _rutas[ruta];
    }else{
      await hidratarByRuta(ruta);
      if(_rutas.containsKey(ruta)) {
        return _rutas[ruta];
      }
    }
    return {};
  }

  ///
  Future<void> hidratar() async {

    if(_rutas.isEmpty) {
      Directory? path = GetPaths.getPathsFolderTo('rutas');
      if(path != null) {
        path.listSync().map((e){
          if(e.path.endsWith('.last')) {
            List<String> partes = e.path.split(Platform.pathSeparator);
            lastRuta = partes.last.replaceAll('.last', '').trim();
          }
        }).toList();
        if(lastRuta.isNotEmpty) {
          File ruts = File('${path.path}/$lastRuta.json');
          if(ruts.existsSync()) {
            _rutas.putIfAbsent(lastRuta, () => Map<String, dynamic>.from(json.decode(ruts.readAsStringSync())) );
            _rutas[lastRuta].remove('ver');
          }
        }
      }
    }
  }

  ///
  Future<void> hidratarByRuta(String ruta) async {

    if(_rutas.isEmpty) {
      Directory? path = GetPaths.getPathsFolderTo('rutas');
      if(path != null) {
        File ruts = File('${path.path}/$ruta.json');
        if(ruts.existsSync()) {
          _rutas.putIfAbsent(ruta, () => Map<String, dynamic>.from(json.decode(ruts.readAsStringSync())) );
          _rutas[ruta].remove('ver');
        }
      }
    }
  }

}