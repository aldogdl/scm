import 'package:scm/src/entity/contacts_entity.dart';

/// Esta clase es para crear el archivo minimo que es pasado
/// entre las distintas carpetas, drash, sended, await etc.
class ScmEntity {

  int intents = 0;
  int idCamp = 0;
  int idReceiver = 0;
  String curc = '';
  String nombre = '';
  bool forceNotSend = false;
  /// El path del archivo principal contenedor de los datos del msg
  String data = '';
  ContactEntity receiver = ContactEntity();
  List<String> errores = [];

  ///
  void fromCampaing(int idCampaing, String pathData, Map<String, dynamic> receptor) {

    intents = 0;
    idCamp = idCampaing;
    idReceiver = receptor['c_id'];
    curc = receptor['c_curc'];
    nombre = receptor['c_nombre'];
    forceNotSend = false;
    data = pathData;
    receiver = ContactEntity()..fromServer(receptor);
    errores = [];
  }

  ///
  void fromProvider(Map<String, dynamic> json) {

    intents = json['intents'];
    idCamp = json['idCamp'];
    idReceiver = json['idReceiver'];
    curc = json['curc'];
    nombre = json['nombre'];
    forceNotSend = (!json.containsKey('forceNotSend'))
      ? false : json['forceNotSend'];
    data = json['data'];
    receiver = ContactEntity()..fromReceiver(json['receiver']);
    errores = List<String>.from(json['errores']);
  }

  ///
  void fromJson(Map<String, dynamic> json) {

    intents = json['intents'];
    idCamp = json['idCamp'];
    idReceiver = json['idReceiver'];
    curc = json['curc'];
    nombre = json['nombre'];
    forceNotSend = (!json.containsKey('forceNotSend'))
      ? false : json['forceNotSend'];
    data = json['data'];
    receiver = ContactEntity()..fromJson(json['receiver']);
    errores = List<String>.from(json['errores']);
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'intents': intents,
      'idCamp': idCamp,
      'idReceiver': idReceiver,
      'curc': curc,
      'nombre': nombre,
      'data': data,
      'receiver': receiver.toReceiver(),
      'errores': errores,
    };
  }
}