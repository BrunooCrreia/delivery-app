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
            const RegisterSectionTitle(title: 'Veiculo de trabalho'),
            const SizedBox(height: 4),
            const Text('Etapa 5 de 7'),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: controller.tipoVeiculoSelecionado,
              decoration: InputDecoration(
                labelText: 'Tipo de veiculo',
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
                  return 'Selecione o tipo do veiculo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.marcaModeloController,
              label: 'Marca e modelo',
              icon: Icons.directions_car_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a marca e modelo';
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
                    label: 'Ano',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o ano';
                      }
                      final digits = value.replaceAll(RegExp(r'\D'), '');
                      if (digits.length != 4) {
                        return 'Ano invalido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RegisterField(
                    controller: controller.placaController,
                    label: 'Placa',
                    icon: Icons.pin_outlined,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a placa';
                      }
                      final cleaned = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                      if (cleaned.length < 7) {
                        return 'Placa invalida';
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
