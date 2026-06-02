import 'package:flutter/material.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/register_entregador/register_entregador_controller.dart';
import 'package:projeto_perguntas/screens/widgets/register_field.dart';
import 'package:projeto_perguntas/screens/widgets/register_section_title.dart';

class Step1Conta extends StatelessWidget {
  const Step1Conta({super.key, required this.controller});

  final RegisterEntregadorController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RegisterSectionTitle(title: AppStrings.dadosPessoais),
            const SizedBox(height: 4),
            const Text('Etapa 1 de 7'),
            const SizedBox(height: 20),
            RegisterField(
              controller: controller.nomeCompletoController,
              label: 'Nome completo',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome completo';
                }
                if (value.trim().split(' ').length < 2) {
                  return 'Informe nome e sobrenome';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.cpfController,
              label: AppStrings.cpf,
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [controller.cpfMask],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeCpf;
                }
                final digits = value.replaceAll(RegExp(r'\D'), '');
                if (digits.length != 11) return AppStrings.cpfIncompleto;
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.rgController,
              label: 'RG',
              icon: Icons.badge,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o RG';
                }
                if (value.trim().length < 5) {
                  return 'RG invalido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.dataNascimentoController,
              label: AppStrings.dataNascimento,
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [controller.dataMask],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeDataNascimento;
                }
                final digits = value.replaceAll(RegExp(r'\D'), '');
                if (digits.length != 8) return AppStrings.dataIncompleta;
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.selfieController,
              label: 'Foto/Selfie (ID, URL ou referencia)',
              icon: Icons.camera_alt_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a selfie/documento de identificacao';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.nomeMaeController,
              label: 'Nome da mae (opcional)',
              icon: Icons.family_restroom_outlined,
              defaultErrorMessage: null,
              validator: (_) => null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => controller.nextPage(controller.formKey1),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(AppStrings.proximo),
            ),
          ],
        ),
      ),
    );
  }
}
