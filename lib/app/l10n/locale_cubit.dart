import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_strings.dart';

/// Idioma elegido en la app. Empieza en español.
///
/// Ejercicio: guarda la elección en SQLite para recordarla al reabrir la app.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit([Locale? initial])
    : super(initial ?? AppStrings.supportedLocales.first);

  void change(Locale locale) => emit(locale);
}
