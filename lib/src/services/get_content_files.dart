import 'dart:convert';
import 'dart:io';

import '../config/sng_manager.dart';
import '../entity/contacts_entity.dart';
import '../entity/scm_file.dart';
import '../entity/proceso_entity.dart';
import '../entity/scm_entity.dart';
import '../services/get_paths.dart';
import '../vars/globals.dart';
import 'my_http.dart';

class GetContentFile {

  static final Globals _globals = getSngOf<Globals>();

  ///
  static Future<List<String>> cargos() async {

    String pathTo = await GetPaths.getFileByPath('cargos');
    final File cargosF = File(pathTo);
    if(cargosF.existsSync()) {
      return List<String>.from( json.decode(cargosF.readAsStringSync()) );
    }
    return [];
  }

  ///
  static Future<List<Map<String, dynamic>>> roles() async {

    String pathTo = await GetPaths.getFileByPath('roles');
    final File cargosF = File(pathTo);
    if(cargosF.existsSync()) {
      return List<Map<String, dynamic>>.from( json.decode(cargosF.readAsStringSync()) );
    }
    return [];
  }

  ///
  static Future<List<Map<String, dynamic>>> regOfLogin() async {

    List<Map<String, dynamic>> registros = [];

    final pathTo = await GetPaths.getFileByPath('connpass');
    final pathLog = await GetPaths.getFileByPath('connwho');
    final regs = File(pathTo);
    final logs = File(pathLog);
    if(regs.existsSync()) {

      final mRegs = Map<String, dynamic>.from( json.decode(regs.readAsStringSync()) );
      late final List<Map<String, dynamic>> llogs;
      if(regs.existsSync()) {
        llogs = List<Map<String, dynamic>>.from( json.decode(logs.readAsStringSync()) );
      }else{
        llogs = [];
      }

      mRegs.forEach((key, value) {
        var reg = Map<String, dynamic>.from(value);
        if(llogs.isNotEmpty) {
          reg['logs'] = llogs.where((element) => element['curc'] == reg['curc']).toList();
        }
        registros.add(reg);
      });
    }
    return registros;
  }

  ///
  static Future<bool> deleteRegOfLogin(String curc) async {

    final pathTo = await GetPaths.getFileByPath('connpass');
    final regs = File(pathTo);
    if(regs.existsSync()) {

      Map<String, dynamic> newsRegs = {};
      final mRegs = Map<String, dynamic>.from( json.decode(regs.readAsStringSync()) );
      if(mRegs.isNotEmpty){
        mRegs.forEach((key, value) {
          if(value['curc'] != curc) {
            newsRegs.putIfAbsent(key, () => value);
          }
        });
      }
      if(newsRegs.isNotEmpty) {
        regs.writeAsStringSync( json.encode(newsRegs) );
      }
      return true;
    }
    
    return false;
  }

  /// Cambiar la ip en el archivo local paths
  static Future<void> cambiarIpEnArchivoPath(String nuevaIp) async {

    nuevaIp = nuevaIp.trim();
    final pathRoot = GetPaths.getPathRoot();
    final regs = File('$pathRoot${GetPaths.getSep()}${GetPaths.nameFilePathsP}');
    if(regs.existsSync()) {

      Map<String, dynamic> mRegs = Map<String, dynamic>.from( json.decode(regs.readAsStringSync()) );

      late Uri ipF;
      late Uri ipG;
      String baseT  = (_globals.isLocalConn) ? 'base_l' : 'base_r';
      String baseTF = (_globals.isLocalConn) ? 'server_local' : 'server_remote';
      String ipCF   = mRegs[baseTF];

      ipF = Uri.parse(ipCF);
      ipG = Uri.parse(_globals.ipDbs[baseT]);

      if(ipF.host.trim() != nuevaIp) {
        ipF = ipF.replace(host: nuevaIp, port: _globals.ipDbs['port_s']);
        mRegs[baseTF] = ipF.toString();
        regs.writeAsStringSync(json.encode(mRegs));
      }
      
      if(ipG.host.trim() != nuevaIp) {
        ipG = ipG.replace(host: nuevaIp, port: _globals.ipDbs['port_s']);
        _globals.ipDbs[baseT] = ipG.toString();
      }
    }

  }

  /// Recuperamos los autos marcas y modelos
  static Future<List<Map<String, dynamic>>> getAllAuto() async {

    final String pathRoot = await GetPaths.getFileByPath('autos');
    final regs = File(pathRoot);
    if(regs.existsSync()) {
      return List<Map<String, dynamic>>.from( json.decode(regs.readAsStringSync()) );
    }
    return [];
  }

  /// Recuperamos el nombre del folder desde el enum.
  static String getFolder(FoldStt fld) {
    if(fld.name == 'wait') {
      return 'scm_a${fld.name}';
    }
    return 'scm_${fld.name}';
  }

  ///
  static Future<ScmFile?> getScmFileWorking({
    FoldStt folder = FoldStt.tray
  }) async {

    ScmFile fileS = ScmFile();
    final c = await GetContentFile.getContentFileWorking(folder: folder);
    if(c.isNotEmpty) {
      fileS.fromFileCampaing(c);
      fileS.createNameFile();
      return fileS;
    }
    return null;
  }

  /// Construimos un archivo independiente por cada campaña que se encuentre
  static Future<void> putNewFileInStage(List<Map<String, dynamic>> campas, String tipo) async {

    final path = GetPaths.getPathsFolderTo(getFolder(FoldStt.stage));

    for (var i = 0; i < campas.length; i++) {

      ScmFile fileS = ScmFile();
      fileS.fromFileCampaing(campas[i]);
      fileS.createNameFile();

      campas[i]['toSend'] = List<int>.from(campas[i]['receivers']);
      campas[i]['noSend'] = List<int>.from(campas[i]['receivers']);
      campas[i]['sended'] = [];

      File newFile = File('${path!.path}${fileS.sep}${fileS.nameFile}');
      newFile.writeAsStringSync(
        json.encode( Map<String, dynamic>.from(campas[i]) )
      );
    }
  }

  /// Buscamos el archivo el cual estamos trabajando
  /// [RETURN] bacio en caso de no existir ningun archivo en la carpeta
  static Future<String> putWorkingIfAbsent({
    required FoldStt folder
  }) async {

    ScmFile? fileS = ScmFile();
    final res = await getPathFileWorking(folder: folder);
    
    if(!res['has'] && res['uri'].isNotEmpty) {
      if(!res['uri'].toString().contains(fileS.prefixFldSended)) {
        fileS = ScmFile(pathOrigin: res['uri']);
        return await fileS.prefixWorking(accion: 'put');
      }
    }
    if(!res['uri'].toString().contains(fileS.prefixFldSended)) {
      return res['uri'];
    }
    return '';
  }

  /// Buscamos el archivo el cual estamos trabajando
  /// [RETURN] bacio en caso de no existir ningun archivo en la carpeta
  static Future<Map<String, dynamic>> getPathFileWorking({
    required FoldStt folder
  }) async {

    String uri = '';
    bool isNew = true;
    final fld = GetPaths.getPathsFolderTo(getFolder(folder));
    if(fld != null) {

      if(fld.existsSync()) {
        final msgs = fld.listSync();
        
        if(msgs.isNotEmpty) {

          ScmFile fileS = ScmFile();
          if(!msgs.first.path.contains(fileS.prefixFldWrk)) {

            for (var i = 0; i < msgs.length; i++) {
              if(!msgs[i].path.contains(fileS.prefixFldSended)) {
                uri = msgs[i].path;
                if(msgs[i].path.endsWith('.json') && msgs[i].path.contains(fileS.prefixFldWrk)) {
                  isNew = false;
                  break;
                }
              }
            }
          }else{
            uri = msgs.first.path;
          }
        }
      }
    }

    return {'has': !isNew, 'uri': uri};
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

  /// Recuperamos el contenido del archivo indicado en la carpeta indicada
  static Future<Map<String, dynamic>> getContentByFileAndFolder({
    required String fileName, required FoldStt folder,
  }) async {

    final directory = GetPaths.getPathsFolderTo(getFolder(folder));
    final sep = GetPaths.getSep();
    return getMsgToMap('${directory!.path}$sep$fileName');
  }

  /// Le quitamos la seña de archivo trabajando y lo movemos al folder TRAY
  /// y colocamos todos los paths necesarios al procesoEntity y al scmEntity
  static Future<void> moveFileWorking({
    required FoldStt from, required FoldStt to
  }) async {

    final pathStage = await getPathFileWorking(folder: from);
    ScmFile fileS = ScmFile(pathOrigin: pathStage['uri']);
    String pathTo = fileS.convertPathTo(to, pathStage['uri'], withoutWorking: true);

    File fileContent = File(pathStage['uri']);
    Map<String, dynamic> content = await getMsgToMap(pathStage['uri']);
    fileContent.deleteSync();
    fileContent = File(pathTo);
    fileContent.writeAsStringSync( json.encode(content) );
  }

  /// Extraemos el siguiente remitente a cual se le enviará un mensaje desde
  /// el archivo principal de datos ubicado en el Stage y colocamos los extractos
  /// en la carpeta de CACHE
  static Future<void> extraerReceptores(String pathWrk) async {

    Map<String, dynamic> content = await getMsgToMap(pathWrk);
    if(content.isEmpty) return;

    if(content['receivers'].isNotEmpty) {
      content = await _extraerReceptoresAndPutAwait(content, pathWrk);
      final file = File(pathWrk);
      file.writeAsStringSync( json.encode(content) );
      // Pasamos el archivo de datos principal de STAGE a la carpera de TRAY
      await moveFileWorking(from: FoldStt.stage, to: FoldStt.tray);
      return;
    }
    return;
  }

  ///
  static Future<Map<String, dynamic>> _extraerReceptoresAndPutAwait(
    Map<String, dynamic> data, String pathFile
  ) async {
    
    final receivers = List<int>.from(data['receivers']);
    final nextReceivers = List<int>.from(data['receivers']);
    if(receivers.isNotEmpty) {

      final pathToWait  = GetPaths.getPathsFolderTo(getFolder(FoldStt.wait));
      final fileS = ScmFile();
      fileS.pathSinFile = pathToWait!.path;
      fileS.fromFileCampaing(data);
      List<int> integridad = [];
      String sufixTimeChilds = '';
      for (var i = 0; i < receivers.length; i++) {

        fileS.createNameFile(receptor: '${receivers[i]}');
        integridad.add(receivers[i]);
        ScmEntity scm = ScmEntity();
        if(i == 0) {
          fileS.nameFile = fileS.nameFile.replaceFirst(
            fileS.suf, fileS.sufM
          );
          final partes = fileS.nameFile.split(fileS.sF); 
          sufixTimeChilds = partes.last;
        }
        scm.init(
          fileS.toScmEntity(pathFile, List<int>.from(receivers)),
          idCampaing: data['id']
        );
        if(nextReceivers.isNotEmpty) {
          nextReceivers.remove(scm.idReceiver);
        }
        scm.nextReceivers = nextReceivers;

        // Crear el achivo para el remitente y ponerlo en await.
        final fileRemit = File('${fileS.pathSinFile}${fileS.sep}${fileS.nameFile}');
        fileRemit.writeAsStringSync( json.encode( scm.toJson()) );
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      final compare = List<int>.from(data['receivers']);
      for (var i = 0; i < compare.length; i++) {
        if(integridad.contains(compare[i])) {
          integridad.remove(compare[i]);
        }
      }
      data['receivers'] = integridad;
      data['sufixTimeChilds'] = sufixTimeChilds;
    }

    return data;
  }

  /// Obtenemos la cantidad de archivos en el folder solicitado
  static Future<int> getCantContentFilesByFolder(FoldStt folder) async {

    final fld = GetPaths.getPathsFolderTo(getFolder(folder));
    if(fld != null) {
      if(fld.existsSync()) {
        final msgs = fld.listSync();
        return msgs.length;
      }
    }
    return 0;
  }

  ///
  static Future<List<Map<String, dynamic>>> getAllCampaingsWithDataMini() async {

    final fileS = ScmFile();
    List<Map<String, dynamic>> lstCamps = [];
    final dir = GetPaths.getPathsFolderTo(getFolder(FoldStt.tray));
    if(dir != null) {
      if(dir.existsSync()) {

        final lstF = dir.listSync();
        if(lstF.isNotEmpty) {
          Map<String, dynamic> current = {};

          for (var i = 0; i < lstF.length; i++) {
            List<String> partes = lstF[i].path.split(GetPaths.getSep());
            if(!partes.last.contains(fileS.prefixFldSended)) {

              final proc = ProcesoEntity();
              proc.fromJson(
                await getContentByFileAndFolder(
                  fileName: partes.last,
                  folder: FoldStt.tray
                )
              );
              if(partes.last.contains(fileS.prefixFldWrk)) {
                current = proc.toJsonMini();
              }else{
                lstCamps.add(proc.toJsonMini());
              }
            }
          }

          lstCamps = List<Map<String, dynamic>>.from(lstCamps.reversed.toList());
          if(current.isNotEmpty) {
            lstCamps.insert(0, current);
          }
          current = {};
        }
      }
    }
    return lstCamps;
  }

  /// Recuperamos la entidad en proceso desde el archivo que se esta trabajando
  static Future<ProcesoEntity> getFileWorkingEnProceso(String pathFile) async {

    final content = await getMsgToMap(pathFile);
    return ProcesoEntity()..fromJson(content);
  }

  ///
  static Future<String> getPathOfContacto(int idContac) async {

    Directory? foldCtcs = GetPaths.getPathsFolderTo('data_ctcs');
    
    File ctac = File('${foldCtcs!.path}${GetPaths.getSep()}$idContac.json');
    if(!ctac.existsSync()) {
      // Descargarlo desde servidor remoto.
      await _downloadDataContact(idContac, false);
    }

    return '${foldCtcs.path}${GetPaths.getSep()}$idContac.json';
  }

  ///
  static Future<ContactEntity> getFileOfContacto(int idContac) async {

    ContactEntity ctcEntity = ContactEntity();
    Directory? foldCtcs = GetPaths.getPathsFolderTo('data_ctcs');
    
    File ctac = File('${foldCtcs!.path}${GetPaths.getSep()}$idContac.json');
    if(!ctac.existsSync()) {

      // Descargarlo desde servidor remoto.
      return await _downloadDataContact(idContac, true) ?? ctcEntity;

    }else{
      ctcEntity.fromJson(
        Map<String, dynamic>.from(json.decode(ctac.readAsStringSync()))
      );
    }

    return ctcEntity;
  }

  ///
  static Future<ContactEntity?> _downloadDataContact(int idCtc, bool getMap) async {

    Map<String, dynamic> content = {};
    ContactEntity ctcEntity = ContactEntity();
    Directory? foldCtcs = GetPaths.getPathsFolderTo('data_ctcs');

    String path = await GetPaths.getUri('get_contacto_byid');
    await MyHttp.get('$path$idCtc/');
    
    if(!MyHttp.result['abort']) {
      content = Map<String, dynamic>.from( MyHttp.result['body'] );
      ctcEntity.fromServer(content);
      File ctac = File('${foldCtcs!.path}${GetPaths.getSep()}$idCtc.json');
      ctac.writeAsStringSync(json.encode(ctcEntity.toJson()));
    }
    return (getMap) ? ctcEntity : null;
  }

  /// Obtenemos el contenido del archivo indicado por parametro
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

  /// Guardamos el log en el archivo del mensaje en proceso
  static Future<void> setMsgInFile(
    String pathFile, Map<String, dynamic> data
  ) async {

    File content = File(pathFile);
    const encode = JsonEncoder();
    content.writeAsStringSync( encode.convert(data) );
  }

  /// Guardamos la data del archivo y el folder indicado
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

  /// Guardamos el log en el archivo del mensaje en proceso
  static Future<void> changeSttOrdenToPapelera(
    Map<String, dynamic> elMsgCurrent
  ) async {

    // y cambiar de version
    // List sabe = [];
    // sabe.firstWhere((element) => element['id'])
    // elMsgCurrent['task']
  }

  ///
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

  ///
  static Future<bool> changeMsgFromChildToMain({
    required String filename
  }) async {

    final waitFld = GetPaths.getPathsFolderTo(getFolder(FoldStt.wait));
    if(waitFld != null) {
      if(waitFld.existsSync()) {
        File fromFile = File(
          '${waitFld.path}${GetPaths.getSep()}$filename'
        );
        final fileS = ScmFile();
        // cambiamos el main por el child
        filename = filename.replaceFirst(fileS.suf, fileS.sufM);
        fromFile.renameSync('${waitFld.path}${GetPaths.getSep()}$filename');
        return true;
      }
    }
    return false;
  }

  /// Actualizamos el archivo principal de la campaña
  static Future<void> updateSendersInFileData(Map<String, dynamic> data, String pathFile) async {

    final file = File(pathFile);
    if(file.existsSync()) {
      var content = Map<String, dynamic>.from(json.decode( file.readAsStringSync() ));
      content['toSend'] = data['toSend'];
      content['sended'] = data['sended'];
      content['noSend'] = data['noSend'];
      file.writeAsStringSync( json.encode(content) );
    }
  }

  /// Ponemos el archivo de la data principal del mensaje como enviado
  static Future<void> putFileDataWorkingAsSended(ScmEntity scm) async {

    final fileS = ScmFile(pathOrigin: scm.data);
    final file  = File(fileS.pathOrigin);
    try {
      file.renameSync('${fileS.pathSinFile}${fileS.sep}${fileS.prefixFldSended}${fileS.nameFile}');
    } catch (_) {}

  }
}