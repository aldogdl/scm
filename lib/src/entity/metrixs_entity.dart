/// Metricas son datos que estan relacionados
/// a la campaña completa, es decir, no a cada
/// mensaje individual, es un panorama general
/// ... Cada orden tiene sus metricas
class MetrixEntity {

  // El status de envio que va en metrix
  // 0 sin enviar, 1 enviadoce, 2 papelera, 3 enviado
  int stt = 0;
  // cantidad total de receptores
  List<int> toTot = [];
  // Cantidad de receptores enviados.
  List<int> sended = [];
  // Cantidad de receptores en papelera.
  List<int> drash = [];
  // Aquien se la estoy enviando actualmente
  int to = 0;
  // Cant. campañas vistas
  int see = 0;
  // Cant. No la tengo
  int ntg = 0;
  // Total de respuestas
  int rsp = 0;
  // Total de piezas
  int tpz = 0;
  // La hora de inicio y fin del envio
  String hIni = '0';
  String hFin = '0';
  // Respuestas por pieza
  Map<String, dynamic> rpp = {};
  // No la tengo por pieza
  Map<String, dynamic> ntpp = {};

  ///
  void setInit({
    required List<int> receptores, required List<int> tpzV
  }) {

    Map<String, dynamic> items = {};
    for (var idP in tpzV) {
      items.putIfAbsent('$idP', () => <int>[]);
    }
    stt = 1;
    toTot = receptores;
    tpz = tpzV.length;
    rpp = items;
    ntpp = items;
    hIni = DateTime.now().toIso8601String();
  }
  
  ///
  Map<String, dynamic> getJsonByTarget(String target) {

    switch (target) {
      case 'orden':
        return toJson();
      default:
    }
    return {};
  }
  
  ///
  void fromJson(Map<String, dynamic> data) {

    stt = data['stt'];
    toTot = List<int>.from(data['toTot']);
    sended = List<int>.from(data['sended']);
    drash = List<int>.from(data['drash']);
    to = data['to'];
    see = data['see'];
    ntg = data['ntg'];
    rsp = data['rsp'];
    tpz = data['tpz'];
    rpp = Map<String, dynamic>.from(data['rpp']);
    ntpp = Map<String, dynamic>.from(data['ntpp']);
    hIni = data['hIni'];
    hFin = data['hFin'];
  }
  
  ///
  void passTo(String passTo, int idRe) {

    switch (passTo) {
      case 'drash':
        if(!drash.contains(idRe)) {
          drash.add(idRe);
        }
        break;
      default:
      if(!sended.contains(idRe)) {
        sended.add(idRe);
      }
    }
  }
  
  ///
  Map<String, dynamic> toJson() {
    return {
      'stt': stt,
      'toTot': toTot,
      'sended': sended,
      'drash': drash,
      'to': to,
      'see': see,
      'ntg': ntg,
      'rsp': rsp,
      'tpz': tpz,
      'rpp': rpp,
      'hIni': hIni,
      'hFin': hFin,
      'ntpp': ntpp
    };
  }

}