import 'package:flutter/material.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/register_entregador/register_entregador_controller.dart';
import 'package:projeto_perguntas/screens/widgets/register_field.dart';
import 'package:projeto_perguntas/screens/widgets/register_section_title.dart';

class Step4Cnh extends StatelessWidget {
  const Step4Cnh({super.key, required this.controller});

  final RegisterEntregadorController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.formKey4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RegisterSectionTitle(title: 'CNH e seguranca'),
            const SizedBox(height: 4),
            const Text('Etapa 4 de 7'),
            const SizedBox(height: 20),
            RegisterField(
              controller: controller.cnhNumeroController,
              label: 'Numero da CNH',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o numero da CNH';
                }
                if (value.replaceAll(RegExp(r'\D'), '').length < 9) {
                  return 'Numero de CNH invalido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.cnhCategoriaController,
              label: 'Categoria da CNH',
              icon: Icons.category_outlined,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a categoria da CNH';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.cnhValidadeController,
              label: 'Validade da CNH',
              icon: Icons.event_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [controller.dataMask],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a validade da CNH';
                }
                final digits = value.replaceAll(RegExp(r'\D'), '');
                if (digits.length != 8) {
                  return AppStrings.dataIncompleta;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.cnhFrenteController,
              label: 'CNH frente (ID, URL ou referencia)',
              icon: Icons.photo_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a foto da frente da CNH';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.cnhVersoController,
              label: 'CNH verso (ID, URL ou referencia)',
              icon: Icons.photo_library_outlined,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a foto do verso da CNH';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.prevPage,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(AppStrings.voltar),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.nextPage(controller.formKey4),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(AppStrings.proximo),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}