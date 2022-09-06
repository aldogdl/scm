import '../repository/to_server.dart';

enum PushCamp { orden, avo, cotz, est, idMsg }

class PushSend {

  /// String base para los push
  static const _event = 'event%self-fnc%notifAll_UpdateData-data%query=scm,secc=metrik';

  /// Analisamos si los datos de la campaña son de una orden
  static Map<PushCamp, dynamic> _isParaOrden
    (Map<String, dynamic> enprocc, String est)
  {

    Map<PushCamp, dynamic> meta = {};

    if(enprocc.isNotEmpty) {
      if(enprocc.containsKey('target')) {
        if(enprocc['target'] == 'orden') {
          meta = schemaMetadataPush();
          if(enprocc.containsKey('orden')) {
            meta[PushCamp.orden] = '${enprocc['orden']['id']}';
          }else{
            if(enprocc.containsKey('data')) {
              meta[PushCamp.orden] = '${enprocc['data']['id']}';
            }
          }
          meta[PushCamp.avo] = '${enprocc['remiter']['id']}';
          meta[PushCamp.est] = est;

          int totCotz = 0;
          int sendedCotz = 0;
          int drash = 0;
          // Enviados
          if(enprocc.containsKey('sended')) {
            sendedCotz = enprocc['sended'].length;
          }
          // Total para enviar
          if(enprocc.containsKey('toSend')) {
            totCotz = enprocc['toSend'].length;
          }
          // En Papelera
          if(enprocc.containsKey('drash')) {
            drash = enprocc['drash'].length;
          }
          meta[PushCamp.cotz] = 'E:$sendedCotz | T:$totCotz | P:$drash';
        }
      }
    }

    return meta;
  }

  ///
  static Map<PushCamp, dynamic> schemaMetadataPush() {
    return {
      PushCamp.orden:'0', PushCamp.avo:'0', PushCamp.idMsg: _getIdMsg,
      PushCamp.est:'0', PushCamp.cotz:'0'
    };
  }

  /// Este metodo envia Notiff. de cambio de estacion:
  /// Est: 0.- Stage, 1.- Bandeja, 2.- En Cola, 3.-Enviandoce,
  /// 4.- Papelera, 5.- Enviado
  static Future<Map<String, dynamic>> ofChangeTo
    (String est, Map<String, dynamic> dataEnProcess) async 
  {
    // En el metodo _isParaOrden se arma Ej. E:0 | T:2 | P:1
    final meta = _isParaOrden(dataEnProcess, est);
    String campos = '';
    if(meta.isNotEmpty) {
      campos = _encode(meta);
    }
    if(campos.isNotEmpty) {
      return await _send(_buildSchema(campos));
    }
    return {};
  }

  /// Este metodo envia Notiff. de Metricas de envio:
  /// E.- Enviados, T.- Total para envio, P.- En Papelera
  /// Ej. E:0|T:2|P:1
  static Future<Map<String, dynamic>> sended(Map<String, dynamic> dataEnProcess) async 
  {
    // En el metodo _isParaOrden se arma Ej. E:0 | T:2 | P:1
    final meta = _isParaOrden(dataEnProcess, '3');
    String campos = '';
    if(meta.isNotEmpty) {
      campos = _encode(meta);
    }
    if(campos.isNotEmpty) {
      return await _send(_buildSchema(campos));
    }
    return {};
  }

  ///
  static String _encode(Map<PushCamp, dynamic> meta) {

    List<String> query = [];
    meta.forEach((key, value) { query.add('${key.name}=$value'); });
    return query.join(',');
  }

  ///
  static String _buildSchema(String campos) => '$_event,$campos';

  ///
  static get _getIdMsg => DateTime.now().millisecondsSinceEpoch.toString();

  ///
  static Future<Map<String, dynamic>> _send(String query) async => ToServer.sendPush(query);
}
