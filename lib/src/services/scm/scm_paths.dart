import '../../config/sng_manager.dart';
import '../../vars/globals.dart';

class ScmPaths {

  static final Globals _globals = getSngOf<Globals>();

  ///  
  static getUri(String uri, {bool isLocal = false}) {

    final tipo = (isLocal) ? 'base_l' : 'base_r';
    final base = _globals.ipDbs[tipo];
    final uris = _paths();
    return '$base${uris[uri]}';
  }

  ///
  static Map<String, String> _paths() {

    return <String, String>{
      'buscar_cotizaciones_orden':'scp/buscar-cotizaciones-orden/',
    };
  }
}