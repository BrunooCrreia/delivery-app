import 'package:flutter/material.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/register_entregador/register_entregador_controller.dart';
import 'package:projeto_perguntas/screens/widgets/register_field.dart';
import 'package:projeto_perguntas/screens/widgets/register_section_title.dart';

class Step6Bancario extends StatelessWidget {
  const Step6Bancario({super.key, required this.controller});

  final RegisterEntregadorController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.formKey6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RegisterSectionTitle(title: AppStrings.dadosBancarios),
            const SizedBox(height: 4),
            const Text(AppStrings.etapaEntregador6),
            const SizedBox(height: 20),
            RegisterField(
              controller: controller.bancoController,
              label: AppStrings.banco,
              icon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RegisterField(
                    controller: controller.agenciaController,
                    label: AppStrings.agencia,
                    icon: Icons.account_tree_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RegisterField(
                    controller: controller.contaController,
                    label: AppStrings.conta,
                    icon: Icons.confirmation_number_outlined,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.chavePixController,
              label: AppStrings.chavePix,
              icon: Icons.pix_outlined,
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.cpfTitularController,
              label: AppStrings.cpfTitularConta,
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [controller.cpfMask],
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeCpfTitular;
                }
                final digits = value.replaceAll(RegExp(r'\D'), '');
                if (digits.length != 11) {
                  return AppStrings.cpfIncompleto;
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
                    onPressed: () => controller.nextPage(controller.formKey6),
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
