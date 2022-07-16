import 'package:puppeteer/puppeteer.dart' as pupp show
ElementHandle, Key;

import 'browser_sng.dart';
import '../../config/sng_manager.dart';
import 'providers/browser_provider.dart';

class BrowserTask {

  static const intentos = 3;

  static late BrowserProvider _wp;
  static BrowserProvider get wp => _wp;
  static BrowserSng browserSng = getSngOf<BrowserSng>();
  static int espera = 10;
  static const Duration _tiempoDeEscritura = Duration(milliseconds: 8);
  static const String prefixHtml = '#main>footer>div._2BU3P.tm2tP.copyable-area>div>span:nth-child(2)>div>div';
  static const String chatContacts = 'Contactos';
  static List<String> comparaCon = [];

  /// Inyectamos el BrowserProvider a esta clase.
  static init(BrowserProvider wp) => _wp = wp;

  // [1] Colocamos el foco en la caja de busqueda de chats
  static Stream<String> buscarContacto({String txt = ''}) async* {

    String ok = await checarConectividad();
    if(ok.isNotEmpty) {
      yield 'ERROR<stop>, No hay conexión con el Navegador';
      return;
    }

    String? select = mapConcep['bskContac']!['html'];

    late pupp.ElementHandle? element;
    if(select != null) {
      try {
        element = await _wp.pagewa!.waitForSelector(select);
      } catch (e) {
        if(e.toString().contains('closed')) {
          yield '${lstErrs['bskContac']![0]}';
          return;
        }
      }

      if(element != null) {

        await element.click();
        if(txt.isNotEmpty) {

          var result = '${lstErrs['bskContac']![1]}';
          for (var i = 0; i < intentos; i++) {
            result = await _writeBskContac(i, txt, element);
            if(result != 'reintentar') {
              break;
            }
          }
          if(result == 'reintentar') {
            result = '${lstErrs['bskContac']![1]}';
          }
          yield result;
          return;
        }else{
          yield 'ok';
          return;
        }
      }
    }

    yield '${lstErrs['bskContac']![1]}';
  }

  /// [2] Escribimos en la caja de busqueda de contactos.
  static Future<String> _writeBskContac(
    int intents, String txt, pupp.ElementHandle element
  ) async {

    var contenido = await element.evaluate<String>('node => node.innerText');

    if(contenido != null) {
      if(contenido.isNotEmpty) {
        await _wp.pagewa!.keyboard.press(pupp.Key.end);
        await _wp.pagewa!.keyboard.down(pupp.Key.shift);
        await _wp.pagewa!.keyboard.press(pupp.Key.home);
        await _wp.pagewa!.keyboard.up(pupp.Key.shift);
        await _wait(100);
        await _wp.pagewa!.keyboard.press(pupp.Key.delete);
        await _wait(100);
      }
    }
    
    if(intents > 1) {
      await element.type(txt, delay: _tiempoDeEscritura);
    }else{
      await element.type(txt);
    }

    await _wait(500);

    // Revisamos lo escrito en la caja
    contenido = await element.evaluate<String>('node => node.innerText');
    if(contenido != null) {
      if(contenido == txt) {
        return 'ok';
      }
    }
    return 'reintentar';
  }

  /// [3] Entramos al chat que se nos indica por parametro
  static Stream<String> entrarAlChat(
    String nombre, {bool isGrup = false, String? selector}
  ) async* {

    String? select = mapConcep['chatDeCtc']!['html'];
    if(isGrup) {
      select = mapConcep['chatDeGrupos']!['html'];
    }

    bool hasRes = false;
    final chats = await _wp.pagewa!.$$(select!);
    if(chats.isNotEmpty) {

      for (var i = 0; i < chats.length; i++) {

        String? nombreDelChat = await chats[i].evaluate<String>('node => node.innerText');
        if(nombreDelChat != null) {
          if(nombreDelChat == nombre) {
            try {
              await chats[i].click();
              await _wait(500);
              String isOkChat = await _isOkChat(nombre);
              if(isOkChat == 'ok') {
                hasRes = true;
              }
              yield isOkChat;
            } catch (e) {
              yield '${lstErrs['chatDeCtc']![0]}';
            }              
            break;
          }
        }
      }
    }

    if(!hasRes) {
      String msgE = '${lstErrs['chatDeCtc']![2]}';
      msgE = msgE.replaceAll('_nombre_', nombre);
      yield msgE;
    }
  }

  /// [4] Corroboramos que estamos en el chat correcto
  static Future<String> _isOkChat(String nombre) async {

    String? select = mapConcep['titDelChat']!['html'];
    pupp.ElementHandle? element = await _wp.pagewa!.waitForSelector(select!);
    if(element != null) {

      String? nombreDelChat = await element.evaluate<String>('node => node.innerText');
      if(nombreDelChat != null) {
        if(nombreDelChat == nombre) {
          return 'ok';
        }
      }
    }
    return '${lstErrs['chatDeCtc']![1]}';
  }

  /// [5] Revisamos la existencia de la caja de busqueda dentro del chat y si
  /// es encontrada escibimos el mesajes pasado por parametro.
  static Stream<String> escribirMsg(List<String> msg) async* {

    bool hasErr = true;
    String msgR = '';

    // Primero revisamos la existencia de la caja de texto.
    String? select = mapConcep['writeMsg']!['html'];
    if(select != null) {

      pupp.ElementHandle? element = await _wp.pagewa!.waitForSelector(select);
      try {
        element = await _wp.pagewa!.$OrNull(select);
      } catch (_) {}

      if (element != null) {
        await element.click();
        await _wait(500);
        msgR = '${lstErrs['writeMsg']![1]}';
        for (var i = 0; i < intentos; i++) {
          msgR = await _writeMensaje(i, element, msg);
          if(msgR == 'ok'){
            hasErr = false;
            break;
          }
        }
      }else{
        msgR = '${lstErrs['writeMsg']![0]}';
      }
    }

    if(hasErr) {
      msgR = '${lstErrs['writeMsg']![1]}';
    }
    yield msgR;
  }

  /// [6]
  static Future<String> _writeMensaje(int intents, pupp.ElementHandle element, List<String> msg) async {

    var contenido = await element.evaluate<String>('node => node.innerText');

    if(contenido != null) {
      if(contenido.isNotEmpty) {
        await _wp.pagewa!.keyboard.down(pupp.Key.control);
        await _wp.pagewa!.keyboard.press(pupp.Key.keyA);
        await _wp.pagewa!.keyboard.up(pupp.Key.control);
        await _wp.pagewa!.keyboard.up(pupp.Key.keyA);
        await _wait(100);
        await _wp.pagewa!.keyboard.press(pupp.Key.delete);
        await _wait(100);
      }
    }

    for (var i = 0; i < msg.length; i++) {

      if(msg[i].contains('_sp_')) {
        await _wp.pagewa!.keyboard.down(pupp.Key.control);
        await _wp.pagewa!.keyboard.press(pupp.Key.enter);
        await _wp.pagewa!.keyboard.up(pupp.Key.control);
        await _wait(100);
      }else{
        if(intents > 1) {
          await element.type(msg[i], delay: _tiempoDeEscritura);
        }else{
          await element.type(msg[i]);
        }
      }
    }

    bool isOkTxtRes = true;
    contenido = await element.evaluate<String>('node => node.innerText');
    if(contenido != null) {
      
      contenido = contenido.toLowerCase();

      for (var i = 0; i < comparaCon.length; i++) {
        if(!contenido.contains(comparaCon[i])) {
          isOkTxtRes = false;
          break;
        }
      }
    }

    if(isOkTxtRes) {
      return 'ok';
    }else{
      return 'err';
    }
  }

  /// [7]
  static Future<String> sendMensaje() async {

    String? select = mapConcep['btnSend']!['html'];
    
    if(select != null) {
      pupp.ElementHandle? element = await _wp.pagewa!.waitForSelector(select);
      try {
        element = await _wp.pagewa!.$OrNull(select);
      } catch (_) {}
      if(element != null) {
        await element.click();
        await _wait(500);
        return 'ok';
      }else{
        return '${lstErrs['btnSend']![0]}';
      }
    }
    return '${lstErrs['btnSend']![1]}';
  }

  ///
  static Future<String> ultimaRevicionAntesDeEnviar() async {

    String? select = mapConcep['writeMsg']!['html'];
    if(select != null) {

      pupp.ElementHandle? element = await _wp.pagewa!.waitForSelector(select);
      try {
        element = await _wp.pagewa!.$OrNull(select);
      } catch (_) {}

      if (element == null) { return '${lstErrs['writeMsg']![0]}'; }
        
      await element.click();
      await _wait(500);
      var contenido = await element.evaluate<String>('node => node.innerText');

      if(contenido != null) {
        if(contenido.isNotEmpty) {
          await _wp.pagewa!.keyboard.down(pupp.Key.control);
          await _wp.pagewa!.keyboard.press(pupp.Key.keyA);
          await _wp.pagewa!.keyboard.up(pupp.Key.control);
          await _wp.pagewa!.keyboard.up(pupp.Key.keyA);
          await _wait(100);
        }
      }

      bool isOkTxtRes = true;
      contenido = await element.evaluate<String>('node => node.innerText');
      if(contenido != null) {
        
        contenido = contenido.toLowerCase();

        for (var i = 0; i < comparaCon.length; i++) {
          if(!contenido.contains(comparaCon[i])) {
            isOkTxtRes = false;
            break;
          }
        }
      }

      if(isOkTxtRes) {return 'ok'; }
    }

    return '${lstErrs['writeMsg']![1]}';
  }


  // ------------------ FUNCTIONS ----------------------

  
  ///
  static Future<String> checarConectividad() async {

    if(_wp.browser == null) {
      return 'ALERTA<stop> No se ha inicializado el Navegador';
    }
    if(_wp.pagewa == null) {
      return 'ALERTA<stop> Inicializa App web de Whatsapp';
    }
    if(_wp.pib == 0) {
      return 'ALERTA<stop> No se inicializó correctamente el Navegador';
    }
    if(_wp.titleCurrent.isEmpty) {
      return 'ALERTA<stop> No se ha inicializado la App web de Whatsapp';
    }

    String? select = mapConcep['bskContac']!['html'];
    if(select != null) {
      try {
        pupp.ElementHandle? element = await _wp.pagewa!.waitForSelector(select);
        if(element == null) {
          return 'ERROR<stop> Ya no hay conexión con la App de Whatsapp';
        }
      } catch (e) {
        return 'ERROR<stop> ${e.toString()}';
      }
    }
    return '';
  }

  /// Extraemos el tipo de error
  static String getTipoDeError(String error) {

    int init = error.indexOf('<');
    int find = error.indexOf('>');
    return error.substring(init+1, ((init+1)+((find-1) - init)));
  }

  // Tiempo de espera publico.
  static Future<void> wait(int mili) async => await _wait(mili);

  // Tiempo de espera interno.
  static Future<void> _wait(int mili) async => await Future.delayed(
    Duration(milliseconds: mili)
  );

  ///
  static const List<String> typErr = ['stop', 'retry', 'drash'];
  
  ///
  static const Map<String, dynamic> lstErrs = {
    'buildReg' : [
      'ERROR,<drash> No se creo el registro inicial en la BD local',
    ],
    'bskContac' : [
      'ERROR,<stop> Sin Conexión a Internet',
      'ERROR,<retry> No se alcanzó la caja de Búsqueda de Contactos.',
      'ERROR,<retry> No se escribió el CURC en la caja de Busqueda de contacto',
      'ERROR,<drash> El sistema sobre paso el tiempo de espera al querer buscar el contacto.'
    ],
    'chatDeCtc' : [
      'ERROR<drash>, El Elemento del chat que se estaba buscando no fué visible en pantalla.',
      'ERROR<retry>, No se alcanzó el TÍTULO DEL CHAT para poder corroborar su veracidad.',
      'ERROR<contac>, No se econtró entre los resultados el CHAT _nombre_.'
    ],
    'writeMsg' : [
      'ERROR<retry>, No se alcanzó la caja de texto para escritura de mensajes.',
      'ERROR<retry>, El mensaje se escribió incorrecto, intentar nuevamente.'
    ],
    'btnSend' : [
      'ERROR<retry>, No se alcanzó el Botón para enviar el mensaje',
      'ERROR<retry>, Inesperado al presionar el botón de enviar mensaje.'
    ]
  };

  /// La lista de los elementos HTML de la App Whatsappweb
  static const mapConcep = <String, Map<String, String>>{
    
    'bskContac' : {
      'desc' : 'Cuadro de texto para ingresar la búsqueda',
      'html' : '#side>div.uwk68>div>div>div._16C8p>div>div._13NKt.copyable-text.selectable-text',
    },
    'btnDelCtc' : {
      'desc' : 'El boton de borrado en la caja de Búsqueda de Contactos',
      'html' : 'button._3GYfN>span'
    },
    'chatDeCtc' : {
      'desc' : 'El chat de Contactos de Autoparnet, un grupo interno',
      'html' : 'div.zoWT4>span>span.matched-text',
    },
    'chatDeGrupos' : {
      'desc' : 'Chats pertenecientes a un Grupo, estos tienen otro selector',
      'html' : 'div.zoWT4>span'
    },
    'titDelChat' : {
      'desc' : 'El titulo dentro del chat.',
      'html' : '#main>header>div._24-Ff>div._2rlF7>div>span'
    },
    'writeMsg' : {
      'desc' : 'La caja de texto para escribir mensajes.',
      'html' : '$prefixHtml._2lMWa>div.p3_M1>div>div._13NKt.copyable-text.selectable-text'
    },
    'btnSend' : {
      'desc' : 'El boton para finalmente enviar el mensajes.',
      'html' : '#main>footer>div._2BU3P.tm2tP.copyable-area>div>span:nth-child(2)>div>div._2lMWa>div._3HQNh._1Ae7k>button'
    }
  };

  ///
  static List<Map<String, dynamic>> getTasks({bool isTest = false}) {

    List<Map<String, dynamic>> task = [];
    
    if(!isTest) {
      task.add({
        'task': 'Crear Registro inicial',
        'stt' : 0,
        'acc' : 'buildReg',
        'sug' : 'Creamos el registro en la base de datos local para obtener un ID unico '
        'el cual será enviado en el link al receiver para identificar los status de los msgs'
      });
    }
    task.addAll(
      [
        {
          'task': 'Revisar Caja de Busqueda',
          'stt' : 0,
          'acc' : 'bskContac',
          'sug' : 'No se encontró la caja de búsqueda de contactos principal '
          'Asegurate de que este visible para el SCM.'
        },
        {
          'task': 'Entrar al Chat de Contactos',
          'stt' : 0,
          'acc' : 'entraChat',
          'sug' : '¿Estás segur@ de que estás usando el dispositivo correcto?'
        },
        {
          'task': 'Escribe y Revisar la caja de Mensajes',
          'stt' : 0,
          'acc' : 'checkBoxWriteMsg',
          'sug' : 'Por favor, es necesario que la caja de mensajes dentro de '
          'cualquier chat esté visible para el SCM, asegurate de realizar esta acción.'
        },
        {
          'task': 'Enviar mensaje de Bienvenida',
          'stt' : 0,
          'acc' : 'sendMsg',
          'sug' : 'Se encontró un error en el sistema, por favor llama al administrador'
        }
      ]
    );
    return task;
  }

}