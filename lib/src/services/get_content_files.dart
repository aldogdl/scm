import 'dart:io';
import 'dart:convert';

import 'package:scm/src/entity/build_notiff.dart';

import '../entity/metrixs_entity.dart';
import '../entity/proceso_entity.dart';
import '../services/scm/scm_paths.dart';
import '../services/get_paths.dart';

class GetContentFile {

  ///
  static String get getSep => GetPaths.getSep();

  /// [r] Recuperamos el nombre del folder desde el enum.
  static String getFolder(FoldStt fld) {
    if(fld.name == 'wait') {
      return 'scm_a${fld.name}';
    }
    return 'scm_${fld.name}';
  }

  ///
  static String getAbsolutePathFolder(FoldStt fld) {
    final f = GetPaths.getPathsFolderTo(getFolder(fld));
    return (f != null) ? '${f.path}$getSep' : '';
  }

  /// Actualizamos la campaña con los datos enviado por parametro
  static void updateFileWorking(String fileWorking, Map<String, dynamic> data) {

    if(!fileWorking.contains(ScmPaths.prefixFldWrk)) {
      fileWorking = ScmPaths.setPrefixWorking(fileWorking);
    }
    final file = File(fileWorking);
    file.writeAsStringSync(json.encode(data));
  }

  /// Creamos el folder si no existe indicado por parametro
  static void createFolderIfAbsent(String path) {

    final dir = Directory(path);
    if(!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  /// [CON PUSH] Actualizamos el archivo de metricas al inicio de la
  /// toma de cada campaña
  static void setMetrixInit(ProcesoEntity enProceso) {

    final sep = GetPaths.getSep();
    final pathMetrix = '${enProceso.expediente}${enProceso.id}$sep${enProceso.fmetrix}';
    final metrix = MetrixEntity();

    Map<String, dynamic> data = {};
    
    final fMetrix = File(pathMetrix);
    switch (enProceso.target) {
      case 'orden':

        if(!fMetrix.existsSync()) {
          List<int> tpz = [];
          for (var i = 0; i < enProceso.data['piezas'].length; i++) {
            tpz.add(enProceso.data['piezas'][i]['id']);
          }
          
          metrix.setInit(
            receptores: enProceso.toSendIds, tpzV: tpz
          );
        }else{

          data = Map<String, dynamic>.from(json.decode(
            fMetrix.readAsStringSync()
          ));
          metrix.fromJson(data);
          metrix.stt = 1;
        }

        // En cualquiera de los dos casos, debemos almacenar en el
        // exp. de la orden el manifiesto de la campaña.
        setManifest(enProceso, '${enProceso.expediente}${enProceso.id}$sep');

        break;
      default:
    }

    data = metrix.getJsonByTarget(enProceso.target);
    if(!fMetrix.existsSync()) {
      fMetrix.createSync(recursive: true);
    }
    fMetrix.writeAsStringSync(json.encode(data));
    BuildNotiff.updateMetrix(enProceso);
  }

  /// El manifest es un string que indiza el tipo de campaña que
  /// se esta procesndo, solo para organizarla en el archivo del
  /// expediente principal de la orden, y desde la scp poder
  /// recuperar sus metricas.
  /// 
  /// El Path es la ruta absoluta a los datos (EXP.) de la campaña
  static void setManifest(ProcesoEntity enProceso, String path) {

    // abrir su expediente
    final expF = File('${enProceso.expediente}${getSep}orden.json');
    if(expF.existsSync()) {

      final exp = Map<String, dynamic>.from(json.decode(expF.readAsStringSync()));
      
      // Crear el campo camping si no existe
      if(!exp.containsKey('campings')) {
        exp['campings'] = enProceso.buildCampoCamping();
      }

      if(enProceso.manifest == 'main') {

        exp['campings'][enProceso.manifest] = enProceso.id; 
      }else{

        // actualizar el campo en caso de existir
        final current = List<Map<String, dynamic>>.from(
          exp['campings'][enProceso.target]
        );
        final has = current.indexWhere((e) => e.keys.contains('${enProceso.id}'));
        if(has != -1) {
          current[has]['${enProceso.id}'] = path;
        }else{
          current.add({'${enProceso.id}':path});
        }
        exp['campings'][enProceso.manifest] = current; 
      }

      expF.writeAsStringSync(json.encode(exp));
    }
  }

  /// Actualizamos el archivo de metricas cada ves que
  /// cambie a otro receptor
  static void setMetrixMiddle
    (ProcesoEntity enProceso, int idReceiver)
  {

    final sep = GetPaths.getSep();
    final pathMetrix = '${enProceso.expediente}${enProceso.id}$sep${enProceso.fmetrix}';
    File arch = File(pathMetrix);
    final metrix = MetrixEntity();

    Map<String, dynamic> data = {};
    
    switch (enProceso.target) {
      case 'orden':
        data = Map<String, dynamic>.from(json.decode(
          arch.readAsStringSync()
        ));
        metrix.fromJson(data);
        metrix.to = idReceiver;
        break;
      default:
    }

    data = metrix.getJsonByTarget(enProceso.target);
    arch.writeAsStringSync(json.encode(data));
  }

  /// Actualizamos el archivo de metricas al finalizar
  /// el envio de cada campaña
  static String setMetrixFinSendCamp(ProcesoEntity enProceso, int stt) {

    final sep = GetPaths.getSep();
    final pathMetrix = '${enProceso.expediente}${enProceso.id}$sep${enProceso.fmetrix}';
    final fMetrix = File(pathMetrix);
    final metrix = MetrixEntity();

    Map<String, dynamic> data = {};
    
    switch (enProceso.target) {
      case 'orden':
        data = Map<String, dynamic>.from(json.decode(
          fMetrix.readAsStringSync()
        ));
        metrix.fromJson(data);
        metrix.stt = stt;
        metrix.hFin= DateTime.now().toIso8601String();
        break;
      default:
    }
    
    data = metrix.getJsonByTarget(enProceso.target);
    fMetrix.writeAsStringSync(json.encode(data));

    final fI = DateTime.parse(metrix.hIni);
    final fF = DateTime.parse(metrix.hFin);
    final df = fF.difference(fI);
    if(df.inSeconds < 60) {
      return 'OK. TIEMPO DE PROCESO [ ${df.inSeconds} Seg.]';
    }else{
      return 'OK. TIEMPO DE PROCESO [ ${df.inMinutes} Min.]';
    }
  }

  /// Actualizamos el archivo de metricas pasando al receiver al campo de
  /// enviados o a papelera.
  static Future<void> updateMetrixReceiver
    (ProcesoEntity enProceso, String passTo, int idRec) async
  {
    final sep = GetPaths.getSep();
    final pathMetrix = '${enProceso.expediente}${enProceso.id}$sep${enProceso.fmetrix}';
    final fMetrix = File(pathMetrix);
    final metrix = MetrixEntity();

    Map<String, dynamic> data = {};
    
    switch (enProceso.target) {
      case 'orden':
        data = Map<String, dynamic>.from(json.decode(
          fMetrix.readAsStringSync()
        ));
        metrix.fromJson(data);
        metrix.passTo(passTo, idRec);
        break;
      default:
    }

    data = metrix.getJsonByTarget(enProceso.target);
    fMetrix.writeAsStringSync(json.encode(data));
  }

  /// [CON PUSH] Le quitamos la seña de archivo trabajando y
  /// lo movemos al folder indicado
  static Future<String> updateFilesFinSendCamp
    (ProcesoEntity proceso, String filename) async
  {
    String res = '';
    final fileCamp = File(filename);
    if(fileCamp.existsSync()) {
      final s = GetPaths.getSep();

      // Actualizamos el archivo actual
      fileCamp.writeAsStringSync(json.encode(proceso.toJson()));

      // Actualizar el expediente cent_log.json
      final ex = '${proceso.expediente}$s${proceso.id}$s${proceso.fcenlog}';
      File(ex).writeAsStringSync( json.encode(proceso.toJson()) );

      // Grabamos en metrix el tiempo final.
      final stt = (proceso.drash.isEmpty) ? 3 : 2;
      res = setMetrixFinSendCamp(proceso, stt);
      
      String fileTo = ScmPaths.removePrefixWork(filename);

      // Si hay errores necesito pasar el archivo a drash
      if(stt == 2) {
        final pathDrash = GetPaths.getPathsFolderTo(
          getFolder(FoldStt.drash)
        );
        fileCamp.renameSync('${pathDrash!.path}$s$fileTo');
      }else{

        // Si no hay errores dejar una copia minima en sended.
        final pathSend = GetPaths.getPathsFolderTo(
          getFolder(FoldStt.sended)
        );
        File('${pathSend!.path}$s$fileTo').writeAsStringSync(
          json.encode(proceso.toJsonSend())
        );
        fileCamp.deleteSync();
      }
    }else{
      res = 'ERROR, SIN FINALIZAR CAMPAÑA';
    }

    if(!res.startsWith('ERROR')) {
      BuildNotiff.updateMetrix(proceso);
    }
    return res;
  }

  /// Tratamos los archivos de cada receiver de la campaña con errores.
  static Future<bool> tratarErrores(String pathToCamp) async {
    
    bool isRecovery = false;

    // Abrir el archivo campaña para ver si efectivamente hay receivers con error
    final camp = await getMsgToMap(pathToCamp);
    final filesErr = List<String>.from(camp['drash']);
    if(filesErr.isNotEmpty) {

      bool delFolder = false;
      // Buscar en la carpeta de werr todos los que hay actualmente
      final pathErr = getAbsolutePathFolder(FoldStt.werr);
      final dir = Directory('$pathErr${camp['src']['id']}$getSep${camp['id']}');
      
      if(dir.existsSync()) {

        // Los archivos receivers con errores
        var archsErr = dir.listSync().toList();
        if(archsErr.isNotEmpty) {
          
          await cleanFileErrsLost(archsErr, camp);
          archsErr = dir.listSync().toList();
          isRecovery = await recoveryCampsIfExist(archsErr, camp['path_receivers']);

          // Si la carpeta contenedora [werr] queda sin errores la borramos
          archsErr = dir.listSync().toList();
          if(archsErr.isEmpty) { delFolder = true; }

        }else{
          delFolder = true;
        }
        
      }else{
        // Existen archivos con error en el archivo main de camp
        // pero no existe ningun archivo en WERR folder.
      }

      if(delFolder) {
        try {
          Directory('$pathErr${camp['src']['id']}').deleteSync(recursive: true);
        } catch (_) {}
      }
    }

    return isRecovery;
  }

  /// Eliminamos o enviamos a la carpeta del expediente lost todos los archivos
  /// que no esten entre los establecidos entre los que estan en DRASH.
  /// archsErr = Total de archivos encontrados en el folder Werr
  /// camp     = La campaña que se esta analizando
  ///  
  static Future<void> cleanFileErrsLost
    (List<FileSystemEntity> archsErr, Map<String, dynamic> camp) async
  {

    // Ver si son los mismos que dice el archivo main
    final filesSended = List<String>.from(camp['sended']);
    final filesDrash  = List<String>.from(camp['drash']);

    final rotar = archsErr.length;
    // Si no son la misma cantidad, necesitamos ver donde estan los demas
    if(rotar != filesDrash.length) {

      for (var e = 0; e < rotar; e++) {

        // tomamos el nombre del archivo, eliminado todo el path
        final fe = archsErr[e].path.split(getSep).last;
        final base = '${camp['expediente']}${camp['id']}$getSep${camp['freceivers']}$getSep';

        bool passLost = false;
        if(!filesDrash.contains(fe)) {
          // si estan en enviados, corroborar que esten en el Expediente
          if(filesSended.contains(fe)) {
            // Abrimos el archivo del receiver.
            final contentR = await getMsgToMap(archsErr[e].path);
            // Verificamos si esta en el expediente.
            final fileLost = File('$base${contentR['idReceiver']}.json');
            if(fileLost.existsSync()) {
              archsErr[e].deleteSync();
            }else{
              passLost = true;
            }
          }else{
            passLost = true;
          }
        }

        if(passLost) {
          final dirLost = Directory('$base${"lost"}');
          if(!dirLost.existsSync()) {
            dirLost.createSync(recursive: true);
          }
          archsErr[e].renameSync('${dirLost.path}$getSep$fe');
        }
      }
    }
  }

  /// Los archivos que estan en drash, los analizamos para ver si son
  /// recuperables o no.
  /// archsErr      = Total de archivos encontrados en el folder Werr
  /// pathReceivers = El path a donde se envian (await) si son recuperados
  ///  
  static Future<bool> recoveryCampsIfExist
    (List<FileSystemEntity> archsErr, String pathReceivers) async
  {

    bool checkExisteFolder = false;
    bool recovery = false;

    for (var e = 0; e < archsErr.length; e++) {

      // Abrimos el archivo del receiver.
      final contentR = await getMsgToMap(archsErr[e].path);
      // tomamos el nombre del archivo, eliminado todo el path
      final fe = archsErr[e].path.split(getSep).last;

      // abrir cada archivo de receiver y ver
      // la cantidad de intentos y el tipo de error
      if(contentR['intents'] < 3) {

        if(contentR['errores'].isNotEmpty) {
          if(contentR['errores'].first['tipo'] == 'retry') {

            // si el tipo de error es retry recuperamos la campaña.
            if(!checkExisteFolder) {
              checkExisteFolder = true;
              final hasDir = Directory(pathReceivers);
              if(!hasDir.existsSync()) {
                hasDir.createSync(recursive: true);
              }
            }

            contentR['errores'] = [];
            File(archsErr[e].path).writeAsStringSync(json.encode(contentR));
            archsErr[e].renameSync('$pathReceivers$fe');
            recovery = true;
          }

        }else{
          // Si estan en drash pero no cuentan con errores eliminar archivo
          archsErr[e].deleteSync();
        }
      }else{
        // mandamos un mensaje al avo.
      }
    }

    return recovery;
  }


  /// [r] Recuperamos la lista de archivos que se encuentran en
  /// el folder especificado por parametro
  static List<FileSystemEntity> getLstFilesByFolder(FoldStt folder) {

    final dir = GetPaths.getPathsFolderTo(getFolder(folder));
    if(dir != null) {
      if(dir.existsSync()) {
        final campas = dir.listSync();
        return (campas.isEmpty) ? [] : campas;
      }
    }
    return [];
  }

  /// [r] Recuperamos el contenido del archivo indicado en la carpeta indicada
  static Future<Map<String, dynamic>> getContentByFileAndFolder({
    required String fileName, required FoldStt folder}) async
  {

    final directory = GetPaths.getPathsFolderTo(getFolder(folder));
    final sep = GetPaths.getSep();
    return getMsgToMap('${directory!.path}$sep$fileName');
  }

  /// [r] Recuperamos el contenido del archivo indicado en la carpeta indicada
  static Future<Map<String, dynamic>> getContentByPath({
    required String fileName, required String folder,
  }) async => getMsgToMap('$folder$fileName');

  /// [r] Obtenemos la cantidad de archivos en el folder solicitado
  static Future<int> getCantContentFilesByFolder(FoldStt folder) async {

    final msgs = getLstFilesByFolder(folder);
    return msgs.length;
  }

  /// [r] Obtenemos el contenido del archivo indicado por parametro
  static Future<Map<String, dynamic>> getMsgToMap(String pathFile) async {

    if(pathFile.isEmpty){ return {}; }
    File content = File(pathFile);
    const decode = JsonDecoder();
    if(content.existsSync()) {
      return Map<String, dynamic>.from(
        decode.convert( content.readAsStringSync() )
      );
    }
    return {};
  }

  /// Obtenemos toda la lista de nombre de los archivos en TRAY
  /// ordenados por priodidad
  static List<String> getFilesTraySortPriority() {
    return sortByPrioridad();
  }

  /// [r] Retorna el path al archivo dentro de TRAY que cuenta
  /// con la mayor prioridad y lo marcamos como trabajando
  static Future<String> searchPriority(List<FileSystemEntity> campas) async {

    if(campas.isEmpty){ return ''; }
    // Si ya hay uno marcado como trabajando lo retornamos
    int hay = campas.indexWhere(
      (element) => element.path.contains(ScmPaths.prefixFldWrk)
    );
    if(hay != -1) { return campas[hay].path; }

    String pathSel = campas.first.path;
    hay = 0;
    if(campas.length > 1) {
      final prioridad = sortByPrioridad(campas: campas);
      if(prioridad.isNotEmpty) {
        hay = campas.indexWhere(
          (element) => element.path.endsWith(prioridad.first)
        );
        if(hay != -1) { pathSel = campas[hay].path; }
      }
    }

    if(pathSel.isNotEmpty) {
      pathSel = ScmPaths.setPrefixWorking( pathSel );
      campas[hay].renameSync(pathSel);
      return pathSel;
    }
    return '';
  }
  
  /// Ordenamos los archivos de la carpeta tray en prioridad.
  /// el que halla sido seleccionado se marca como trabajando
  static List<String> sortByPrioridad({List<FileSystemEntity> campas = const []}) {

    String findF = '';
    List<List<String>> files = [];

    if(campas.isEmpty) {
      campas = getLstFilesByFolder(FoldStt.tray);
    }

    // Recorremos la lista para recuperar los nombres de los archivos
    for (var i = 0; i < campas.length; i++) {
      findF = ScmPaths.extractNameFile(campas[i].path);
      files.add(findF.split(ScmPaths.sF));
    }

    List<String> prioridad = [];
    files.sort((a, b) => a[0].compareTo(b[0]));
    
    String itm = '';
    for (var i = 0; i < files.length; i++) {
      if(i == 0) {
        itm = files.first.first;
      }else{
        itm = files[i].first;
      }
      final varios = files.where((e) => e.first == itm).toList();

      if(varios.length > 1) {
        varios.sort((a,b) => a[1].compareTo(b[1]));
        varios.map((e) {
          String fr = e.join('-');
          if(!prioridad.contains(fr)) {
            prioridad.add(fr);
          }
        }).toList();
      }else{
        String fr = varios.first.join('-');
        if(!prioridad.contains(fr)) {
          prioridad.add(fr);
        }
      }
    }

    return prioridad;
  }

  /// [r] Tomanos el contenido del mensaje enviado por parametro
  static Future<List<String>> getMsgOfCampaing
    (String msgName, Map<String, dynamic> target) async
  {

    List<String> msg = [];
    final dirM = GetPaths.getPathsFolderTo('scm_msgs');
    if(dirM != null) {

      final lines = utf8.decoder.bind(
        File('${dirM.path}${GetPaths.getSep()}$msgName').openRead()
      ).transform(const LineSplitter());
      
      try {
        await for (String line in lines) {

          if(line.contains('_pzas_')) {
            if(target.containsKey('piezas')) {
              line = line.replaceAll('_pzas_', '${target['piezas'].length}');
            }
          }

          if(line.contains('_auto_')) {
            if(target.containsKey('marca')) {
              line = line.replaceAll('_auto_', '${target['marca']['nombre']}');
            }
          }
          msg.add(line);
        }
      } catch (_) {}
    }

    return msg;
  }

  ///
  static Future<Map<String, dynamic>> getCurcsTesting() async {

    final dirM = GetPaths.getPathRoot();
    return await getMsgToMap('$dirM${GetPaths.getSep()}${"testings_scm.json"}');
  }

  ///
  static Future<List<ProcesoEntity>> getAllMesajesDelFolder(String carpeta) async {

    List<ProcesoEntity> mensajes = [];
    Directory? folder = GetPaths.getPathsFolderTo(carpeta);
    final archivos = folder!.listSync();
    if(archivos.isNotEmpty) {

      archivos.map((archivo){

        //File contentF = File(archivo.path);
        // final ord = ProcesoEntity()..fromFileScm(
        //   json.decode(contentF.readAsStringSync()),
        //   archivo.path
        // );
        // mensajes.add(ord);

      }).toList();
    }

    return mensajes;
  }

  /// 
  static String getCodeSwh() {
    
    String pathTo = GetPaths.getPathRoot();
    final File codeF = File('$pathTo${GetPaths.getSep()}swh.txt');
    String codeSwh = '';
    if(!codeF.existsSync()) {
      codeF.writeAsStringSync('');
    }else{
      codeSwh = codeF.readAsStringSync();
    }
    if(codeSwh.isEmpty) { return 'noCode'; }
    return codeSwh;
  }

  /// Es usado solo en desarrollo para no estar pidiendo
  /// de manera remota la IP de harbi.
  static String ipConectionLocal() {

    final codeSwh = getCodeSwh();
    if(codeSwh.isEmpty) { return 'noCode'; }
    String pathTo = GetPaths.getPathRoot();
    final File cargosF = File('$pathTo${GetPaths.getSep()}harbi_connx.json');
    if(cargosF.existsSync()) {
      final res = Map<String, dynamic>.from(json.decode(cargosF.readAsStringSync()));
      if(res.isNotEmpty && res.containsKey(codeSwh)) {
        return res[codeSwh];
      }
    }
    return '';
  }

  /// 
  static void setSwh(String codeSwh) {

    String pathTo = GetPaths.getPathRoot();
    final File codeF = File('$pathTo${GetPaths.getSep()}swh.txt');
    if(codeF.existsSync()) {
      codeF.writeAsStringSync(codeSwh);
    }
  }


}
