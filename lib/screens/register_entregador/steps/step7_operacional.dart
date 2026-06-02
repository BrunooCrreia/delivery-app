import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/register_entregador/register_entregador_controller.dart';
import 'package:projeto_perguntas/screens/widgets/register_error.dart';
import 'package:projeto_perguntas/screens/widgets/register_field.dart';
import 'package:projeto_perguntas/screens/widgets/register_section_title.dart';
import 'package:projeto_perguntas/screens/widgets/termos_entregador_texto.dart';

class Step7Operacional extends StatelessWidget {
  const Step7Operacional({super.key, required this.controller});

  final RegisterEntregadorController controller;

  void _showTermos(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,

      builder: (context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SingleChildScrollView(child: TermosEntregadorTexto()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.formKey7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RegisterSectionTitle(title: 'Dados operacionais'),
            const SizedBox(height: 4),
            const Text('Etapa 7 de 7'),
            const SizedBox(height: 20),
            RegisterField(
              controller: controller.regiaoAtuacaoController,
              label: 'Regiao de atuacao',
              icon: Icons.public_outlined,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.horariosDisponiveisController,
              label: 'Horarios disponiveis',
              icon: Icons.schedule_outlined,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: controller.possuiMeiSelecionado,
              decoration: InputDecoration(
                labelText: 'Possui MEI?',
                prefixIcon: const Icon(Icons.business_center_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: controller.opcoesPossuiMei
                  .map(
                    (opcao) =>
                        DropdownMenuItem(value: opcao, child: Text(opcao)),
                  )
                  .toList(),
              onChanged: controller.setPossuiMei,
            ),
            if (controller.possuiMeiSelecionado == 'Sim') ...[
              const SizedBox(height: 16),
              RegisterField(
                controller: controller.meiCnpjController,
                label: 'CNPJ do MEI',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(14),
                ],
                validator: (value) {
                  if (controller.possuiMeiSelecionado != 'Sim') {
                    return null;
                  }
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o CNPJ do MEI';
                  }
                  if (value.replaceAll(RegExp(r'\D'), '').length != 14) {
                    return 'CNPJ invalido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              RegisterField(
                controller: controller.meiNomeEmpresaController,
                label: 'Nome empresarial do MEI',
                icon: Icons.business_outlined,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (controller.possuiMeiSelecionado != 'Sim') {
                    return null;
                  }
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome empresarial';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: controller.aceitouTermos,
              onChanged: (value) => controller.setAceitouTermos(value ?? false),
              title: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(AppStrings.liEAceito),
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () => _showTermos(context),
                    child: const Text(AppStrings.termosUso),
                  ),
                ],
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (controller.errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              RegisterError(message: controller.errorMessage),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.isLoading
                        ? null
                        : controller.prevPage,
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
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(AppStrings.criarConta),
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
