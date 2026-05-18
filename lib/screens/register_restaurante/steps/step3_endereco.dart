import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/register_restaurante/register_restaurante_controller.dart';
import 'package:projeto_perguntas/screens/widgets/register_error.dart';
import 'package:projeto_perguntas/screens/widgets/register_field.dart';
import 'package:projeto_perguntas/screens/widgets/register_section_title.dart';

class Step3Endereco extends StatelessWidget {
  const Step3Endereco({super.key, required this.controller});

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
              title: AppStrings.endereco,
              useMedium: true,
            ),
            const SizedBox(height: 4),
            const Text(AppStrings.etapa3de3),
            const SizedBox(height: 20),
            RegisterField(
              controller: controller.enderecoController,
              label: AppStrings.endereco,
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
                  Text('Buscando endereco pelo CEP...'),
                ],
              ),
            ],
            const SizedBox(height: 28),
            const RegisterSectionTitle(
              title: AppStrings.localizacao,
              useMedium: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RegisterField(
                    controller: controller.latitudeController,
                    label: AppStrings.latitude,
                    icon: Icons.my_location_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.obrigatorio;
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return AppStrings.invalido;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RegisterField(
                    controller: controller.longitudeController,
                    label: AppStrings.longitude,
                    icon: Icons.my_location_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.obrigatorio;
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return AppStrings.invalido;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            if (controller.errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              RegisterError(message: controller.errorMessage),
            ],
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
                    onPressed: controller.isLoading
                        ? null
                        : () => controller.handleRegister(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: controller.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(AppStrings.cadastrarRestaurante),
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
