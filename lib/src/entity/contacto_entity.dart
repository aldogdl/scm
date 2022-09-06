
class ContactoEntity {

  int id = 0;
  int empresaId = 0;
  String curc = '';
  List<String> roles = [];
  String password = '';
  String nombre = '';
  String tkServ = '';
  bool isCot = false;
  String cargo = '';
  String celular = '';

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'empresaId': empresaId,
      'curc': curc,
      'roles': roles,
      'password': (password.isEmpty) ? '1234567' : password,
      'nombre': nombre,
      'isCot': isCot,
      'cargo': cargo,
      'celular': celular
    };
  }

  ///
  Map<String, dynamic> toJsonForUpdateHarbi() {

    return {
      'idC' : id,
      'nombre' : nombre, 
      'password' : password, 
      'curc' : curc,
      'roles' : roles
    };
  }

  ///
  Map<String, dynamic> toJsonForAdminUser() {
    
    return {
      'id': id,
      'empresaId': 1,
      'curc': curc,
      'roles': roles,
      'password': (password.isEmpty) ? '1234567' : password,
      'nombre': nombre,
      'isCot': false,
      'cargo': cargo,
      'celular': celular,
    };
  }

  /// Este metodo es usado para hidratar la variable de globals es solo para
  /// los usuarios que estan usando esta app.
  void fromFile(Map<String, dynamic> user) {
    id = user['id'];
    curc = user['curc'];
    roles = List<String>.from(user['roles']);
    password = (user.containsKey('password')) ? user['password'] : '0';
    nombre = user['nombre'];
    if(user.containsKey('token')) {
      tkServ = user['token'];
    }
    if(user.containsKey('tkServ')) {
      tkServ = user['tkServ'];
    }
  }

  Map<String, dynamic> userToJson() {
    return {
      'id': id,
      'curc': curc,
      'roles': roles,
      'password': password,
      'nombre': nombre,
      'tkServ': tkServ,
    };
  }

  Map<String, dynamic> userConectado({
    required String app, required String ip, required String idCon
  }) {
    return {
      'id': id,
      'ip': ip,
      'app':app,
      'curc': curc,
      'name': nombre,
      'idCon': idCon,
      'roles': roles,
      'pass': password,
    };
  }

  ///
  void fromFrmToList(Map<String, dynamic> dataFrm) {

    Map<String, dynamic> data = (dataFrm.containsKey('contacto'))
      ? dataFrm['contacto'] : dataFrm;

    id = data['id'];
    curc = data['curc'];
    roles = data['roles'];
    password = data['password'];
    nombre = data['nombre'];
    isCot = data['isCot'];
    cargo = data['cargo'];
    celular = data['celular'];
    data = {}; dataFrm = {};
  }

}