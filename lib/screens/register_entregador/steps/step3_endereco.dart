import 'package:flutter/material.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/register_entregador/register_entregador_controller.dart';
import 'package:projeto_perguntas/screens/widgets/register_address_step.dart';

class Step3Endereco extends StatelessWidget {
  const Step3Endereco({super.key, required this.controller});

  final RegisterEntregadorController controller;

  @override
  Widget build(BuildContext context) {
    return RegisterAddressStep(
      controller: controller,
      title: AppStrings.enderecoResidencial,
      etapaLabel: 'Etapa 3 de 7',
    );
  }
}
