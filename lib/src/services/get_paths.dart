import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart' show Size;

import '../config/sng_manager.dart';
import '../vars/globals.dart';

class GetPaths {

  static final Globals globals = getSngOf<Globals>();

  static const String package = 'autoparnet';
  static const String nameFilePaths = 'paths_dev.json';
  static const String nameFilePathsP = 'paths_prod.json';
  static p.Style estiloPlatform = p.Style.windows;

  ///
  static Future<int> getPort(String from) async {
    final puerto = await _getFromFilePathsProd(from);

    int? port = int.tryParse('${puerto['uri']}');
    if (port != null) {
      return port;
    }
    return 80;
  }

  /// Obtenemos el separador del sistema
  static String getSep() {
    var context = p.Context(style: estiloPlatform);
    return context.separator;
  }

  /// Recuperamos la data del archivo principal de paths
  static Future<Map<String, dynamic>?> getContentFilePaths({bool isProd = false}) async {
    
    List<String> sep = [getSep()];
    Map<String, dynamic>? pathsFinder;
    late File paths;
    if (!isProd) {
      String assets = '${p.context.current}${sep.first}assets${sep.first}';
      paths = File('$assets$nameFilePaths');
    } else {
      paths = File('${getPathRoot()}${sep.first}$nameFilePathsP');
    }
    if (paths.existsSync()) {
      pathsFinder =
          Map<String, dynamic>.from(json.decode(paths.readAsStringSync()));
    }
    return pathsFinder;
  }

  /// Obtenemos el path a root del proyecto
  static String getPathRoot() {
    var context = p.Context(style: estiloPlatform);
    return context.join(
        Directory.systemTemp.parent.parent.path, 'Roaming', 'com.$package');
  }

  /// Guardamos u obtenemos el tamaño de la pantalla del dispositivo
  static Future<Size> screen({String set = ''}) async {

    String root = getPathRoot();
    
    final file = File('$root${getSep()}screen.txt');
    if(file.existsSync()) {
      final setOld = file.readAsStringSync();
      if(setOld.isNotEmpty) {
        set = setOld;
      }else{
        if(set.isNotEmpty) {
          file.writeAsStringSync(set);
        }
      }
    }else{
      file.writeAsStringSync(set);
    }
    
    if(set.isNotEmpty) {
      final t = List<String>.from(set.split(' '));
      return Size(double.parse(t.first), double.parse(t.last));
    }
    return const Size(1280, 720);
  }

  ///
  static Future<void> deleteFilePathsProd() async {
    File paths = File('${getPathRoot()}${getSep()}$nameFilePathsP');
    if (paths.existsSync()) {
      paths.deleteSync();
    }
  }

  /// Revisamos la existencia del archivo paths para produccion
  static Future<bool> existFilePathsProd() async {
    File paths = File('${getPathRoot()}${getSep()}$nameFilePathsP');
    return paths.existsSync();
  }

  /// Recuperamos la URI segun key desde el archivo de produccion
  static Future<Map<String, dynamic>> _getFromFilePathsProd(String key) async {
    
    File paths = File('${getPathRoot()}${getSep()}$nameFilePathsP');
    if (paths.existsSync()) {
      Map mapa = json.decode(paths.readAsStringSync());
      if (mapa.containsKey(key)) {
        return {
          'port_harbi': mapa['portHarbi'],
          'port_server': mapa['portServer'],
          'ip_harbi': mapa['ip_harbi'],
          'base_r': mapa['server_remote'],
          'base_l': mapa['server_local'],
          'uri': mapa[key],
        };
      }
    }
    return {};
  }

  /// Guardamos la ip que apunta a la base de datos local
  static Future<Map<String, dynamic>> setBaseDbLocal(String ip) async {
    
    File paths = File('${getPathRoot()}${getSep()}$nameFilePathsP');
    if (paths.existsSync()) {
      Map mapa = json.decode(paths.readAsStringSync());
      if (mapa.containsKey('server_local')) {
        if (mapa['server_local'].toString().contains('_ip_')) {
          mapa['server_local'] =
              mapa['server_local'].toString().replaceAll('_ip_', ip);
          paths.writeAsStringSync(json.encode(mapa));
        }
      }
    }
    return {};
  }

  /// Recuperamos la URI segun key desde el archivo de produccion
  static Directory? getPathsFolderTo(String key) {
    Directory? pathFolder = Directory('${getPathRoot()}${getSep()}$key');
    return pathFolder;
  }

  ///
  static Future<String> getFileByPath(String path) async {
    final paths = await _getFromFilePathsProd(path);
    return paths['uri'];
  }

  ///
  static Future<String> getDominio({bool isLocal = true}) async {
    final paths = await _getFromFilePathsProd('portServer');
    return (isLocal) ? paths['base_l'] : paths['base_r'];
  }

  ///
  static Future<Map<String, dynamic>> getConnectionFtp(
    {bool isLocal = true}
  ) async {

    final pathDt = await _getFromFilePathsProd('ftp');
    String sufix = (isLocal) ? 'l' : 'r';
    return {
      'url': pathDt['base_$sufix'],
      'u': pathDt['uri']['u_${globals.env}'],
      'p': pathDt['uri']['p_${globals.env}'],
      'ssl': true
    };
  }

  ///
  static Future<Map<String, dynamic>> getBaseLocalAndRemoto() async {

    final paths = await _getFromFilePathsProd('portServer');

    return {
      'local': paths['base_l'],
      'remoto': paths['base_r'],
      'ipHarbi': globals.ipHarbi,
      'ptoHarbi': globals.portHarbi,
      'pto-loc': paths['uri'],
    };
  }

  ///
  static Future<String> getUri(String uri, {bool isLocal = true}) async {

    Map<String, dynamic> uriPath = await _getFromFilePathsProd(uri);

    String base = '${uriPath['base_l']}${uriPath['uri']}/';
    if (!isLocal) {
      base = '${uriPath['base_r']}${uriPath['uri']}/';
    }
    return base;
  }

  ///
  static Future<String> getApiHarbi(String uri, String ipHarbi) async {

    Map<String, dynamic> uriPath = await _getFromFilePathsProd(uri);
    return 'http://$ipHarbi${uriPath['uri']}/';
  }

  ///
  static Future<Uri> getUriApiHarbi(String uri, String query) async {

    Map<String, dynamic> uriPath = await _getFromFilePathsProd(uri);
    if(query.isNotEmpty) {
      query = '/$query';
    }

    return Uri.http('${uriPath['ip_harbi']}:${uriPath['port_harbi']}', '${uriPath['uri']}$query');
  }
}
