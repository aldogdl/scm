import 'contacts_entity.dart';

/// Esta clase es para crear el archivo minimo que es pasado
/// entre las distintas carpetas, drash, sended, await etc.
class ScmEntity {

  int intents = 0;
  int idCamp = 0;
  int idReceiver = 0;
  String curc = '';
  String fIni = '';
  String fFin = '';
  String nombre = '';
  String rCurc = '';
  String rName = '';
  String link = '';
  bool forceNotSend = false;
  /// El path del archivo principal contenedor de los datos del msg
  String data = '';
  ContactEntity receiver = ContactEntity();
  List<Map<String, dynamic>> errores = [];

  ///
  void fromProvider(Map<String, dynamic> json) {

    if(json.isEmpty){ return; }

    intents = json['intents'];
    idCamp = json['idCamp'];
    link = json['link'];
    idReceiver = json['idReceiver'];
    curc = json['curc'];
    fIni = (json.containsKey('fIni')) ? json['fIni'] : '';
    fFin = (json.containsKey('fFin')) ? json['fFin'] : '';
    nombre = json['nombre'];
    rCurc = json['rCurc'];
    rName = json['rName'];
    forceNotSend = (!json.containsKey('forceNotSend'))
      ? false : json['forceNotSend'];
    data = json['data'];
    receiver = ContactEntity()..fromReceiver(json['receiver']);
    errores = List<Map<String, dynamic>>.from(json['errores']);
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'intents': intents,
      'idCamp': idCamp,
      'link': link,
      'idReceiver': idReceiver,
      'curc': curc,
      'fIni': fIni,
      'fFin': fFin,
      'nombre': nombre,
      'rCurc' : rCurc,
      'rName' : rName,
      'data': data,
      'receiver': receiver.toReceiver(),
      'errores': errores,
    };
  }

}