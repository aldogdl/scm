const int ppPort = 9222;
const String ppBase = '127.0.0.1';

const String wsList = '/json/list';
const String wsVersion = '/json/version';
const String wsActive = '/json/activate/';
const String fldPupp = 'puppeteer';

const String pageWhatsapp = 'WhatsApp';
const String uriWhatsapp = 'https://web.whatsapp.com/';

const String msgForContacts = 'add_contact.txt';
const String msgForAlerts = 'alert_to_remit.txt';

const String chatContacts = 'Contactos';
const int intentos = 3;
const esperarPorHtml = Duration(milliseconds: 5000);

enum ErrorType {retry, contac, drash, stop}
enum CmdType {
  retryAll, retryThis, contactanos, papelera,
  notifRemite, stopAlert
}
