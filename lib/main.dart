import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/dependencies.dart';
import 'core/infrastructure/app_database.dart';

/// Punto de entrada: abre SQLite, monta las dependencias, crea el usuario de
/// prueba (si no existe) y arranca la interfaz.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await AppDatabase.open();
  final dependencies = AppDependencies.sqlite(database);
  await dependencies.seedDefaultUser();

  runApp(WsMovilApp(dependencies: dependencies));
}
