import 'package:flutter/material.dart';

class RegisterSectionTitle extends StatelessWidget {
  final String title;

  /// Define o tamanho do título.
  /// Usa [titleLarge] por padrão — passe [useMedium: true] para [titleMedium].
  final bool useMedium;

  const RegisterSectionTitle({
    super.key,
    required this.title,
    this.useMedium = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = useMedium
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.titleLarge;

    return Text(title, style: style?.copyWith(fontWeight: FontWeight.bold));
  }
}
