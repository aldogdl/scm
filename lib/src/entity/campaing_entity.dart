class CampaingEntity {

  int id = 0;
  String titulo = '';
  String despec = '';
  int priority = 0;
  String slug = '';
  String msgTxt = '';
  bool isConFilt = true;

  ///
  void fromJson(Map<String, dynamic> json) {

    id = json['id'];
    titulo = json['titulo'];
    despec = json['despec'];
    priority = json['priority'];
    slug = json['slug'];
    msgTxt = json['msgTxt'];
    isConFilt = json['isConFilt'];
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'titulo': titulo,
      'despec': despec,
      'priority': priority,
      'slug': slug,
      'msgTxt': msgTxt,
      'isConFilt': isConFilt
    };
  }

  ///
  Map<String, dynamic> toJsonMini() {

    return {
      'id': id,
      'titulo': titulo,
      'priority': priority,
      'slug': slug
    };
  }

}