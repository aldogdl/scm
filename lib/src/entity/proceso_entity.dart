import 'campaing_entity.dart';
import 'contacts_entity.dart';

class ProcesoEntity {

  int id = 0;
  Map<String, dynamic> target = {};
  Map<String, dynamic> src = {};
  DateTime createdAt = DateTime.now();
  String sendAt = 'now';
  ContactEntity emiter = ContactEntity();
  ContactEntity remiter = ContactEntity();
  CampaingEntity campaing = CampaingEntity();
  List<int> receivers = [];
  List<int> toSend = [];
  List<int> sended = [];
  List<int> noSend = [];

  ///
  void fromJson(Map<String, dynamic> json) async {

    id = json['id'];
    target = json['target'];
    src = json['src'];
    createdAt = DateTime.parse(json['createdAt']['date']);
    sendAt = json['sendAt'];
    emiter = ContactEntity()..fromJson(json['emiter']);
    remiter = ContactEntity()..fromJson(json['remiter']);
    campaing = CampaingEntity()..fromJson(json['campaing']);
    receivers = List<int>.from(json['receivers']);
    toSend = List<int>.from(json['toSend']);
    if(json.containsKey('sended')) {
      sended = List<int>.from(json['sended']);
    }else{
      sended = [];
    }
    noSend = List<int>.from(json['noSend']);
  }

  ///
  Map<String, dynamic> toJsonMini() {

    return {
      'id': id,
      'src': src,
      'createdAt': createdAt,
      'emiter': emiter.toJsonMini(),
      'remiter': remiter.toJsonMini(),
      'campaing': campaing.toJsonMini(),
      'toSend': toSend,
      'sended': sended,
    };
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'target': target,
      'src': src,
      'createdAt': createdAt,
      'sendAt': sendAt,
      'emiter': emiter.toJson(),
      'remiter': remiter.toJson(),
      'campaing': campaing.toJson(),
      'receivers': receivers,
      'toSend': toSend,
      'sended': sended,
      'noSend': noSend
    };
  }


}