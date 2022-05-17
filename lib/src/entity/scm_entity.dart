import 'package:scm/src/entity/contacts_entity.dart';

/// Esta clase es para crear el archivo minimo que es pasado
/// entre las distintas carpetas, drash, sended, await etc.
class ScmEntity {

  int intents = 0;
  /// El idCamp es el id del mensaje en si BD. scm_camp
  int idCamp = 0;
  bool forceNotSend = false;
  /// Nombre del Archivo
  String nFile = '';
  /// El path a los datos de este receptor
  String data = '';
  int idReceiver = 0;
  List<int> nextReceivers = [];
  ContactEntity receiver = ContactEntity();
  List<String> errores = [];

  ///
  void init(Map<String, dynamic> json, {int idCampaing = 0}) {

    intents = 0;
    idCamp = idCampaing;
    nFile = json['nFile'];
    data = json['data'];
    idReceiver = json['idReceiver'];
    nextReceivers = json['nextReceivers'];
    forceNotSend = false;
    receiver = ContactEntity();
    errores = <String>[];
  }

  ///
  void fromJson(Map<String, dynamic> json) {

    intents = json['intents'];
    idCamp = json['idCamp'];
    forceNotSend = (!json.containsKey('forceNotSend'))
      ? false : json['forceNotSend'];
    nFile = json['nFile'];
    data = json['data'];
    idReceiver = json['idReceiver'];
    nextReceivers = List<int>.from(json['nextReceivers']);
    receiver = ContactEntity()..fromJson(json['receiver']);
    errores = List<String>.from(json['errores']);
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'intents': intents,
      'idCamp': idCamp,
      'nFile': nFile,
      'data': data,
      'idReceiver': idReceiver,
      'nextReceivers': nextReceivers,
      'receiver': receiver.toReceiver(),
      'errores': errores,
    };
  }
}