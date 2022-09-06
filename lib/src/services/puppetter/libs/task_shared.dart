import 'package:flutter/services.dart';
import 'package:puppeteer/puppeteer.dart' as pupp show
ElementHandle, Key, Page;

import '../vars_puppe.dart' show ErrorType,
intentos, CmdType;
import '../../get_content_files.dart';
import '../../../providers/process_provider.dart';
import '../../../providers/terminal_provider.dart';

///
Future<bool> hasContenido({
    required pupp.ElementHandle element
}) async
{
  var contenido = await element.evaluate<String>('node => node.innerText');
  if(contenido != null) {
    contenido = contenido.trim();
    if(contenido.isNotEmpty) {
      return true;
    }
  }
  return false;
}

///
Future<String> getContenido({
  required pupp.ElementHandle element
}) async
{
  var contenido = await element.evaluate<String>('node => node.innerText');
  if(contenido != null) {
    if(contenido.isNotEmpty) {
      return contenido;
    }
  }
  return '';
}

///
Future<void> borrarContenidoContac({
  required pupp.ElementHandle element,
  required pupp.Page page
}) async
{
  var contenido = await element.evaluate<String>('node => node.innerText');
  if(contenido != null) {
    if(contenido.isNotEmpty) {
      await page.keyboard.press(pupp.Key.end);
      await page.keyboard.down(pupp.Key.shift);
      await page.keyboard.press(pupp.Key.home);
      await page.keyboard.up(pupp.Key.shift);
      await page.keyboard.press(pupp.Key.delete);
    }
  }
}

///
Future<void> borrarMensaje({
  required pupp.ElementHandle element,
  required pupp.Page page
}) async
{

  var contenido = await element.evaluate<String>('node => node.innerText');
  if(contenido != null) {
    if(contenido.isNotEmpty) {
      await page.keyboard.down(pupp.Key.control);
      await page.keyboard.press(pupp.Key.keyA);
      await page.keyboard.up(pupp.Key.control);
      await page.keyboard.up(pupp.Key.keyA);
      await page.keyboard.press(pupp.Key.delete);
    }
  }
}

///
Future<void> pegarDash ({
  required pupp.ElementHandle element,
  required pupp.Page page
}) async
{
  await page.keyboard.down(pupp.Key.control);
  await page.keyboard.press(pupp.Key.keyV);
  await page.keyboard.up(pupp.Key.control);
  await Clipboard.setData(const ClipboardData(text: ''));
}

///
Future<void> _sleep({int time = 250}) async => await Future.delayed(Duration(milliseconds: time));

///
Future<void> tituloSecc(TerminalProvider console, String titulo) async {
  console.addDiv(s: '-');
  await _sleep();
  console.addWar(titulo);
}

/// Analizamos el tipo de erro ocurrido en cada seccion y paso
/// del envio del mensaje.
Future<String> anaErr
  (ProcessProvider pprov, TerminalProvider console,
  String error, String seccion, String step) async
{

  final tipoErr = getTipoDeError(error);
  if(tipoErr.isEmpty) {
    console.addWar('Error Indeterminado');
    console.addErr(tipoErr['err']);
    return 'Indeterminado';
  }

  console.addErr(tipoErr['err']);
  console.addTask('Sección:: $seccion > $step');
  await _sleep(time: 350);

  if(pprov.isProcessOnErr){
    console.addOk('REG. Tipo ${tipoErr['type']}');
    console.addDiv();
    return tipoErr['err'];
  }

  String typeE = '';
  bool goPapelera = false;
  pprov.receiverCurrent.cmds.clear();
  pprov.receiverCurrent.seccName = seccion;
  pprov.receiverCurrent.errores.add(tipoErr['err']);
  pprov.receiverCurrent.intents = pprov.receiverCurrent.intents+1;

  switch (tipoErr['type']) {
    case ErrorType.retry:
      typeE = ErrorType.retry.name;
      if(pprov.receiverCurrent.intents < intentos) {
        pprov.receiverCurrent.cmds.add(CmdType.retryThis);
      }else{
        goPapelera = true;
      }
      break;
    case ErrorType.contac:
    typeE = ErrorType.contac.name;
      pprov.receiverCurrent.cmds.add(CmdType.contactanos);
      goPapelera = true;
      break;
    case ErrorType.drash:
    typeE = ErrorType.drash.name;
      goPapelera = true;
      break;
    case ErrorType.stop:
      typeE = ErrorType.stop.name;
      pprov.receiverCurrent.cmds.add(CmdType.stopAlert);
      break;
    default:
  }

  if(goPapelera) {
    pprov.receiverCurrent.cmds.add(CmdType.notifRemite);
    pprov.receiverCurrent.cmds.add(CmdType.papelera);
  }

  console.addOk('REGISTRADO el tipo [$typeE]');
  console.addDiv();
  return tipoErr['err'];
}

/// Extraemos el tipo de error
Map<String, dynamic> getTipoDeError(String error) {

  if(!error.contains('<')) { return {}; }
  int init = error.indexOf('<');
  int find = error.indexOf('>');
  final type = error.substring(init+1, ((init+1)+((find-1) - init)));
  late ErrorType tipo;
  switch (type) {
    case 'retry':
      tipo = ErrorType.retry;
      break;
    case 'drash':
      tipo = ErrorType.drash;
      break;
    case 'contac':
      tipo = ErrorType.contac;
      break;
    case 'stop':
      tipo = ErrorType.stop;
      break;
    default:
  }
  
  final err = error.replaceAll('<$type>', '');
  return { 'type': tipo, 'err' : err };
}

///
Future<List<String>> getMsgBy(String nameFile) async {
  return await GetContentFile.getMsgOfCampaing(nameFile);
}

///
List<String> buildMsgCom
  (ProcessProvider pprov, {String nombre = ''})
{

  List<String> msg = pprov.msgCurrentFormat;
  List<String> toCompare = [];
  String nom = nombre;
  if(nombre.isEmpty) {
    nom = pprov.receiverCurrent.nombre;
  }
  List<String> items = nom.toLowerCase().split(' ');

  for (var i = 0; i < items.length; i++) {
    toCompare.add(items[i].trim());
  }

  if(pprov.enProceso.data.containsKey('marca')) {

    items = pprov.enProceso.data['marca']['nombre'].toString().toLowerCase().split(' ');
    for (var i = 0; i < items.length; i++) {
      toCompare.add(items[i].trim());
    }
    items = pprov.enProceso.data['modelo']['nombre'].toString().toLowerCase().split(' ');
    for (var i = 0; i < items.length; i++) {
      toCompare.add(items[i].trim());
    }

  }else{

    for (var i = 0; i < msg.length; i++) {

      if(msg[i].contains('*')) {

        String tmp = msg[i].replaceAll('*', '');
        if(!tmp.contains('http')) {
          items = tmp.toLowerCase().split(' ');
          for (var i = 0; i < items.length; i++) {
            String lett = items[i].trim();
            if(lett.length > 3) {
              if(!lett.startsWith('_')) {
                if(!lett.contains('.')) {
                  if(toCompare.length < 5){
                    toCompare.add(items[i].trim());
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  toCompare.add('autoparnet');
  return toCompare;
}

///  
List<String> replaceAutoAndIdOrden(ProcessProvider pprov, List<String> msg) {

  for (var i = 0; i < msg.length; i++) {

    if(msg[i].contains('_auto_')){
      String auto = pprov.enProceso.data['modelo']['nombre'];
      auto = '$auto ${pprov.enProceso.data['anio']}';
      auto = '$auto de ${pprov.enProceso.data['marca']['nombre']}';
      msg[i] = msg[i].replaceAll('_auto_', auto);
    }

    if(msg[i].contains('_idOrden_')) {
      msg[i] = msg[i].replaceAll('_idOrden_', '${pprov.enProceso.src['id']}');
    }
  }
  return msg;
}

///
Future<Map<String, dynamic>> getLstTester() async => await GetContentFile.getCurcsTesting();
