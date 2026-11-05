import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_strings.dart';
import 'locale_cubit.dart';

/// Botón de la barra superior para cambiar entre español e inglés.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  static const _names = {'es': 'Español', 'en': 'English'};

  @override
  Widget build(BuildContext context) {
    final current = context.watch<LocaleCubit>().state;
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.translate),
      tooltip: AppStrings.of(context).language,
      initialValue: current,
      onSelected: context.read<LocaleCubit>().change,
      itemBuilder: (context) => [
        for (final locale in AppStrings.supportedLocales)
          PopupMenuItem(
            value: locale,
            child: Text(_names[locale.languageCode] ?? locale.languageCode),
          ),
      ],
    );
  }
}
