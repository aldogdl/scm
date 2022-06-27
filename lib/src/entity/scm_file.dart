import 'dart:io';

import '../services/get_paths.dart';

class ScmFile {

  final String prefixFldWrk = '_wk_';
  final String prefixFldSended = 'sended_';
  final String sF = '-';
  final String suf = '-child-';
  final String sufM = '-main-';
  String pathOrigin  = '';
  // Constructor
  ScmFile({
    this.pathOrigin = ''
  }) {
    if(pathOrigin.isNotEmpty) {  parse();  }
  }

  /// La [PRIORIDAD] de msg impuesto por la tabla scm_camps.
  int pri = -1;
  /// El ID del [TARGET]. el cuerpo del mensaje es decir 
  /// Una Orden, Una Pieza y si es otros se queda como _
  String tar = '_';
  /// El ID del [MENSAJE] de la tabla scm_camps.
  int msg = -1;
  /// El ID del [RECEPTOR] a quien se le va a enviar este mensaje.
  /// para el archivo principal ira la letra R
  String rec = 'R';
  DateTime created = DateTime.now();

  String sep = GetPaths.getSep();
  String root = GetPaths.getPathRoot();
  String nameExt     = '.json';
  String nameFileSinExt = '';
  String nameFile    = '';
  String nameFileWrk = '';
  String nameFileWrkSinExt = '';
  String pathSinFile = '';

  ///
  void fromFileCampaing(Map<String, dynamic> json) {

    msg = json['id'];
    if(json.containsKey('target')) {
      tar = '${json[json['target']]['id']}';
    }else{
      tar = '_';
    }
    pri = json['campaing']['priority'];
    created = DateTime.now();
    if(json.containsKey('ext')) {
      nameExt = json['ext'];
    }
  }

  /// Esta fnc solo funciona despues de haber hidratado con anterioridad
  /// la clase desde... fromFileCampaing | 
  String createNameFile({String receptor = 'R'}) {
    
    rec = receptor;
    int ct = created.millisecondsSinceEpoch;
    nameFileSinExt = '$pri$sF$msg$sF$tar$suf$rec$sF$ct';
    nameFile = '$nameFileSinExt$nameExt';
    nameFileWrk = '$prefixFldWrk$nameFileSinExt$nameExt';
    nameFileWrkSinExt = '$prefixFldWrk$nameFileSinExt';
    return nameFile;
  }

  ///
  Map<String, dynamic> toScmEntity(String pathOriginStage, int receiverId) {
    // return {
    //   'data': convertPathTo(, pathOriginStage),
    //   'idReceiver': receiverId,
    // };
    return {};
  }

  // ///
  // String convertPathTo(FoldStt to, String from, {bool withoutWorking = false}) {

  //   List<String> partes = from.split(sep);
  //   var nameF = partes.last;
  //   if(withoutWorking) {
  //     nameF = nameFile;
  //   }
  //   final pathTo = GetPaths.getPathsFolderTo(getFolder(to));
  //   return '${pathTo!.path}$sep$nameF';
  // }

  // /// Recuperamos el nombre del folder desde el enum.
  // String getFolder(FoldStt fld) {
  //   if(fld.name == 'wait') {
  //     return 'scm_a${fld.name}';
  //   }
  //   return 'scm_${fld.name}';
  // }

  /// A partir de la propiedad pathOrigin
  void parse() {

    List<String> partes = pathOrigin.split(sep);
    nameFile = partes.removeLast();
    if(nameFile.startsWith(prefixFldWrk)) {
      nameFileWrk = nameFile;
      nameFile = nameFile.replaceFirst(prefixFldWrk, '');
    }else{
      nameFileWrk = '$prefixFldWrk$nameFile';
    }
    pathSinFile = partes.join(sep);
    partes = nameFile.split('.');
    nameExt= partes.last;
    nameFileSinExt = partes.first;
    if(nameFileWrk.isNotEmpty) {
      partes = nameFileWrk.split('.');
      nameFileWrkSinExt = partes.first;
    }

    partes = nameFile.split(sF);
    pri = int.parse(partes[0]);
    msg = int.parse(partes[1]);
    tar = partes[2];
    partes = partes.last.split('.');
    created = DateTime.fromMillisecondsSinceEpoch(int.parse(partes.first));
  }

  /// Renombramos el archivo pasado desde el constructor de la clase con la
  /// marca indicada en el parametro | put | del |
  Future<String> prefixWorking({String accion = 'put'}) async {

    if(pathOrigin.isNotEmpty) {
      
      var nameAbs = '$pathSinFile$sep';
      if(accion == 'put') {
        nameAbs = '$nameAbs$nameFileWrk';
      }else{
        nameAbs = '$nameAbs$nameFile';
      }
      File fileContent = File(pathOrigin);
      if(fileContent.existsSync()) {
        fileContent = fileContent.renameSync(nameAbs);
      }
      return nameAbs;
    }
    return pathOrigin;
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'prioridad': pri,
      'target': tar,
      'mensaje': msg,
      'receptor': rec,
      'sep': sep,
      'root': root,
      'nameExt': nameExt,
      'nameFileSinExt': nameFileSinExt,
      'nameFile': nameFile,
      'nameFileWrk': nameFileWrk,
      'nameFileWrkSinExt': nameFileWrkSinExt,
      'pathSinFile': pathSinFile,
      'pathOrigin': pathOrigin,
      'created' : created
    };
  }

}