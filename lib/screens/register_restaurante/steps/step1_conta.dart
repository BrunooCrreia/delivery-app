import 'package:flutter/material.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/register_restaurante/register_restaurante_controller.dart';
import 'package:projeto_perguntas/screens/widgets/register_field.dart';
import 'package:projeto_perguntas/screens/widgets/register_section_title.dart';

class Step1Conta extends StatelessWidget {
  const Step1Conta({super.key, required this.controller});

  final RegisterRestauranteController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RegisterSectionTitle(
              title: AppStrings.dadosConta,
              useMedium: true,
            ),
            const SizedBox(height: 4),
            const Text(AppStrings.etapa1de3),
            const SizedBox(height: 20),
            RegisterField(
              controller: controller.nomeController,
              label: AppStrings.nomeRestaurante,
              icon: Icons.storefront_outlined,
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.emailController,
              label: AppStrings.email,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeEmail;
                }
                if (!value.contains('@')) {
                  return AppStrings.emailInvalido;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),
            RegisterField(
              controller: controller.passwordController,
              label: AppStrings.senha,
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.informeSenha;
                }
                if (value.length < 6) {
                  return AppStrings.minimo6Caracteres;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.confirmPasswordController,
              label: AppStrings.confirmarSenha,
              icon: Icons.lock_outline,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.confirmeSenha;
                }
                if (value != controller.passwordController.text) {
                  return AppStrings.senhasNaoConferem;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: controller.telefoneController,
              label: AppStrings.telefone,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeTelefone;
                }
                final digits = value.replaceAll(RegExp(r'\D'), '');
                if (digits.length < 10 || digits.length > 11) {
                  return AppStrings.telefoneInvalido;
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => controller.nextPage(controller.formKey1),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(AppStrings.proximo),
            ),
          ],
        ),
      ),
    );
  }
}
