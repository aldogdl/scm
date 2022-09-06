///
enum InitProcessT {
  hasProcess, buildReg, getMsg, formatMsg
}
Map<InitProcessT, Map<String, String>> initProcessT = {

  InitProcessT.hasProcess: {
    'task': 'Revisando existencia de MSG.',
  },
  InitProcessT.buildReg: {
    'task': 'Registrando en Base de Datos.',
  },
  InitProcessT.getMsg: {
    'task': 'Recuperando MSG.',
  },
  InitProcessT.formatMsg: {
    'task': 'Formateando MSG.',
  },
};

List<String> errsInitProcess = [
  'ERROR,<drash> No se encontró ningún mensaje para enviar.',
  'ERROR,<drash> No se pudo crear el registro en la BD.'
];