import '../services/get_paths.dart';
import '../services/my_http.dart';

class ToServer {

  static Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':[]};

  ///
  static void clean() {
    result = {'abort':false, 'msg':'ok', 'body':[]};
  }

  ///
  static Future<void> buildRegInBD(int idCamp, int idReceiver, {
    String stt = 'i', bool isLocal = true
  }) async {

    String path = await GetPaths.getUri('set_reg_envio', isLocal: isLocal);
    await MyHttp.post(
      path, {'camp': idCamp, 'receiver': idReceiver, 'stt': stt, 'isLast': false}
    );
    result = MyHttp.result;
  }

  ///
  static Future<void> updateRegInBD(int idReg, String stt) async {

    String path = await GetPaths.getUri('set_regs_byids');
    await MyHttp.get('$path$idReg/$stt');
  }

  ///
  static Future<Map<String, dynamic>> sendPush(String query) async {

    Uri uri = await GetPaths.getUriApiHarbi('push', query);
    await MyHttp.getHarbi(uri);
    return MyHttp.result;
  }
}