import 'dart:io';
import 'dart:convert';

import 'package:scm/src/entity/proceso_entity.dart';

import '../services/get_paths.dart';


class BuildNotiff
{

  // Push recien llgedos con exito "scp_pushin"
  // Push ya procesados por el scp "scp_pushout"
  // Push recien llgedos con error de recuperacion "scp_pushlost"
  static Map<String, dynamic> foldersPush = {
    'in' : 'pushin', 'out': 'pushout', 'lost' : 'pushlost'
  };

  ///
  static void updateMetrix(ProcesoEntity enProceso) {

    final sep = GetPaths.getSep();
    final dir = GetPaths.getPathsFolderTo(foldersPush['in']);
    final data = {
      'id'      : enProceso.src['id'],
      'idCamp'  : enProceso.id,
      'idAvo'   : enProceso.remiter.id,
      'manifest': enProceso.manifest,
      'target'  : enProceso.target,
    };

    if(dir != null) {
      var schema = getSchemaMain(
        secc: 'metrix',
        priority: 'baja',
        titulo: 'Actualización de Métricas del Centinela',
        descrip: 'Se actualizaron las métricas para ${enProceso.target}: ${enProceso.src['id']}',
        data: data
      );
      String nameFile = '${enProceso.remiter.id}-${DateTime.now().millisecondsSinceEpoch}.json';
      File('${dir.path}$sep$nameFile').writeAsStringSync(json.encode(schema));

      // Construyendo notificacion para fire_push
      schema = getSchemaMain(
        secc: 'fire_push',
        priority: 'alta',
        titulo: 'Enviando Fire Push a cotizadores',
        descrip: 'Fin del proceso de Envio ${enProceso.target}: ${enProceso.src['id']}',
        data: data
      );
      nameFile = 'fire_push-${DateTime.now().millisecondsSinceEpoch}.json';
      File('${dir.path}$sep$nameFile').writeAsStringSync(json.encode(schema));
    }
  }

  ///
  static Map<String, dynamic> getSchemaMain({
    required String priority,
    required String secc,
    required String titulo,
    required String descrip,
    required Map<String, dynamic> data
  }) {

    return {
      'secc'    : secc,
      'priority': priority,
      'titulo'  : titulo,
      'descrip' : descrip,
      'sended'  : DateTime.now().toIso8601String(),
      'data'    : data,
    };
  }
}