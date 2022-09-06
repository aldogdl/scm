import 'dart:convert';

import '../config/sng_manager.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import '../vars/globals.dart';

class MyHttp {

  static Globals globals = getSngOf<Globals>();
  static Map<String, dynamic> result = {'abort':false, 'msg': 'ok', 'body':{}};

  static clean() {
    result = {'abort':false, 'msg': 'ok', 'body':{}};
  }

  static Future<String> makeLogin(
    String dominio, Map<String, dynamic> credentials
  ) async {

    const base = 'secure-api-check';
    http.Response resp = await http.post(
      Uri.parse('$dominio$base'),
      body: json.encode(credentials),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      }
    );
    if(resp.statusCode == 200) {
      final r = Map<String, dynamic>.from(json.decode(resp.body));
      if(r.containsKey('token')){
        return r['token'];
      }
    }
    return '';
  }

  ///
  static Future<void> get(String uri) async {

    late http.Response response;
    Uri uriParse = Uri.parse(uri);
    try {
      response = await http.get(uriParse);
    } catch (e) {
      // 
      if(e.toString().contains('SocketException')) {
        result['abort'] = true;
        result['body'] = 'ERROR, El Host ${ uriParse.host } está sin conexión.';
      }
      return;
    }

    if(response.statusCode == 200) {
      clean();
      result = Map<String, dynamic>.from(json.decode(response.body));
    }else{
      _drawErrorInConsole(response);
    }
  }

  ///
  static Future<void> post(String uri, Map<String, dynamic> data) async {

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    var req = http.MultipartRequest('POST', Uri.parse(uri));

    req.headers.addAll(headers);
    req.fields['data'] = json.encode(data);
    late http.Response response;
    try {
      response = await http.Response.fromStream(await req.send());
    } catch (e) {
      result = {'abort':true, 'msg': e.toString(), 'body':'ERROR, Sin conexión al servidor, intentalo nuevamente.'};
      return;
    }

    if(response.statusCode == 200) {
      clean();
      result = Map<String, dynamic>.from(json.decode(response.body));
    }else{
      _drawErrorInConsole(response);
    }
  }

  ///
  static Future<void> getHarbi(Uri uri) async {

    late http.Response response;

    try {
      response = await http.get(uri);
    } catch (e) {
      result = {'abort':true, 'msg': e.toString(), 'body':'ERROR, Sin conexión al servidor, intentalo nuevamente.'};
      return;
    }

    if(response.statusCode == 200) {
      clean();
      result = Map<String, dynamic>.from(json.decode(response.body));
    }else{
      _drawErrorInConsole(response);
    }
  }

  ///
  static Future<void> postHarbi(String uri, Map<String, dynamic> data) async {

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    var req = http.MultipartRequest('POST', Uri.parse(uri));

    req.headers.addAll(headers);
    req.fields['data'] = '${utf8.encode(json.encode(data))}';
    late http.Response response;
    try {
      response = await http.Response.fromStream(await req.send());
    } catch (e) {
      result = {'abort':true, 'msg': e.toString(), 'body':'ERROR, Sin conexión al servidor, intentalo nuevamente.'};
      return;
    }

    if(response.statusCode == 200) {
      clean();
      result = Map<String, dynamic>.from(json.decode(response.body));
    }else{
      _drawErrorInConsole(response);
    }
  }

  ///
  static void _drawErrorInConsole(http.Response response) {

    debugPrint('[ERROR]::${response.statusCode}');
    debugPrint(response.body);
  }
}