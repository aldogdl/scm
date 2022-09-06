import 'dart:io';
import 'package:puppeteer/protocol/target.dart';
import 'package:puppeteer/puppeteer.dart';

import 'libs/vars_bsk_contact.dart';
import 'vars_puppe.dart';
import '../get_paths.dart';
import '../../vars/globals.dart';
import '../../config/sng_manager.dart';

class BrowserConn {

  static final _globals = getSngOf<Globals>();
  static String typeErr = '';

  ///
  static Future<Browser?> tryConnect() async {

    Browser? browser;
    try {
      browser = await puppeteer.connect(
        browserUrl: 'http://$ppBase:$ppPort', defaultViewport: getViewer()
      );
    } catch (e) {
      typeErr = e.toString();
    }

    return browser;
  }

  ///
  static Future<Browser?> lanzar() async {

    final userDataDir = _getRoot();
    List<String>? arguments = getArgs();

    Browser? browser;
    try {
      browser = await puppeteer.launch(
        headless: false, userDataDir: userDataDir, devTools: true,
        args: arguments, defaultViewport: getViewer()
      );
    } catch (e) {
      typeErr = e.toString();
    }

    return browser;
  }

  ///
  static DeviceViewport getViewer() {

    final w = _globals.sizeWin.width * 0.73;
    final h = _globals.sizeWin.height - 190;
    final ws = w.toStringAsFixed(0);
    final hs = h.toStringAsFixed(0);
    return DeviceViewport(
      width: int.parse(ws), height: int.parse(hs)
    );
  }

  ///
  static Future<Page?> getPageByIdTarget(Browser browser, String id) async {

    Target? tar = browser.targetById(TargetID(id));
    if(tar != null) {
      if(tar.isPage) {
        return await tar.page;
      }
    }
    return await getPageWhatsapp(browser);
  }

  ///
  static Future<Page?> getPageWhatsapp(Browser browser) async {

    List<Page> paginas = await browser.pages;
    if(paginas.isNotEmpty) {

      paginas.map((pagina) async {

        String? name = await pagina.title;
        if(name != null) {
          if(name.isNotEmpty) {
            if(name.toString().toLowerCase().contains(pageWhatsapp.toLowerCase())) {
              return pagina;
            }
          }
        }
      }).toList();
    }

    return null;
  }

  ///
  static List<String> getArgs() {

    var va = _globals.sizeWin.width * 0.27;
    final poss = int.parse(va.toStringAsFixed(0));
    va = _globals.sizeWin.width * 0.73;
    final width = int.parse(va.toStringAsFixed(0));
    final alto = _globals.sizeWin.height - 118;    
    final height = int.parse(alto.toStringAsFixed(0));

    return [
      '--remote-debugging-port=$ppPort',
      '--window-position=$poss,0',
      '--window-size=$width${"x"}$height'
    ];
  }

  ///
  static Future<String> tryLunchWhatsapp(Page page) async {
    
    late Response site;
    try {
      site = await page.goto(uriWhatsapp,  wait: Until.networkIdle);
      if(site.data.status == 200) {
        return await page.title ?? ''; 
      }
      return site.data.serviceWorkerResponseSource.toString();
    } catch (e) {
      typeErr = e.toString();
    }
    return '';
  }

  ///
  static String _getRoot() {

    final String sep = GetPaths.getSep();
    Directory pathRoot = Directory('${GetPaths.getPathRoot()}$sep$fldPupp');
    if(!pathRoot.existsSync()) {
      pathRoot.createSync();
    }
    return pathRoot.path;
  }

  ///
  static Future<void> closeBrowser(Browser browser, int pib) async {

    try {
      await browser.close();
    } catch (_) { }

    Process.killPid(pib);
  }

  ///
  static Future<String> checarConectividad
    (Browser? browser, Page? page, String title) async
  {

    if(browser == null) {
      return 'ALERTA<stop> No se ha inicializado el Navegador';
    }

    if(page == null) {
      return 'ALERTA<stop> No se ha inicializado ninguna página';
    }

    if(!browser.isConnected) {
      return 'ALERTA<stop> No se ha inicializado el Navegador';
    }
    if(title.isEmpty) {
      return 'ALERTA<stop> No se ha inicializado la App web de Whatsapp';
    }

    String? select = taskContact[TaskContac.html]!['caja'];
    if(select != null) {
      try {
        ElementHandle? e = await page.waitForSelector(select);
        if(e == null) {
          return 'ERROR<stop> Ya no hay conexión con la App de Whatsapp';
        }
      } catch (e) {
        return 'ERROR<stop> ${e.toString()}';
      }
    }
    return '';
  }


}