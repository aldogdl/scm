import '../../config/sng_manager.dart';
import '../../services/rutas/rutas_cache.dart';

class EstStt {

  static RutasCache r = getSngOf<RutasCache>();

  String ruta = '';
  String estacion = '';

  // Revisamos que exista, en caso contrario descargamos la ruta adecuada
  static Future<void> init(String ruta) async {
    if(r.rutas.containsKey(ruta)) {
      await r.hidratarByRuta(ruta);
    }
  }

  // Revisamos que exista, en caso contrario descargamos la ruta adecuada
  static Future<void> _putIfAbsent(String ruta) async {

    if(!r.rutas.containsKey(ruta)) {
      await r.hidratarByRuta(ruta);
    }
  }

  // Revisamos que exista en caso contrario descargamos la ruta adecuada
  static Future<Map<String, dynamic>> getNextSttByEst(Map<String, dynamic> data) async {

    await _putIfAbsent(data['rta']);
    if(r.rutas.containsKey(data['rta'])) {

      List<String> rta = List<String>.from(r.rutas[data['rta']]['rta'][data['est']]);
      // Buscamos el status actual en la lista resultante rta
      int index = rta.indexOf(data['stt']);
      if(index != -1) {

        // Revisamos que el status siguiente no sea fin de estación
        String sttN = rta[index +1];
        if(sttN != 'f') {
          final txtStt = r.rutas[data['rta']]['stt'][data['est']][sttN];
          return {'est':data['est'], 'stt':sttN, 'rta':data['rta'], 'txtStt':txtStt};
        }

      }else{
        return {'error':'No se encuentra la orden: x'};
      }
    }

    return {'error':'Sin ruta'};
  }

  /// Obtenemos el status inicial de la estacion solicitada
  static String getFirstSttByEst(Map<String, dynamic> data) {

    _putIfAbsent(data['rta']);
    if(r.rutas.containsKey(data['rta'])) {
      return r.rutas[data['rta']]['rta'][data['est']].first;
    }
    return 'Ruta Desconocida';
  }

  
  /// Obtenemos el primer estatus de la pieza estacion busqueda
  static Future<Map<String, dynamic>> getFirstSttByEstBusqueda(Map<String, dynamic> data) async {

    _putIfAbsent(data['rta']);
    Map<String, dynamic> rstt = {};

    if(r.rutas.containsKey(data['rta'])) {
      r.rutas[data['rta']]['est'].forEach((key, value) {
        if(value == 'Buscando Piezas') {
          rstt = {'est':key, 'stt':r.rutas[data['rta']]['rta'][key].first, 'rta':data['rta']};
        }
      });
    }
    return rstt;
  }

  /// Obtenemos la estacion solicitada
  static String getEst(Map<String, dynamic> data) {

    _putIfAbsent(data['rta']);
    if(r.rutas.containsKey(data['rta'])) {
      return r.rutas[data['rta']]['est'][data['est']];
    }
    return 'Ruta Desconocida';
  }

  /// Obtenemos el estatus segun su estacion
  static String getSttByEst(Map<String, dynamic> data) {

    /// tmp puedes borrar despues
    if(data['rta'] == '1647977307172042') {
      data['rta'] = '1648924605064399';
    }
    /// fin tmp

    _putIfAbsent(data['rta']);
    if(r.rutas.containsKey(data['rta'])) {
      return r.rutas[data['rta']]['stt'][data['est']][data['stt']];
    }
    return 'Ruta Desconocida';
  }

}