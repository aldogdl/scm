///
enum FinProcessT {
  stopCronFile,  updateSttBD, saveDataLocal, sendPush, moveFile
}
Map<FinProcessT, Map<String, String>> finProcessT = {

  FinProcessT.stopCronFile: {
    'task': 'Deteniendo Monitoreo',
  },
  FinProcessT.updateSttBD: {
    'task': 'Actualizando Status en B.D.',
  },
  FinProcessT.saveDataLocal: {
    'task': 'Guardando datos en local',
  },
  FinProcessT.sendPush: {
    'task': 'Enviando Notificación',
  },
  FinProcessT.moveFile: {
    'task': 'Moviendo archivos locales',
  }
};

