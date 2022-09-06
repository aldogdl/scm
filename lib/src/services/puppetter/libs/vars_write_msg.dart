///
enum WriteMsgT {
  html, bskBoxWrite, capturCheckBox, writeMsg, checkChat, checkMsg, send
}
Map<WriteMsgT, Map<String, String>> writeMsgt = {
  WriteMsgT.html: {
    'caja': '#main>footer>div._2BU3P.tm2tP.copyable-area>div>span:nth-child(2)>div>div._2lMWa>div.p3_M1>div>div.fd365im1.to2l77zo.bbv8nyr4.mwp4sxku.gfz4du6o.ag5g9lrv',
    'send': '#main>footer>div._2BU3P.tm2tP.copyable-area>div>span:nth-child(2)>div>div._2lMWa>div._3HQNh._1Ae7k>button',
    'check': '#main>footer>div._2BU3P.tm2tP.copyable-area>div>span:nth-child(2)>div>div._2lMWa>div._3HQNh._1Ae7k>button>span',
    'chatRoomTitulo': '#main>header>div._24-Ff>div._2rlF7>div>span',
  },
  WriteMsgT.bskBoxWrite: {
    'task': 'Detectando Caja de Mensajes',
  },
  WriteMsgT.capturCheckBox: {
    'task': 'Capturando Caja de Mensajes',
  },
  WriteMsgT.writeMsg: {
    'task': 'Escribiendo Mensaje',
  },
  WriteMsgT.checkChat: {
    'task': 'Checando el Chat Room',
  },
  WriteMsgT.checkMsg: {
    'task': 'Revisando el mensaje',
  },
  WriteMsgT.send: {
    'task': 'Mensaje Enviado',
  }
};

///
List<String> errsWrite = [
  'ERROR<retry>, No se alcanzó la caja de texto para escritura de mensajes.',
  'ERROR<retry>, No se pudo eliminar el contenido del mensaje.',
  'ERROR<retry>, El mensaje se escribió incorrecto.',
  'ERROR<retry>, No se alcanzó el Boton de envio de mensajes.'
];
