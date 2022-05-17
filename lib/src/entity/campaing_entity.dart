class CampaingEntity {

  int id = 0;
  String titulo = '';
  String despec = '';
  int priority = 0;

  ///
  void fromJson(Map<String, dynamic> json) {

    id = json['id'];
    titulo = json['titulo'];
    despec = json['despec'];
    priority = json['priority'];
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'titulo': titulo,
      'despec': despec,
      'priority': priority
    };
  }

  ///
  Map<String, dynamic> toJsonMini() {

    return {
      'id': id,
      'titulo': titulo,
      'priority': priority
    };
  }

}