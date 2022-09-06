import 'package:get_it/get_it.dart';

import '../services/rutas/rutas_cache.dart';
import '../vars/globals.dart';

GetIt getSngOf = GetIt.instance;

void sngManager() {

  getSngOf.registerLazySingleton(() => Globals());
  getSngOf.registerLazySingleton(() => RutasCache());
}