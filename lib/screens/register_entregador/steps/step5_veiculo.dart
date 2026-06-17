import 'package:flutter/material.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/register_entregador/register_entregador_controller.dart';
import 'package:projeto_perguntas/screens/widgets/register_field.dart';
import 'package:projeto_perguntas/screens/widgets/register_section_title.dart';

class Step5Veiculo extends StatelessWidget {
  const Step5Veiculo({super.key, required this.controller});

  final RegisterEntregadorController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.formKey5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RegisterSectionTitle(title: AppStrings.veiculoDeTrabalho),
            const SizedBox(height: 4),
            const Text(AppStrings.etapaEntregador5),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: controller.tipoVeiculoSelecionado,
              decoration: InputDecoration(
                labelText: AppStrings.tipoVeiculo,
                prefixIcon: const Icon(Icons.two_wheeler_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: controller.tiposVeiculo
                  .map(
                    (tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)),
                  )
                  .toList(),
              onChanged: controller.setTipoVeiculo,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.selecioneVeiculoTipo;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.marcaModeloController,
              label: AppStrings.marcaEModelo,
              icon: Icons.directions_car_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeMarcaModelo;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RegisterField(
                    controller: controller.anoVeiculoController,
                    label: AppStrings.ano,
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.informeAno;
                      }
                      final digits = value.replaceAll(RegExp(r'\D'), '');
                      if (digits.length != 4) {
                        return AppStrings.anoInvalido;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RegisterField(
                    controller: controller.placaController,
                    label: AppStrings.placa,
                    icon: Icons.pin_outlined,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.informePlaca;
                      }
                      final cleaned = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                      if (cleaned.length < 7) {
                        return AppStrings.placaInvalida;
                      }
                      return null;
                    },
                  ),
                ),
              ],
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
                    onPressed: () => controller.nextPage(controller.formKey5),
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
