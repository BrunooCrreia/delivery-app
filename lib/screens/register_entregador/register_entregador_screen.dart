import 'package:flutter/material.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/register_entregador/register_entregador_controller.dart';
import 'package:projeto_perguntas/screens/register_entregador/steps/step1_conta.dart';
import 'package:projeto_perguntas/screens/register_entregador/steps/step2_acesso.dart';
import 'package:projeto_perguntas/screens/register_entregador/steps/step3_endereco.dart';
import 'package:projeto_perguntas/screens/widgets/register_progress_bar.dart';

class RegisterEntregadorScreen extends StatefulWidget {
  const RegisterEntregadorScreen({super.key});

  @override
  State<RegisterEntregadorScreen> createState() =>
      _RegisterEntregadorScreenState();
}

class _RegisterEntregadorScreenState extends State<RegisterEntregadorScreen> {
  late final RegisterEntregadorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RegisterEntregadorController();
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
            title: const Text(AppStrings.cadastroEntregador),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: RegisterProgressBar(
                currentPage: _controller.currentPage,
                totalPages: 3,
              ),
            ),
          ),
          body: PageView(
            controller: _controller.pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: _controller.setCurrentPage,
            children: [
              Step1Conta(controller: _controller),
              Step2Acesso(controller: _controller),
              Step3Endereco(controller: _controller),
            ],
          ),
        );
      },
    );
  }
}
