///
enum TaskContac {
  html, bskContac, capturBox, capturCheckBox, writeCtac, checkCtac
}
Map<TaskContac, Map<String, String>> taskContact = {
  TaskContac.html: {
    'caja': '#side>div.uwk68>div>div>div._16C8p>div>div._13NKt.copyable-text.selectable-text',
    'back': '#side>div.uwk68>div>div>button._28-cz',
    'xDel': '#side>div.uwk68>div>div>span>button._3GYfN'
  },
  TaskContac.bskContac: {
    'task': 'Detectando Caja de Búsqueda',
  },
  TaskContac.capturBox: {
    'task': 'Capturando Caja de Búsqueda',
  },
  TaskContac.capturCheckBox: {
    'task': 'Asegurando captura de Caja',
  },
  TaskContac.writeCtac: {
    'task': 'Escribiendo nombre del Contacto',
  },
  TaskContac.checkCtac: {
    'task': 'Revisando nombre del Contacto',
  },
};

///
List<String> errsContact = [
  'ERROR,<stop> Sin Conexión a Internet',
  'ERROR,<retry> No se alcanzó la caja de Búsqueda de Contactos.',
  'ERROR,<retry> No se escribió el CURC en la caja de Busqueda de contacto',
  'ERROR,<retry> El sistema sobre paso el tiempo de espera al querer buscar el contacto.',
  'ERROR,<retry> No se recibió el CURC. variable bacía'
];
