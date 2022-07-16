import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

import '../../vars/globals.dart';
import '../get_paths.dart';
import 'browser_sng.dart';
import 'providers/browser_provider.dart';
import '../../config/sng_manager.dart';

class BrowserConn {

  static late BrowserProvider _wp;
  static BrowserProvider get wp => _wp;
  static BrowserSng browserSng = getSngOf<BrowserSng>();

  static int _intentos = 1;
  static final _globals = getSngOf<Globals>();
  
  ///
  static Future<void> lanzar(BrowserProvider wp) async {

    bool hasErr = false;
    _wp = wp;
    final userDataDir = _getRoot();
    List<String>? arguments = browserSng.getArgs(_globals.sizeWin);

    if(_wp.pib != 0) {
      
      try {
        _wp.browser = await puppeteer.connect(
          browserWsEndpoint: browserSng.wsEndpoint,
        );
      } catch (e) {
        await _setVariables();
        if(browserSng.browserPid == 0) {
          hasErr = true;
          await _closeBrowser();
        }
      }

    }else{

      // intentamos conectar con alguna instancia abirta de chrominium
      try {
        _wp.browser = await puppeteer.connect(
          browserUrl: 'http://127.0.0.1:${browserSng.port}',
        );
      } catch (_) {
        
        try {
          _wp.browser = await puppeteer.launch(
            headless: false,
            userDataDir: userDataDir,
            devTools: true,
            args: arguments,
          );
        } catch (e) {

          await _setVariables();
          if(browserSng.browserPid == 0) {
            hasErr = true;
            await _closeBrowser();
          }
        }
      }
    }

    if(!hasErr) {
      _setVariables();
    }

  }

  ///
  static Future<void> initWhatsapp() async {

    if(_wp.browser != null) {
      
      List<Page> paginas = await _wp.browser!.pages;
      if(paginas.isEmpty) {
         _wp.pagewa = await _wp.browser!.newPage();
         await _iniciarPageWhatsApp();
      }else{
        
        if(_wp.pagewa != null) {
          final ti = await _wp.pagewa!.title;
          if(ti != null) {
            if(ti.contains('WhatsApp')) {
              _wp.titleCurrent = ti;
              return;
            }
          }
        }
        paginas.map((pagina) async {

          String? name = await pagina.title;
          if(name != null) {
            if(name.isEmpty) {
              _wp.pagewa = pagina;
              await _iniciarPageWhatsApp();
            }else{
              if(!name.contains('WhatsApp')) {
                _wp.pagewa = pagina;
                await _iniciarPageWhatsApp();
              }
            }
          }else{
            _wp.pagewa = pagina;
            await _iniciarPageWhatsApp();
          }
        }).toList();
      }
    }
  }

  ///
  static Future<void> _iniciarPageWhatsApp() async {
    
    await _wp.pagewa!.setViewport(
      const DeviceViewport(width: 990, height: 768)
    );
    Response site = await _wp.pagewa!.goto(
      browserSng.uriWhatsapp,
      wait: Until.networkIdle,
<<<<<<< HEAD
      timeout: const Duration(milliseconds: 300000)
=======
      timeout: const Duration(minutes: 3)
>>>>>>> 5ca0a8d1e7f6ddde07593b80f706a3b67541cbbe
    );
    if(site.data.status == 200) {
      _wp.titleCurrent = await _wp.pagewa!.title ?? ''; 
    }
  }
  
  ///
  static String _getRoot() {

    final String sep = GetPaths.getSep();
    Directory pathRoot = Directory('${GetPaths.getPathRoot()}$sep${browserSng.fldPupp}');
    if(!pathRoot.existsSync()) {
      pathRoot.createSync();
    }
    return pathRoot.path;
  }

  ///
  static _setVariables() async {

    try {
      _wp.pib = _wp.browser!.process!.pid;
      browserSng.browserPid = _wp.browser!.process!.pid;
      browserSng.wsEndpoint = _wp.browser!.wsEndpoint;
    } catch (e) {
      _wp.pib = 0;
      browserSng.browserPid = 0;
      await _closeBrowser();
    }
  }

  ///
  static Future<void> _closeBrowser() async {

    if(_intentos >= 3) {
      _wp.msgs = 'ERRCONX';
      return;
    }

    _intentos++; 

    try {
      await _wp.browser!.close();
    } catch (_) { }

    Process.killPid(_wp.pib);
    _wp.pib = 0;
    _wp.browser = null;
    browserSng.browserPid = 0;
    browserSng.wsEndpoint = '0';
    await Future.delayed(const Duration(milliseconds: 500));
    lanzar(wp);
  }


}