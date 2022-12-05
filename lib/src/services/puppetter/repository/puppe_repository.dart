
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../vars_puppe.dart';

class PuppeRepository {

  /// Revisamos si hay una instancia del browser iniciada
  Future<String> getFrontTarget(String targetId) async {

    http.Response resp = await http.get(Uri.http('$ppBase:$ppPort', '$wsActive$targetId'));
    if(resp.statusCode == 200) {
      return resp.body;
    }
    return '';
  }

  /// Revisamos si hay una instancia del browser iniciada
  Future<Map<String, dynamic>> getVersionBrowser() async {

    http.Response resp = await http.get(Uri.http('$ppBase:$ppPort', wsVersion));
    if(resp.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(resp.body));
    }
    return {};
  }

  /// Una lista de todos los objetivos de websocket disponibles.
  Future<List<Map<String, dynamic>>> getListTargets() async {

    try {
      http.Response resp = await http.get(Uri.http('$ppBase:$ppPort', wsList));
      if(resp.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(resp.body));
      }
    } catch (_) {}
    
    return [];
  }

}