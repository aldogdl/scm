import 'package:get_it/get_it.dart';

import '../services/puppetter/browser_sng.dart';
import '../vars/globals.dart';
import '../services/rutas/rutas_cache.dart';

GetIt getSngOf = GetIt.instance;

void sngManager() {

  getSngOf.registerLazySingleton(() => Globals());
  getSngOf.registerLazySingleton(() => RutasCache());
  getSngOf.registerLazySingleton(() => BrowserSng());
}