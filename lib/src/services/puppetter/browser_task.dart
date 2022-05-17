import 'package:puppeteer/puppeteer.dart' as _pupp show
ElementHandle, Key;

import 'browser_sng.dart';
import '../../config/sng_manager.dart';
import 'providers/browser_provider.dart';

class BrowserTask {

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
        _pupp.ElementHandle? element = await _wp.pagewa!.waitForSelector(select);
        if(element == null) {
          return 'ERROR<stop> Ya no hay conexión con la App de Whatsapp';
        }
      } catch (e) {
        return 'ERROR<stop> ${e.toString()}';
      }
    }
    return '';
  }

  // Colocamos el foco en la caja de busqueda de chats
  static Stream<String> buscarContacto({
    String txt = '',
  }) async* {

    String ok = await checarConectividad();
    if(ok.isNotEmpty) {
      yield 'ERROR<stop>, No hay conexión con el Navegador';
      return;
    }

    String? select = mapConcep['bskContac']!['html'];

    late _pupp.ElementHandle? element;
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
          final result = await _writeBskContac(txt, element);
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

  /// Entramos al chat que se nos indica por parametro
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
              String corroborarChat = await _corroborarChat(nombre);
              hasRes = true;
              yield corroborarChat;
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

  /// Revisamos la existencia de la caja de busqueda dentro del chat y si
  /// es encontrada escibimos el mesajes pasado por parametro.
  static Stream<String> escribirMsg(List<String> msg) async* {

    // Primero revisamos la existencia de la caja de texto.
    String? select = mapConcep['writeMsg']!['html'];
    bool hasErr = true;
    String msgR = '';

    if(select != null) {

      _pupp.ElementHandle? element = await _wp.pagewa!.waitForSelector(select);
      try {
        element = await _wp.pagewa!.$OrNull(select);
      } catch (_) {}

      if (element != null) {

        const int veces = 3;
        int intentos = 1;
        for (var i = 0; i < veces; i++) {

          String result = await _writeMensaje(element, msg);
          if(result == 'ok'){
            hasErr = false;
            msgR = result;
            break;
          }

          if(intentos >= veces) {
            hasErr = false;
            msgR = result;
            break;
          }
          intentos++;
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

  ///
  static Future<String> sendMensaje() async {

    String? select = mapConcep['btnSend']!['html'];
    
    if(select != null) {
      _pupp.ElementHandle? element = await _wp.pagewa!.waitForSelector(select);
      try {
        element = await _wp.pagewa!.$OrNull(select);
      } catch (_) {}
      if(element != null) {
        await element.click();
        await _wait(200);
        return 'ok';
      }else{
        return '${lstErrs['btnSend']![0]}';
      }
    }
    return '${lstErrs['btnSend']![1]}';
  }

  /// Escribimos en la caja de busqueda de contactos.
  static Future<String> _writeBskContac(String txt, _pupp.ElementHandle? element) async {

    String? select;
    if(element == null) {
      select = mapConcep['bskContac']!['html'];
      if(select != null) {
        element = await _wp.pagewa!.waitForSelector(select);
      }
    }

    if(element != null) {

      var contenido = await element.evaluate<String>('node => node.innerText');

      if(contenido != null) {
        if(contenido.isNotEmpty) {
          await _wp.pagewa!.keyboard.press(_pupp.Key.end);
          await _wp.pagewa!.keyboard.down(_pupp.Key.shift);
          await _wp.pagewa!.keyboard.press(_pupp.Key.home);
          await _wp.pagewa!.keyboard.up(_pupp.Key.shift);
          await _wait(100);
          await _wp.pagewa!.keyboard.press(_pupp.Key.delete);
          await _wait(100);
        }
      }
      
      await element.type(txt);
      await _wait(500);
      contenido = await element.evaluate<String>('node => node.innerText');

      bool hasContent = true;
      if(contenido != null) {
        if(contenido.isNotEmpty) {
          await _wp.pagewa!.keyboard.press(_pupp.Key.end);
          await _wp.pagewa!.keyboard.down(_pupp.Key.shift);
          await _wp.pagewa!.keyboard.press(_pupp.Key.home);
          await _wp.pagewa!.keyboard.up(_pupp.Key.shift);
        }else{
          hasContent = false;
        }
      }else{
        hasContent = false;
      }
      if(!hasContent) {
        return '${lstErrs['bskContac'][2]}';
      }

      // Esperamos a que aparezca el boton de limpiar busqueda
      int timer = 1;
      bool hasErr = false;
      select = mapConcep['btnDelCtc']!['html'];
      _pupp.ElementHandle? btn = await _wp.pagewa!.waitForSelector(select!);
      do {
        if(espera == timer) { hasErr = true; break; }
        await _wait(1000);
        timer++;
      } while (btn == null);

      if(!hasErr) {

        // Revisamos lo escrito en la caja
        contenido = await element.evaluate<String>('node => node.innerText');
        if(contenido != null) {
          if(contenido == txt) {
            return 'ok';
          }
        }
        await _wp.pagewa!.keyboard.press(_pupp.Key.end);
        await _wp.pagewa!.keyboard.down(_pupp.Key.shift);
        await _wp.pagewa!.keyboard.press(_pupp.Key.home);
        await _wp.pagewa!.keyboard.up(_pupp.Key.shift);
        await _wait(300);
        await element.type(txt, delay: _tiempoDeEscritura);
        contenido = await element.evaluate<String>('node => node.innerText');
        if(contenido != null) {
          if(contenido == txt) {
            return 'ok';
          }
        }
        return '${lstErrs['bskContac'][1]}';
      }else{
        return '${lstErrs['bskContac'][4]}';
      }
    }else{
      return '${lstErrs['bskContac'][1]}';
    }
    
  }

  /// Corroboramos que estamos en el chat correcto
  static Future<String> _corroborarChat(String nombre) async {

    String? select = mapConcep['titDelChat']!['html'];
    _pupp.ElementHandle? element = await _wp.pagewa!.waitForSelector(select!);
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

  ///
  static Future<String> _writeMensaje(_pupp.ElementHandle element, List<String> msg) async {

    await element.click();
    var contenido = await element.evaluate<String>('node => node.innerText');

    if(contenido != null) {
      if(contenido.isNotEmpty) {
        await _wp.pagewa!.keyboard.down(_pupp.Key.control);
        await _wp.pagewa!.keyboard.press(_pupp.Key.keyA);
        await _wp.pagewa!.keyboard.up(_pupp.Key.control);
        await _wp.pagewa!.keyboard.up(_pupp.Key.keyA);
        await _wait(100);
        await _wp.pagewa!.keyboard.press(_pupp.Key.delete);
        await _wait(100);
      }
    }

    for (var i = 0; i < msg.length; i++) {

      if(msg[i].contains('_sp_')) {
        await _wp.pagewa!.keyboard.down(_pupp.Key.control);
        await _wp.pagewa!.keyboard.press(_pupp.Key.enter);
        await _wp.pagewa!.keyboard.up(_pupp.Key.control);
        await _wait(100);
      }else{
        await element.type(msg[i], delay: const Duration(milliseconds:8));
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

  /// Extraemos el tipo de error
  static String getTipoDeError(String error) {

    int init = error.indexOf('<');
    int find = error.indexOf('>');
    return error.substring(init+1, ((init+1)+((find-1) - init)));
  }

  // Tiempo de espera publico.
  static Future<void> wait(int mili) async => await _wait(mili);

  // Tiempo de espera.
  static Future<void> _wait(int mili) async => await Future.delayed(
    Duration(milliseconds: mili)
  );

  ///
  static const List<String> typErr = ['stop', 'retry', 'drash'];
  
  ///
  static const Map<String, dynamic> lstErrs = {
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
      'desc' : 'Caja de Búsqueda de Contactos',
      'html' : '#side>div.uwk68>div>label>div>div._13NKt.copyable-text.selectable-text',
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
  static List<Map<String, dynamic>> getTasks() {

     return [
      {
        'task': 'Revisar Caja de Busqueda',
        'stt' : 0,
        'acc' : 'bskContac',
        'sug' : 'No se encontró la caja de busqueda de contactos principal '
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
    ];
  }

}