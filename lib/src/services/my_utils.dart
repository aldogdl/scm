class MyUtils {

  /// Recuperamos y calculamos la fecha de hoy
  static Map<String, dynamic> getFecha({DateTime? fecha}) {

    late DateTime hoy;
    if(fecha == null) {
      hoy = DateTime.now();
    }else{
      hoy = fecha;
    }
    
    String dia = (hoy.day < 10) ? '0${hoy.day}' : '${hoy.day}';
    String mes = (hoy.month < 10) ? '0${hoy.month}' : '${hoy.month}';
    String hr = '';
    String saludo = '¡Buenos Dias!';

    if(hoy.hour == 13) {
      hr = '01';
      saludo = '¡Buenas Tardes!';
    }else{
      if(hoy.hour < 10) {
        hr = '0${hoy.hour}';
      }else{
        if(hoy.hour > 9 && hoy.hour < 12) {
          hr = '${hoy.hour}';
        }else{

          saludo = '¡Buenas Tardes!';
          double to12Hrs = (hoy.hour - 10) - 2;
          hr = to12Hrs.toStringAsFixed(0);
          if(to12Hrs < 10) {
            hr = '0${to12Hrs.toStringAsFixed(0)}';
          }
          if(to12Hrs >= 7) {
            saludo = '¡Buenas Noches!';
          }
        }
      }
    }
    
    String min = (hoy.minute < 10) ? '0${hoy.minute}' : '${hoy.minute}';

    return <String, dynamic>{
      'completa': '$dia-$mes-${hoy.year} $hr:$min',
      'saludo'  : saludo,
      'tiempo'  : '$hr:$min',
      'fecha'   : '$dia-$mes-${hoy.year}',
      'mini'    : '$dia-$mes  $hr:$min',
    };
  }

  /// Formateamos el telefono
  static String formatTel(String tel) {

    List<String> partes = [];
    List<String> bloques = [];
    List<String> segmento = [];
    const int slot = 4;
    for (var i = 0; i < tel.length; i++) {
      partes.add(tel[i]);
    }

    partes = partes.reversed.toList();
    for (var i = 0; i < partes.length; i++) {
      segmento.add(partes[i]);
      if(segmento.length == slot) {
        segmento = segmento.reversed.toList();
        bloques.insert(0, segmento.join());
        segmento.clear();
      }
    }
    if(segmento.isNotEmpty) {
      segmento = segmento.reversed.toList();
      bloques.insert(0, segmento.join());
    }
    return bloques.join(' ');
  }
}