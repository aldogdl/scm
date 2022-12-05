import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:puppeteer/puppeteer.dart' as pupp show
ElementHandle, Key, Page;

import '../vars_puppe.dart' show ErrorType;
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

  pprov.receiverCurrent!.intents = pprov.receiverCurrent!.intents+1;

  final tipoErr = getTipoDeError(error);
  if(tipoErr.isEmpty) {
    console.addWar('Error Indeterminado');
    console.addErr(tipoErr['err']);
    pprov.receiverCurrent!.errores.add(
      {
        'step': step, 'tipo': 'Indeterminado',
        'err' : tipoErr['err']
      },
    );
  }else{

    pprov.receiverCurrent!.errores.add(
      {
        'step': step, 'tipo': tipoErr['txtType'],
        'err' : tipoErr['err']
      },
    );
    console.addErr(tipoErr['err']);
  }

  console.addOk('[ERROR] REGISTRADO .......[X]');
  console.addDiv();
  await _sleep();
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
  return { 'type': tipo, 'err' : err, 'txtType': tipo.name};
}

///
List<String> buildMsgCom(ProcessProvider pprov) {
  List<String> toCompare = [];
  if(pprov.enProceso.data.containsKey('marca')) {
    final items = pprov.enProceso.data['marca']['nombre'].toString().toLowerCase().split(' ');
    for (var i = 0; i < items.length; i++) {
      toCompare.add(items[i].trim());
    }
  }
  toCompare.add('autoparnet');
  toCompare.add('cotizo');
  toCompare.add('http');
  toCompare.add('/${pprov.enProceso.data['id']}-');
  return toCompare;
}

