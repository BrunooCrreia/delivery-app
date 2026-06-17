import 'package:flutter/material.dart';
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
      builder: (context) => _TermosBottomSheet(
        onLeuTudo: () => controller.setLeuTermos(true),
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
            const RegisterSectionTitle(title: AppStrings.dadosOperacional),
            const SizedBox(height: 4),
            const Text(AppStrings.etapaEntregador7),
            const SizedBox(height: 20),
            RegisterField(
              controller: controller.regiaoAtuacaoController,
              label: AppStrings.regiaoAtuacao,
              icon: Icons.public_outlined,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.horariosDisponiveisController,
              label: AppStrings.horariosDisponiveis,
              icon: Icons.schedule_outlined,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: controller.possuiMeiSelecionado,
              decoration: InputDecoration(
                labelText: AppStrings.possuiMei,
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
                label: AppStrings.cnpjMei,
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [controller.cnpjMask],
                validator: (value) {
                  if (controller.possuiMeiSelecionado != 'Sim') {
                    return null;
                  }
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.informeCnpjMei;
                  }
                  if (value.replaceAll(RegExp(r'\D'), '').length != 14) {
                    return AppStrings.cnpjInvalido;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              RegisterField(
                controller: controller.meiNomeEmpresaController,
                label: AppStrings.nomeEmpresarialMei,
                icon: Icons.business_outlined,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (controller.possuiMeiSelecionado != 'Sim') {
                    return null;
                  }
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.informeNomeEmpresarial;
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: controller.aceitouTermos,
              onChanged: controller.leuTermos
                  ? (value) => controller.setAceitouTermos(value ?? false)
                  : null,
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
            if (!controller.leuTermos)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  AppStrings.precisaLerTermos,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
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

class _TermosBottomSheet extends StatefulWidget {
  const _TermosBottomSheet({required this.onLeuTudo});

  final VoidCallback onLeuTudo;

  @override
  State<_TermosBottomSheet> createState() => _TermosBottomSheetState();
}

class _TermosBottomSheetState extends State<_TermosBottomSheet> {
  late final ScrollController _scrollController;
  bool _chegouAoFinal = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_chegouAoFinal) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 40) {
      setState(() => _chegouAoFinal = true);
      widget.onLeuTudo();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: const TermosEntregadorTexto(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _chegouAoFinal
                    ? () => Navigator.of(context).pop()
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _chegouAoFinal
                      ? AppStrings.confirmar
                      : AppStrings.roleParaLerTudo,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
