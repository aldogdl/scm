
class ContactEntity {

  int id = 0;
  String curc = '';
  List<String> roles = [];
  String nombre = '0';
  String cargo = '0';
  String celular = '0';
  bool isCot = true;
  int idE = 0;
  String empresa = '0';
  String domicilio = '0';
  int cp = 0;
  String telFijo = '0';
  bool isLocal = true;
  String latLng = '0';

  ///
  void fromJson(Map<String, dynamic> json) {
  
    id = json['id'];
    curc = json['curc'];
    roles = List<String>.from(json['roles']);
    nombre = json['nombre'];
    cargo = (json['cargo'].isEmpty) ? '0' : json['cargo'];
    celular = json['celular'];
    isCot = json.containsKey('isCot') ? json['isCot'] : isCot;
    
    if(json.containsKey('empresa')) {

      if(json['empresa'].runtimeType == String) {
        if(json['empresa'] != '0') {
          empresa = json['empresa'];
          idE = (json.containsKey('idE')) ? json['idE'] : 0;
          domicilio = (json.containsKey('domicilio')) ? json['domicilio'] : '0';
          cp = (json.containsKey('cp')) ? json['cp'] : 0;
          telFijo = (json.containsKey('telFijo')) ? json['telFijo'] : '0';
          isLocal = (json.containsKey('isLocal')) ? json['isLocal'] : true;
          latLng = (json.containsKey('latLng')) ? json['latLng'] : '0';
        }
      }else{
        idE = json['empresa']['id'];
        empresa = json['empresa']['nombre'];
        domicilio = json['empresa']['domicilio'];
        cp = json['empresa']['cp'];
        telFijo = json['empresa']['telFijo'];
        isLocal = json['empresa']['isLocal'];
        latLng = json['empresa']['latLng'];
      }
      
    }
  }

  ///
  void fromServer(Map<String, dynamic> json) {
    
    id = json['c_id'];
    curc = json['c_curc'];
    roles = List<String>.from(json['c_roles']);
    nombre = json['c_nombre'];
    isCot = json['c_isCot'];
    cargo = json['c_cargo'];
    celular = json['c_celular'];
    idE = json['e_id'];
    empresa = json['e_nombre'];
    domicilio = json['e_domicilio'];
    cp = json['e_cp'];
    isLocal = json['e_isLocal'];
    telFijo = json['e_telFijo'];
    latLng = json['e_latLng'];
  }

  ///
  Map<String, dynamic> toJsonMini() {

    return {
      'id': id,
      'curc': curc,
      'nombre': nombre,
      'empresa': empresa,
    };
  }

  ///
  Map<String, dynamic> toReceiver() {

    return {
      'id': id,
      'curc': curc,
      'nombre': nombre,
      'cargo': cargo,
      'celular': celular,
      'roles': roles,
      'empresa': empresa,
    };
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'curc': curc,
      'roles': roles,
      'nombre': nombre,
      'cargo': cargo,
      'celular': celular,
      'isCot': isCot,
      'idE': idE,
      'empresa': empresa,
      'domicilio': domicilio,
      'cp': cp,
      'telFijo': telFijo,
      'isLocal': isLocal,
      'latLng': latLng
    };
  }
  
}