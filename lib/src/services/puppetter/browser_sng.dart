class BrowserSng {

  int browserPid = 0;
  String wsEndpoint = '0';
  final List<String> args = [
    '--remote-debugging-port=9222',
    '--window-position=340,0',
    '--window-size=950x768'
  ];
  final String fldPupp = 'puppeteer';
  final String pageWhatsapp = 'WhatsApp';
  final String uriWhatsapp = 'https://web.whatsapp.com/';
}