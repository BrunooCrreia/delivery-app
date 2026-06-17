import 'package:flutter/material.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/register_restaurante/register_restaurante_controller.dart';
import 'package:projeto_perguntas/screens/widgets/register_error.dart';
import 'package:projeto_perguntas/screens/widgets/register_section_title.dart';

class Step5Operacional extends StatelessWidget {
  const Step5Operacional({super.key, required this.controller});

  final RegisterRestauranteController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RegisterSectionTitle(
            title: AppStrings.dadosOperacional,
            useMedium: true,
          ),
          const SizedBox(height: 4),
          const Text(AppStrings.etapa5de7),
          const SizedBox(height: 24),

          // ── Dias de funcionamento ──────────────────────────────────────────
          Text(
            AppStrings.diasFuncionamento,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: RegisterRestauranteController.allDias.map((dia) {
              final selected = controller.diasSelecionados.contains(dia);
              return FilterChip(
                label: Text(dia),
                selected: selected,
                onSelected: (_) => controller.toggleDia(dia),
                selectedColor: colorScheme.primaryContainer,
                checkmarkColor: colorScheme.onPrimaryContainer,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── Horário de funcionamento ───────────────────────────────────────
          Text(
            AppStrings.horarioFuncionamento,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      controller.selectHorarioAbertura(context),
                  icon: const Icon(Icons.schedule_outlined, size: 18),
                  label: Text(
                    controller.horarioAbertura != null
                        ? controller.horarioAbertura!.format(context)
                        : AppStrings.horarioAbertura,
                    style: TextStyle(
                      color: controller.horarioAbertura != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      controller.selectHorarioFechamento(context),
                  icon: const Icon(Icons.schedule_outlined, size: 18),
                  label: Text(
                    controller.horarioFechamento != null
                        ? controller.horarioFechamento!.format(context)
                        : AppStrings.horarioFechamento,
                    style: TextStyle(
                      color: controller.horarioFechamento != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Raio máximo de entrega ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.raioEntrega,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.raioEntregaKm.round()} km',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: controller.raioEntregaKm,
            min: 1,
            max: 50,
            divisions: 49,
            onChanged: controller.setRaioEntrega,
          ),
          const SizedBox(height: 16),

          // ── Tipos de veículo aceitos ───────────────────────────────────────
          Text(
            AppStrings.veiculosAceitos,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: RegisterRestauranteController.allVeiculos.map((v) {
              final selected = controller.veiculosSelecionados.contains(v);
              return FilterChip(
                label: Text(v),
                selected: selected,
                onSelected: (_) => controller.toggleVeiculo(v),
                selectedColor: colorScheme.primaryContainer,
                checkmarkColor: colorScheme.onPrimaryContainer,
              );
            }).toList(),
          ),
          if (controller.errorMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            RegisterError(message: controller.errorMessage),
          ],
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      controller.isLoading ? null : controller.prevPage,
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
                      : () => controller.nextStep5(context),
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
    );
  }
}
