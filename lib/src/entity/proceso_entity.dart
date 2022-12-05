import 'contacts_entity.dart';

class ProcesoEntity {

  int id = 0;
  String target = '';
  // El manifest es el tipo de campaña que se esta procesando
  // TIPOS: [
    // main : Es la campaña principal del primer rastreo de aqui se alimenta el Dashboard del SCP 
    // assig: Campañas que son reasignaciones de piezas para la misma orden
    // reme : Campañas que son utilizadas para hacer recordatorios de que respondan a los msgs por whats
    // hi   : Campañas que sirven como saludos de cualquier tipo
  // ]
  String manifest = '';
  Map<String, dynamic> data = {};
  Map<String, dynamic> src = {};
  DateTime createdAt = DateTime.now();
  String sendAt = 'now';
  ContactEntity emiter = ContactEntity();
  ContactEntity remiter = ContactEntity();
  // los Paths
  String filename = '';
  String fcenlog = '';
  String fmetrix = '';
  String freceivers = '';
  String expediente = '';
  String pathReceivers = '';

  List<int> receivers = [];
  List<int> toSendIds = [];
  List<String> toSend = [];
  List<String> sended = [];
  List<String> noSend = [];
  List<String> drash  = [];
  // El registro del tipo de campaña
  String titulo = '';
  String despec = '';
  int priority = 0;
  String slug = '';
  String msgTxt = '';
  bool isConFilt = true;

  ///
  void fromJson(Map<String, dynamic> json) async {

    id = json['id'];
    target = json['target'];
    manifest = (json.containsKey('manifest')) ? json['manifest'] : 'main';
    if(json.containsKey(json['target'])) {
      data = Map<String, dynamic>.from(json[json['target']]);
    }else{
      if(json.containsKey('data')) {
        data = json['data'];
      }
    }
    src = json['src'];
    createdAt = DateTime.parse(json['created']);
    sendAt = json['sendAt'];
    emiter = ContactEntity()..fromJson(json['emiter']);
    remiter = ContactEntity()..fromJson(json['remiter']);
    receivers = (json['src'].containsKey('receivers'))
      ? List<int>.from(json['src']['receivers'])
      : [];
    toSendIds = List<int>.from(json['to_send_ids']);
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
    if(json.containsKey('path_receivers')) {
      pathReceivers = json['path_receivers'];
    }
    noSend = List<String>.from(json['noSend']);
    titulo = json['titulo'];
    despec = json['despec'];
    priority = json['priority'];
    slug = json['slug'];
    msgTxt = json['msgTxt'];
    isConFilt = json['isConFilt'];
    filename = json['filename'];
    fcenlog = json['fcenlog'];
    fmetrix = json['fmetrix'];
    freceivers = json['freceivers'];
    expediente = json['expediente'];
  }

  ///
  Map<String, dynamic> toJsonMini() {

    return {
      'id': id,
      'src': src,
      'target': target,
      'manifest': manifest,
      'created': createdAt.toIso8601String(),
      'emiter': emiter.toJsonMini(),
      'remiter': remiter.toJsonMini(),
      'titulo': titulo,
      'priority': priority,
      'msgTxt': msgTxt,
      'toSend': toSend.length,
      'noSend': noSend.length,
      'sended': sended.length,
       target: getDataMini()
    };
  }

  ///
  Map<String, dynamic> getDataMini() {

    if(data.containsKey('anio')) {
      return {
        'id': data['id'],
        'anio': data['anio'],
        'marca': data['marca']['nombre'],
        'modelo': data['modelo']['nombre'],
        'piezas': data['piezas'].length,
      };
    }
    return {};
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'target': target,
      'src': src,
      'filename': filename,
      'fcenlog': fcenlog,
      'fmetrix': fmetrix,
      'freceivers': freceivers,
      'expediente': expediente,
      'path_receivers': pathReceivers,
      'created': createdAt.toIso8601String(),
      'sendAt': sendAt,
      'emiter': emiter.toJson(),
      'remiter': remiter.toJson(),
      'receivers': receivers,
      'to_send_ids': toSendIds,
      'toSend': toSend,
      'sended': sended,
      'noSend': noSend,
      'drash': drash,
      'data': data,
      'titulo': titulo,
      'despec': despec,
      'priority': priority,
      'slug': slug,
      'msgTxt': msgTxt,
      'isConFilt': isConFilt
    };
  }

  ///
  Map<String, dynamic> toJsonSend() {

    return {
      'id': id,
      'target': target,
      'src': src,
      'filename': filename,
      'fcenlog': fcenlog,
      'fmetrix': fmetrix,
      'freceivers': freceivers,
      'expediente': expediente,
      'path_receivers': pathReceivers,
      'created': createdAt.toIso8601String(),
    };
  }

  ///
  Map<String, dynamic> buildCampoCamping() {

    return {
      'main' : '',
      'assig': [],
      'reme': [],
      'hi': [],
    };
  }
}