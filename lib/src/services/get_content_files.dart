import 'dart:io';
import 'dart:convert';

import '../entity/proceso_entity.dart';
import '../entity/scm_entity.dart';
import '../services/scm/scm_paths.dart';
import '../services/get_paths.dart';

class GetContentFile {

  /// [r] Recuperamos el nombre del folder desde el enum.
  static String getFolder(FoldStt fld) {
    if(fld.name == 'wait') {
      return 'scm_a${fld.name}';
    }
    return 'scm_${fld.name}';
  }

  /// [r] Le colocamos el prefijo _wk_ al archivo que se encuentre en el
  /// stage, para que el cron lo tome y lo empiece a procesar.
  /// [RETURN] bacio en caso de no existir ningun archivo en la carpeta
  static Future<String> putWorkingIfAbsent({
    required FoldStt folder
  }) async {

    final res = await getPathFileWorking(folder: folder);
    if(!res['has'] && res['uri'].isNotEmpty) {

      // Le ponemos el prefixo de trabajo, en caso de no estar ya enviado.
      final newPath = ScmPaths.setPrefixWorking(res['uri']);
      final file = File(res['uri']);
      if(file.existsSync()) {
        file.renameSync(newPath);
      }
      return newPath;
    }
    return res['uri'];
  }

  /// [r] Buscamos el archivo el cual estamos trabajando
  /// [RETURN] bacio en caso de no existir ningun o
  /// el ultimo encontrado sin procesar aun.
  static Future<Map<String, dynamic>> getPathFileWorking({required FoldStt folder}) async {

    String uri = '';
    bool isNew = true;
    final fld = GetPaths.getPathsFolderTo(getFolder(folder));
    if(fld != null) {

      if(fld.existsSync()) {
        final msgs = fld.listSync();
        
        if(msgs.isNotEmpty) {
          if(!msgs.first.path.contains(ScmPaths.prefixFldWrk)) {
            List<String> todos = [];
            for (var i = 0; i < msgs.length; i++) {
              if(msgs[i].path.endsWith('.json')) {
                uri = msgs[i].path;
                todos.add(uri);
                if(msgs[i].path.contains(ScmPaths.prefixFldWrk)) {
                  isNew = false;
                  break;
                }
              }
            }
            if(isNew) {
              uri = (todos.isEmpty) ? '' : todos.first;
              todos = [];
            }
          }else{
            uri = msgs.first.path;
          }
        }
      }
    }

    return {'has': !isNew, 'uri': uri};
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
    required String fileName, required FoldStt folder,
  }) async {

    final directory = GetPaths.getPathsFolderTo(getFolder(folder));
    final sep = GetPaths.getSep();
    return getMsgToMap('${directory!.path}$sep$fileName');
  }

  /// [r] Extraemos el siguiente remitente a cual se le enviar?? un mensaje desde
  /// el archivo principal de datos ubicado en el Stage y colocamos los extractos
  /// en la carpeta de AWAIT
  static Future<void> extraerReceptores(String pathWrk) async {

    Map<String, dynamic> content = await getMsgToMap(pathWrk);
    if(content.isEmpty) return;
    if(!content['src'].containsKey('receivers')) {
      content['src']['receivers'] = [];
    }

    if(content['src']['receivers'].isNotEmpty) {
      // Indica que solo a estos receptores debe ser enviada la campa??a
      
      content = await _extraerReceptoresAndPutAwait(content, pathWrk);
    }else{

      // Si no hay receivers indicados, entonces enviar a todos la campa??a.
      content = await _setReceptoresAndPutAwait(content, pathWrk);
      final file = File(pathWrk);
      file.writeAsStringSync( json.encode(content) );
      // Pasamos el archivo de datos principal de STAGE a la carpera de TRAY
      await moveFileWorkingAndRemovePrefix(from: FoldStt.stage, to: FoldStt.tray);
      return;
    }
    return;
  }

  /// [r] Buscamos y filtramos a todos los receptores que coinsidan con los
  /// criterios de esta campa??a y los colocamos en la carpeta de AWAIT
  static Future<Map<String, dynamic>> _setReceptoresAndPutAwait(
    Map<String, dynamic> data, String pathFile
  ) async {
    
    final receivers = await getContenetToList(await GetPaths.getFileByPath('cotizadores'));

    if(receivers.isNotEmpty) {
      final s = GetPaths.getSep();
      final pathToWait  = GetPaths.getPathsFolderTo(getFolder(FoldStt.wait));
      final pathToTray  = GetPaths.getPathsFolderTo(getFolder(FoldStt.tray));
      final nameF = ScmPaths.removePrefixWork(pathFile);
      Map<String, List<ScmEntity>>? recps = {
        'priory': [], 'alto': [], 'medium': [], 'normal': [],
      };

      for (var i = 0; i < receivers.length; i++) {

        final passFilter = await _pasaFilter(receivers[i], data);
        if(passFilter['pasa']) {
          ScmEntity scm = ScmEntity();
          scm.fromCampaing(data['id'], '${pathToTray!.path}$s$nameF', receivers[i]);
          recps[passFilter['priority']]!.add(scm);
        }
      }

      List<String> lstFiles = [];
      List<ScmEntity> receptores = [];
      recps.forEach((key, value) {
        receptores.addAll(value);
      });
      if(receptores.isNotEmpty) {
        for (var i = 0; i < receptores.length; i++) {
          // Crear el achivo para el remitente y ponerlo en await.
          final nameFile = ScmPaths.createNameFileReceptor(data['id']);
          final fileRemit = File('${pathToWait!.path}$s$nameFile');
          lstFiles.add(nameFile);
          fileRemit.writeAsStringSync( json.encode( receptores[i].toJson()) );
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
      
      data['toSend'] = List<String>.from(lstFiles);
      data['noSend'] = List<String>.from(lstFiles);
      lstFiles = [];
      receptores = [];
    }

    return data;
  }

  /// [r] Revisamos que el receptor pase los filtros
  static Future<Map<String, dynamic>> _pasaFilter(receiver, campaing) async {

    String priority = 'normal';
    // revisamos si la campa??a solicita filtrado
    if(!campaing['campaing']['isConFilt']) { return {'priority': priority, 'pasa':true}; }
    
    // vemos la localidad. all | loc | for
    final z = campaing['src']['filter']['zona'];
    if(z != 'all') {
      if(z == 'for' && receiver['e_isLocal']) {
        return {'priority': priority, 'pasa':false};
      }
    }

    bool pasa = true;
    if(receiver['f_plan'] != null) {
      String subPri = 'normal';
      if(receiver['f_plan'] != 'driver'){
        subPri = (receiver['f_plan'] == 'pilot') ? 'medium' : 'alto';
      }

      if(receiver['f_isFav'] != null) {
        if(receiver['f_isFav'] && priority == 'normal') {
          subPri = 'medium';
        }
        if(receiver['f_isFav'] && priority == 'medium') {
          subPri = 'alto';
        }
        if(receiver['f_isFav'] && priority == 'alto') {
          subPri = 'priory';
        }
      }
      priority = subPri;
    }

    // Revisamos restricciones mk | md | pz
    if(receiver['f_restris'] != null) {
      pasa = await _checkFilterOf(
        Map<String, dynamic>.from(receiver['f_restris']), campaing
      );
    }

    return {'priority': priority, 'pasa':pasa};
  }

  /// [r]
  static Future<bool> _checkFilterOf(Map<String, dynamic> filtro, Map<String, dynamic> camp) async {

    bool pasa = true;
    final mk = List<int>.from(filtro['mk']);
    final md = List<int>.from(filtro['md']);
    final pz = List<int>.from(filtro['pz']);
    if(camp.containsKey('orden')) {
      if(camp['orden'].containsKey('marca')) {
        if(mk.isNotEmpty) {
          // Cuentas con restricciones de marca, es decir solo maneja estas
          if(!mk.contains(camp['orden']['marca']['id'])){
            return false;
          }
        }
      }
      if(camp['orden'].containsKey('modelo')) {
        if(md.isNotEmpty) {
          // Cuentas con restricciones de modelos, es decir solo maneja estos
          if(!md.contains(camp['orden']['modelo']['id'])){
            return false;
          }
        }
      }
      if(camp['orden'].containsKey('pzaReg')) {
        if(pz.isNotEmpty) {
          // Cuentas con restricciones de piezas, es decir solo maneja estas
          if(!pz.contains(camp['orden']['modelo']['id'])){
            return false;
          }
        }
      }
    }
    return pasa;
  }

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

  /// [r] Obtenemos el contenido del archivo indicado por parametro
  static Future<List<Map<String, dynamic>>> getContenetToList(String pathFile) async {

    if(pathFile.isEmpty){ return []; }

    File content = File(pathFile);
    const decode = JsonDecoder();
    if(content.existsSync()) {
      return List<Map<String, dynamic>>.from(
        decode.convert( content.readAsStringSync() )
      );
    }
    return [];
  }

  /// [r] Retorna el nombre del archivo dentro de TRAY que cuenta
  /// con la mayor prioridad.
  static Future<String> searchPriority(List<FileSystemEntity> campas) async {

    String current = '';
    String findF = '';
    List<List<String>> archivos = [];
    List<List<String>> priory = [];
    
    // Recorremos la lista para recuperar los nombres de los archivos
    for (var i = 0; i < campas.length; i++) {
      findF = ScmPaths.extractNameFile(campas[i].path);
      if(findF.startsWith(ScmPaths.prefixFldWrk)) {
        findF = findF.replaceFirst(ScmPaths.prefixFldWrk, '').trim();
        current = findF;
      }
      archivos.add(findF.split(ScmPaths.sF));
    }
    
    if(archivos.isEmpty) {
      if(current.isNotEmpty) {
        return current;
      }
      return '';
    }

    priory = List<List<String>>.from(archivos);

    // Reducimos la lista a una mayor prioridad haceindo dicho analisis
    // dos veces, ya que los dos primeros numeros son los que se analizan
    for (var i = 1; i > -1; i--) {

      bool isLast = (i <= 0) ? true : false;
      priory = _findMayorPrioridad(
        toReduce: priory, index: i, isLast: isLast
      );
      if(priory.isEmpty && !isLast) {
        priory = List<List<String>>.from(archivos);
      }
    }

    if(priory.isEmpty) {
      if(current.isNotEmpty) {
        return current;
      }
      return '';
    }else{
      findF = priory.first.join(ScmPaths.sF);
      priory = [];
    }

    // Ultima prueba de prioridad contra el current.
    if(current.isNotEmpty){
      if(current != findF) {
        List<String> finalComp = [current, findF];
        finalComp.sort();
        findF = finalComp.first;
      }
    }

    return findF;
  }
  
  /// [r] Analizamos la lista de archivos que se encuentran en TRAY
  /// con la finalidad de reducirla a una mayor prioridad
  static List<List<String>> _findMayorPrioridad({
    required List<List<String>> toReduce,
    required int index, required bool isLast,
  }) {

    List<String> elFirst = toReduce.first;
    List<List<String>> result = [];
    int valueInit = -1;
    for (var i = 0; i < toReduce.length; i++) {

      if(!toReduce[i].contains('_')) {
        if(i == 0) {
          valueInit = int.tryParse(toReduce[i][index]) ?? 0;
        }
        int vnew = int.tryParse(toReduce[i][index]) ?? 0;

        if(vnew < valueInit) {
          result.add(toReduce[i]);
          valueInit = vnew;
        }
      }
    }
    
    if(isLast) {
      result = (result.isEmpty) ? [elFirst] : result;
    }
    return result;
  }

  /// [r] Revisamos que el archivo encontrado con mayor prioridad
  /// sea el mismo que el que esta actualmente en proceso
  static Future<bool> isSameCampaing(
    String currentFileProcess, String fileCamp
  ) async {

    if(!fileCamp.contains(ScmPaths.prefixFldWrk)) {
      fileCamp = ScmPaths.setPrefixWorking(fileCamp, isPath: false);
    }
    if(currentFileProcess.isNotEmpty) {
      final current = ScmPaths.extractNameFile(currentFileProcess);
      return (fileCamp == current) ? true : false;
    }
    return false;
  }

  /// [r] Cambiamos el archivo de tray que actualmente se este
  /// trabajando por el indicado por parametro
  static Future<File?> cambiamosFileDeTrabajo(
    String currentFileProcess, String fileCamp,
  ) async {

    File? fileW;
    const pfx = ScmPaths.prefixFldWrk;
    bool findWk = false;
    // Renombramos el archivo actual que se esta trabajando.
    // quitandoles el prefijo de _wk_
    if(currentFileProcess.isNotEmpty) {
      fileW = File(currentFileProcess);
      if(fileW.existsSync()) {
        final newPath = currentFileProcess.replaceFirst(pfx, '');
        fileW.renameSync(newPath);
        findWk = true;
      }
    }

    // Si no encontramos el archivo de trabajo actual lo buscamos uno a uno
    if(!findWk) {
      final dirTray = GetPaths.getPathsFolderTo(GetContentFile.getFolder(FoldStt.tray));
      if(dirTray != null) {
        if(dirTray.existsSync()) {
          final hasF = dirTray.listSync().toList();
          for (var i = 0; i < hasF.length; i++) {
            if(hasF[i].path.contains(pfx)){
              final newPath = hasF[i].path.replaceFirst(pfx, '');
              hasF[i].renameSync(newPath);
              break;
            }
          }
        }
      }
    }

    // El archivo ques se envia como nueva campa??a le ponemos el
    // prefijo de trabajo _wk_
    fileW = null;
    if(fileCamp.isNotEmpty) {
      final base = GetPaths.getPathsFolderTo(
        GetContentFile.getFolder(FoldStt.tray)
      );
      if(base != null) {
        final s = ScmPaths.getSep();
        fileW = File('${base.path}$s$fileCamp');
        if(fileW.existsSync()) {
          fileCamp = ScmPaths.setPrefixWorking(fileCamp, isPath: false);
          fileW = fileW.renameSync('${base.path}$s$fileCamp');
        }
      }
    }

    return fileW;
  }

  /// Buscamos el archivo el cual estamos trabajando en la carpeta indicada
  /// [RETURN] un Mapa en caso de existir.
  static Future<Map<String, dynamic>> getContentFileWorking({required FoldStt folder}) async {

    final pathWork = await getPathFileWorking(folder: folder);
    if(pathWork['uri'].isNotEmpty) {
      return await getMsgToMap(pathWork['uri']);
    }
    return {};
  }

  ///
  static Future<Map<String, dynamic>> _extraerReceptoresAndPutAwait(
    Map<String, dynamic> data, String pathFile
  ) async {

    // final receivers = List<int>.from(data['receivers']);
    // final nextReceivers = List<int>.from(data['receivers']);
    // TODO
    return {};
  }

  /// [r] Le quitamos la se??a de archivo trabajando y lo movemos al folder indicado
  static Future<void> moveFileWorkingAndRemovePrefix({
    required FoldStt from, required FoldStt to,
  }) async {

    final pathFrom = await getPathFileWorking(folder: from);

    final file = File(pathFrom['uri']);
    if(file.existsSync()) {

      String fileTo = ScmPaths.removePrefixWork(pathFrom['uri']);
      final pathTo = GetPaths.getPathsFolderTo(getFolder(to));
      if(pathTo != null && pathTo.existsSync()) {
        
        file.renameSync('${pathTo.path}${ScmPaths.getSep()}$fileTo');
        if(file.existsSync()) {
          file.deleteSync();
        }
      }
    }
  }

  /// [r] Usado para extrar los datos minimos del archivo de campa??as para
  /// mostrarlas en la parte inferior de la page de home
  static Future<List<Map<String, dynamic>>> getAllCampaingsWithDataMini() async {

    List<Map<String, dynamic>> lstCamps = [];
    
    final lstF = getLstFilesByFolder(FoldStt.tray);
    if(lstF.isNotEmpty) {

      Map<String, dynamic> current = {};

      for (var i = 0; i < lstF.length; i++) {
        List<String> partes = lstF[i].path.split(GetPaths.getSep());
        final proc = ProcesoEntity();
        proc.fromJson(
          await getContentByFileAndFolder(
            fileName: partes.last, folder: FoldStt.tray
          )
        );
        if(partes.last.contains(ScmPaths.prefixFldWrk)) {
          current = proc.toJsonMini();
        }else{
          lstCamps.add(proc.toJsonMini());
        }
      }

      lstCamps = List<Map<String, dynamic>>.from(lstCamps.reversed.toList());
      if(current.isNotEmpty) {
        lstCamps.insert(0, current);
      }
      current = {};
    }
    return lstCamps;
  }

  /// [r] Usado para extrar los datos minimos del archivo ubicado en
  /// AWAIT los cuales son los receivers a los que se le enviaran la campa??a
  /// que se esta procesando.
  /// 
  /// El parametro fileNameCurrent es usado para evitar devolver el msg
  /// que se esta procesando actualmente
  static Future<List<ScmEntity>> getAllReceiverOfCampaings({
    required List<String> filesRecivers, required String fileNameCurrent
  }) async {

    List<ScmEntity> lstRecivers = [];
    
    if(filesRecivers.isNotEmpty) {
      for (var i = 0; i < filesRecivers.length; i++) {
        if(filesRecivers[i] != fileNameCurrent) {
          final lstF = await getContentByFileAndFolder(
            fileName: filesRecivers[i], folder: FoldStt.wait
          );
          if(lstF.isNotEmpty) {
            lstRecivers.add(
              ScmEntity()..fromProvider(lstF)
            );
          }
        }
      }
    }
    return lstRecivers;
  }

  /// [r] Tomanos el contenido del mensaje enviado por parametro
  static Future<List<String>> getMsgOfCampaing(String msgFile) async {

    List<String> msg = [];
    final dirM = GetPaths.getPathsFolderTo('scm_msgs');
    if(dirM != null) {

      final lines = utf8.decoder.bind(
        File('${dirM.path}${GetPaths.getSep()}$msgFile').openRead()
      ).transform(const LineSplitter());

      try {
        await for (final line in lines) {
          msg.add(line);
        }
      } catch (_) {}
    }

    return msg;
  }

  /// [r] Usado para cambiar un archivo de carpeta
  static Future<bool> changeDeFolder({
    required String filename,
    required FoldStt from, required FoldStt to
  }) async {

    final fromFld = GetPaths.getPathsFolderTo(getFolder(from));
    final toFld = GetPaths.getPathsFolderTo(getFolder(to));
    if(fromFld != null && toFld != null) {
      if(fromFld.existsSync()) {
        File fromFile = File(
          '${fromFld.path}${GetPaths.getSep()}$filename'
        );
        if(toFld.existsSync()) {
          try {
            fromFile.renameSync('${toFld.path}${GetPaths.getSep()}$filename');
          } catch (_) {
            return false;
          } 
          return true;
        }
      }
    }
    return false;
  }

  /// [r] Guardamos la data del archivo y el folder indicado
  static Future<bool> saveData(
    String filename, FoldStt fld, Map<String, dynamic> data
  ) async {

    final path = GetPaths.getPathsFolderTo(getFolder(fld));
    if(path != null) {
      if(path.existsSync()) {
        final file = File('${path.path}${GetPaths.getSep()}$filename');
        if(file.existsSync()) {
          file.writeAsStringSync( json.encode(data));
          return true;
        }
      }
    }
    return false;
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

}