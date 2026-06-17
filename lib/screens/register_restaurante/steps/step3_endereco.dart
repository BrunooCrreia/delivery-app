import 'package:flutter/material.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/register_restaurante/register_restaurante_controller.dart';
import 'package:projeto_perguntas/screens/widgets/register_address_step.dart';

class Step3Endereco extends StatelessWidget {
  const Step3Endereco({super.key, required this.controller});

  final RegisterRestauranteController controller;

  @override
  Widget build(BuildContext context) {
    return RegisterAddressStep(
      controller: controller,
      title: AppStrings.dadosEndereco,
      etapaLabel: AppStrings.etapa4de7,
    );
  }
}
