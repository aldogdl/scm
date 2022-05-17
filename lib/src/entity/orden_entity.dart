class OrdenEntity {

  int id = 0;
  int anio = 0;
  DateTime? createdAt;
  String est = '0';
  String stt = '0';
  bool isNac = true;
  int idMarca = 0;
  int idModelo = 0;
  String logoMarca = '0';
  String marca = '0';
  String modelo = '0';
  
  ///
  void fromJson(Map<String, dynamic> json) {

    id = json['id'];
    anio = json['anio'];
    est = json['est'];
    stt = json['stt'];
    isNac = json['isNac'];
    if(json['marca'].runtimeType == String) {
      idMarca = json['idMarca'];
      marca = json['marca'];
      logoMarca = json['logoMarca'];
    }else{
      idMarca = json['marca']['id'];
      marca = json['marca']['nombre'];
      logoMarca = json['marca']['logo'];
    }
    if(json['modelo'].runtimeType == String) {
      idModelo = json['idModelo'];
      modelo = json['modelo'];
    }else{
      idModelo = json['modelo']['id'];
      modelo = json['modelo']['nombre'];
    }

    if(json['createdAt'].runtimeType == String) {
      createdAt = DateTime.parse(json['createdAt']);
    }else{
      createdAt = DateTime.parse(json['createdAt']['date']);
    }
  }
  
  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'anio': anio,
      'est': est,
      'stt': stt,
      'isNac': isNac,
      'idMarca': idMarca,
      'marca': marca,
      'logoMarca': logoMarca,
      'idModelo': idModelo,
      'modelo': modelo,
      'createdAt': (createdAt != null) ? createdAt!.toIso8601String() : '',
    };
  }

  // ///
  // void fromFile(Map<String, dynamic> json) {

  //   id = json['id'];
  //   anio = json['anio'];
  //   est = json['est'];
  //   stt = json['stt'];
  //   isNac = json['isNac'];
  //   ruta = json['ruta'];
  //   idMarca = json['idMarca'];
  //   marca = json['marca'];
  //   idModelo = json['idModelo'];
  //   modelo = json['modelo'];
  //   createdAt = DateTime.parse(json['createdAt']);
  // }
    
}