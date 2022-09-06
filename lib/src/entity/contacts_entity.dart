
class ContactEntity {

  int id = 0;
  String curc = '';
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
  void fromReceiver(Map<String, dynamic> json) {
    
    if(json.containsKey('c_id')) {
      fromServer(json);
      return;
    }
    cargo = json['cargo'];
    celular = json['celular'];
    idE = json['idE'];
    empresa = json['empresa'];
  }

  ///
  void fromJson(Map<String, dynamic> json) {
  
    id = json['id'];
    curc = json['curc'];
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
    
    if(json.containsKey('id')) {
      fromReceiver(json);
      return;
    }

    id = json['c_id'];
    curc = json['c_curc'];
    nombre = json['c_nombre'];
    cargo = json['c_cargo'];
    celular = json['c_celular'];
    isLocal = json['e_isLocal'];
    idE = json['e_id'];
    empresa = json['e_nombre'];
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
      'cargo': cargo,
      'curc': curc,
      'celular': celular,
      'idE': idE,
      'empresa': empresa,
    };
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'curc': curc,
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