import 'contacts_entity.dart';
import '../services/puppetter/vars_puppe.dart' show CmdType;

/// Esta clase es para crear el archivo minimo que es pasado
/// entre las distintas carpetas, drash, sended, await etc.
class ScmEntity {

  int intents = 0;
  int idCamp = 0;
  int idReceiver = 0;
  String curc = '';
  String nombre = '';
  String rCurc = '';
  String rName = '';
  String seccName = '';
  List<CmdType> cmds = [];
  bool forceNotSend = false;
  /// El path del archivo principal contenedor de los datos del msg
  String data = '';
  ContactEntity receiver = ContactEntity();
  List<String> errores = [];

  ///
  void fromCampaing(
    int idCampaing, String pathData,
    Map<String, dynamic> receptor,
    Map<String, dynamic> remiter)
  {
    intents = 0;
    idCamp = idCampaing;
    idReceiver = receptor['c_id'];
    curc = receptor['c_curc'];
    nombre = receptor['c_nombre'];
    rCurc = remiter['curc'];
    rName = remiter['nombre'];
    forceNotSend = false;
    data = pathData;
    receiver = ContactEntity()..fromServer(receptor);
    errores = [];
  }

  ///
  void fromProvider(Map<String, dynamic> json) {

    if(json.isEmpty){ return; }

    intents = json['intents'];
    idCamp = json['idCamp'];
    idReceiver = json['idReceiver'];
    curc = json['curc'];
    nombre = json['nombre'];
    rCurc = json['rCurc'];
    rName = json['rName'];
    seccName = (json.containsKey('seccName')) ? json['seccName'] : '';
    cmds = [];
    if(json.containsKey('cmds')) {
      cmds = commandToEnum(List<String>.from(json['cmds']));
    }
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
    rCurc = json['rCurc'];
    rName = json['rName'];
    seccName = json['seccName'];
    cmds = commandToEnum(json['cmds']);
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
      'rCurc' : rCurc,
      'rName' : rName,
      'seccName' : seccName,
      'cmds' : commandToJson(),
      'data': data,
      'receiver': receiver.toReceiver(),
      'errores': errores,
    };
  }

  ///
  List<String> commandToJson() {
    if(cmds.isEmpty){ return []; }
    return cmds.map((e) => e.name).toList();
  }

  ///
  List<CmdType> commandToEnum(List<String> commands) {

    if(commands.isEmpty){ return []; }

    List<CmdType> c = [];
    Map<String, CmdType> tmp = {};
    CmdType.values.map((e) {
      tmp.putIfAbsent(e.name, () => e);
    }).toList();

    commands.map((key){
      if(tmp.containsKey(key)) {
        c.add(tmp[key]!);
      }
    }).toList();

    return c;
  }
}