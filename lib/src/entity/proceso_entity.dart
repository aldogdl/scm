import 'campaing_entity.dart';
import 'contacts_entity.dart';

class ProcesoEntity {

  int id = 0;
  String target = '';
  Map<String, dynamic> data = {};
  Map<String, dynamic> src = {};
  DateTime createdAt = DateTime.now();
  String sendAt = 'now';
  ContactEntity emiter = ContactEntity();
  ContactEntity remiter = ContactEntity();
  CampaingEntity campaing = CampaingEntity();
  List<int> receivers = [];
  List<String> toSend = [];
  List<String> sended = [];
  List<String> noSend = [];
  List<String> drash  = [];

  ///
  void fromJson(Map<String, dynamic> json) async {

    id = json['id'];
    target = json['target'];
    if(json.containsKey(json['target'])) {
      data = Map<String, dynamic>.from(json[json['target']]);
    }else{
      if(json.containsKey('data')) {
        data = json['data'];
      }
    }
    src = json['src'];
    if(json['createdAt'].runtimeType == String) {
      createdAt = DateTime.parse(json['createdAt']);
    }else{
      if(json['createdAt'].containsKey('date')) {
        createdAt = DateTime.parse(json['createdAt']['date']);
      }else{
        createdAt = DateTime.parse(json['createdAt']);
      }
    }

    sendAt = json['sendAt'];
    emiter = ContactEntity()..fromJson(json['emiter']);
    remiter = ContactEntity()..fromJson(json['remiter']);
    campaing = CampaingEntity()..fromJson(json['campaing']);
    receivers = (json['src'].containsKey('receivers'))
      ? List<int>.from(json['src']['receivers'])
      : [];
    toSend = List<String>.from(json['toSend']);
    if(json.containsKey('sended')) {
      sended = List<String>.from(json['sended']);
    }else{
      sended = [];
    }
    if(json.containsKey('drash')) {
      drash = List<String>.from(json['drash']);
    }else{
      drash = [];
    }
    noSend = List<String>.from(json['noSend']);
  }

  ///
  Map<String, dynamic> toJsonMini() {

    return {
      'id': id,
      'src': src,
      'createdAt': createdAt.toIso8601String(),
      'emiter': emiter.toJsonMini(),
      'remiter': remiter.toJsonMini(),
      'campaing': campaing.toJsonMini(),
      'toSend': toSend,
      'noSend': noSend,
      'sended': sended,
    };
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'target': target,
      'src': src,
      'createdAt': createdAt.toIso8601String(),
      'sendAt': sendAt,
      'emiter': emiter.toJson(),
      'remiter': remiter.toJson(),
      'campaing': campaing.toJson(),
      'receivers': receivers,
      'toSend': toSend,
      'sended': sended,
      'noSend': noSend,
      'drash': drash,
      'data': data
    };
  }


}