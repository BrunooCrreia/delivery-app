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
            const RegisterSectionTitle(title: AppStrings.cnhESeguranca),
            const SizedBox(height: 4),
            const Text(AppStrings.etapaEntregador4),
            const SizedBox(height: 20),
            RegisterField(
              controller: controller.cnhNumeroController,
              label: AppStrings.cnhNumero,
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeCnhNumero;
                }
                if (value.replaceAll(RegExp(r'\D'), '').length < 9) {
                  return AppStrings.cnhNumeroInvalido;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.cnhValidadeController,
              label: AppStrings.cnhValidade,
              icon: Icons.event_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [controller.dataMask],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeCnhValidade;
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
              label: AppStrings.cnhFrente,
              icon: Icons.photo_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeCnhFrente;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.cnhVersoController,
              label: AppStrings.cnhVerso,
              icon: Icons.photo_library_outlined,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeCnhVerso;
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
