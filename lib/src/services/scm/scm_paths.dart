import 'package:path/path.dart' as p;
import '../../config/sng_manager.dart';
import '../../vars/globals.dart';
enum FoldStt {
  wait, tray, drash, sended, hist, werr
}
class ScmPaths {

  static final Globals _globals = getSngOf<Globals>();
  static p.Style estiloPlatform = p.Style.windows;
  static const String prefixFldWrk = '_wk_';
  static const String sF = '-';

  /// Obtenemos el separador del sistema
  static String getSep() {
    var context = p.Context(style: estiloPlatform);
    return context.separator;
  }

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

  /// isPath indica si el archivo es una ruta absoluta
  /// de lo contrario solo es el nombre del archivo
  static String setPrefixWorking(String path, {bool isPath = true}) {

    String filename = path;
    String base = '';
    final s = getSep();
    if(isPath) {
      final partes = filename.split(s).toList();
      filename = partes.removeLast();
      base = partes.join(s);
    }
    if(!filename.startsWith(prefixFldWrk)) {
      if(base.isNotEmpty) {
        filename = '$base$s$prefixFldWrk$filename';
      }else{
        filename = '$prefixFldWrk$filename';
      }
    }else{
      if(base.isNotEmpty) {
        filename = '$base$s$filename';
      }
    }
    return filename.toLowerCase().trim();
  }

  /// isPath indica si el archivo es una ruta absoluta
  /// de lo contrario solo es el nombre del archivo
  static String removePrefixWork(String path, {bool isPath = true}) {

    String filename = path;
    if(isPath) {
      filename = filename.split(getSep()).toList().removeLast();
    }
    if(filename.startsWith(prefixFldWrk)) {
      filename = filename.replaceFirst(prefixFldWrk, '');
    }
    return filename.toLowerCase().trim();
  }

  ///
  static String createNameFileReceptor(int idCamp) {
    return '$idCamp$sF${DateTime.now().millisecondsSinceEpoch}.json';
  }

  ///
  static String extractNameFile(String path) {
    List<String> uriP = path.split(getSep()).toList();
    return uriP.removeLast();
  }
}