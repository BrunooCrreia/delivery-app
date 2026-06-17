import 'package:flutter/material.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/register_restaurante/register_restaurante_controller.dart';
import 'package:projeto_perguntas/screens/widgets/register_field.dart';
import 'package:projeto_perguntas/screens/widgets/register_section_title.dart';

class Step3Responsavel extends StatelessWidget {
  const Step3Responsavel({super.key, required this.controller});

  final RegisterRestauranteController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RegisterSectionTitle(
              title: AppStrings.dadosResponsavel,
              useMedium: true,
            ),
            const SizedBox(height: 4),
            const Text(AppStrings.etapa3de7),
            const SizedBox(height: 20),
            RegisterField(
              controller: controller.nomeResponsavelController,
              label: AppStrings.nomeResponsavel,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.cpfResponsavelController,
              label: AppStrings.cpfResponsavel,
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [controller.cpfResponsavelMask],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.obrigatorio;
                }
                if (value.replaceAll(RegExp(r'\D'), '').length != 11) {
                  return AppStrings.cpfResponsavelInvalido;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: controller.cargoSelecionado,
              decoration: InputDecoration(
                labelText: AppStrings.cargoResponsavel,
                prefixIcon: const Icon(Icons.work_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: controller.cargos
                  .map(
                    (cargo) =>
                        DropdownMenuItem(value: cargo, child: Text(cargo)),
                  )
                  .toList(),
              onChanged: controller.setCargo,
              validator: (_) => controller.cargoSelecionado == null
                  ? AppStrings.informeCargo
                  : null,
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
                    onPressed: () => controller.nextPage(controller.formKey3),
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
