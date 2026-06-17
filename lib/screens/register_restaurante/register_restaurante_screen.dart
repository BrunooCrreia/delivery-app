import 'package:flutter/material.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/register_restaurante/register_restaurante_controller.dart';
import 'package:projeto_perguntas/screens/register_restaurante/steps/step1_conta.dart';
import 'package:projeto_perguntas/screens/register_restaurante/steps/step2_restaurante.dart';
import 'package:projeto_perguntas/screens/register_restaurante/steps/step3_responsavel.dart';
import 'package:projeto_perguntas/screens/register_restaurante/steps/step3_endereco.dart';
import 'package:projeto_perguntas/screens/register_restaurante/steps/step5_operacional.dart';
import 'package:projeto_perguntas/screens/widgets/register_progress_bar.dart';

class RegisterRestauranteScreen extends StatefulWidget {
  const RegisterRestauranteScreen({super.key});

  @override
  State<RegisterRestauranteScreen> createState() =>
      _RegisterRestauranteScreenState();
}

class _RegisterRestauranteScreenState extends State<RegisterRestauranteScreen> {
  late final RegisterRestauranteController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RegisterRestauranteController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.cadastroRestaurante),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: RegisterProgressBar(
                currentPage: _controller.currentPage,
                totalPages: 5,
              ),
            ),
          ),
          body: PageView(
            controller: _controller.pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: _controller.setCurrentPage,
            children: [
              Step1Conta(controller: _controller),
              Step2Restaurante(controller: _controller),
              Step3Responsavel(controller: _controller),
              Step3Endereco(controller: _controller),
              Step5Operacional(controller: _controller),
            ],
          ),
        );
      },
    );
  }
}
