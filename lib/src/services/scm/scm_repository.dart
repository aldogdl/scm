import 'scm_paths.dart';
import '../../services/scm/scm_http.dart';
import '../../config/sng_manager.dart';
import '../../vars/globals.dart';

class ScmRepository {

  final Globals globals = getSngOf<Globals>();
  Map<String, dynamic> result = {'abort':false, 'msg': 'ok', 'body':{}};

  ///
  void clean() {
    result = {'abort':false, 'msg': 'ok', 'body':{}};
  }

  ///
  Future<void> setBuscarCotizacionesOrden(Map<String, dynamic> data, {bool isLocal = false}) async {

    await ScmHttp.post(
      ScmPaths.getUri('buscar_cotizaciones_orden', isLocal: isLocal), data
    );
    result = ScmHttp.result;
    ScmHttp.clean();
  }

}