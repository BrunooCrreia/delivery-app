import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/widgets/register_field.dart';
import 'package:projeto_perguntas/screens/widgets/register_section_title.dart';

/// Interface que qualquer controller de endereço deve implementar.
/// Permite que o widget compartilhado [RegisterAddressStep] funcione com
/// tanto [RegisterEntregadorController] quanto [RegisterRestauranteController].
abstract class IAddressStepController {
  GlobalKey<FormState> get addressFormKey;
  TextEditingController get enderecoController;
  TextEditingController get bairroController;
  TextEditingController get numeroController;
  TextEditingController get complementoController;
  TextEditingController get cidadeController;
  TextEditingController get estadoController;
  TextEditingController get cepController;
  bool get isCepLoading;
  bool get highlightNumeroField;
  void onCepChanged(String value, BuildContext context);
  void prevPage();
  void nextPage(GlobalKey<FormState> formKey);
}

/// Tela de endereço reutilizável para qualquer fluxo de cadastro.
/// Recebe [title] e [etapaLabel] para personalizar o cabeçalho.
class RegisterAddressStep extends StatelessWidget {
  const RegisterAddressStep({
    super.key,
    required this.controller,
    required this.title,
    required this.etapaLabel,
  });

  final IAddressStepController controller;
  final String title;
  final String etapaLabel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.addressFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RegisterSectionTitle(title: title, useMedium: true),
            const SizedBox(height: 4),
            Text(etapaLabel),
            const SizedBox(height: 20),

            // ── CEP (preenche os campos abaixo automaticamente) ──────────────
            if (controller.isCepLoading) ...[
              const SizedBox(height: 10),
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(AppStrings.buscandoCep),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // ── Endereço (rua) ───────────────────────────────────────────────
            RegisterField(
              controller: controller.enderecoController,
              label: AppStrings.endereco,
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),

            // ── Bairro + Número ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: RegisterField(
                    controller: controller.bairroController,
                    label: AppStrings.bairro,
                    icon: Icons.map_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: controller.highlightNumeroField
                            ? Colors.red
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: RegisterField(
                      controller: controller.numeroController,
                      label: AppStrings.numero,
                      icon: Icons.tag,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Complemento (opcional) ───────────────────────────────────────
            RegisterField(
              controller: controller.complementoController,
              label: AppStrings.complemento,
              icon: Icons.add_location_alt_outlined,
              defaultErrorMessage: null,
              validator: (_) => null,
            ),
            const SizedBox(height: 16),

            // ── Cidade + Estado ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: RegisterField(
                    controller: controller.cidadeController,
                    label: AppStrings.cidade,
                    icon: Icons.location_city_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RegisterField(
                    controller: controller.estadoController,
                    label: AppStrings.estado,
                    icon: Icons.flag_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            RegisterField(
              controller: controller.cepController,
              label: AppStrings.cep,
              icon: Icons.markunread_mailbox_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              onChanged: (value) => controller.onCepChanged(value, context),
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
                    onPressed: () =>
                        controller.nextPage(controller.addressFormKey),
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
