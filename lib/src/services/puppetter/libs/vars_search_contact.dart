///
enum FindCtac {
  html, searchCtac, checkTitulo
}

Map<FindCtac, Map<String, String>> findCtac = {
  FindCtac.html: {
    'chatLstNormal': 'div.zoWT4>span>span.matched-text',
    'chatLstGroup': 'div.zoWT4>span',
    'chatRoomTitulo': '#main>header>div._24-Ff>div._2rlF7>div>span',
  },
  FindCtac.searchCtac: {
    'task': 'Buscando el Contacto en la Lista',
  },
  FindCtac.checkTitulo: {
    'task': 'Corroborando Chat',
  },
};

///
List<String> errsSearch = [
  'ERROR<contac>, No se encontró entre los resultados el CHAT > ',
  'ERROR<retry>, No se esta en el mismo dentro del Room del Chat Solicitado.',
  'ERROR<retry>, No se alcanzó el TÍTULO DEL CHAT para poder corroborar su veracidad.'
];
