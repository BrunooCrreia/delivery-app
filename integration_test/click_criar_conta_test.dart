import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('clica em Criar conta e abre selecao de tipo', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    SharedPreferences.setMockInitialValues({});

    app.main();
    await tester.pumpAndSettle();

    final criarContaButton = find.text(AppStrings.criarConta);
    expect(criarContaButton, findsOneWidget);

    await tester.tap(criarContaButton);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.criarConta), findsOneWidget);
    expect(find.text('Entregador'), findsOneWidget);
    expect(find.text('Restaurante'), findsOneWidget);

    await tester.tap(find.text('Restaurante'));
    await tester.pumpAndSettle(const Duration(seconds: 4));

    final nomeField = find.widgetWithText(
      TextFormField,
      AppStrings.nomeRestaurante,
    );
    await tester.tap(nomeField);
    await tester.pumpAndSettle();
    await tester.enterText(nomeField, 'Nome de Teste');
    await tester.pumpAndSettle();

    final emailField = find.widgetWithText(TextFormField, AppStrings.email);
    await tester.tap(emailField);
    await tester.pumpAndSettle();
    await tester.enterText(emailField, 'teste@email.com');
    await tester.pumpAndSettle();

    final senhaField = find.widgetWithText(TextFormField, AppStrings.senha);
    await tester.tap(senhaField);
    await tester.pumpAndSettle();
    await tester.enterText(senhaField, '123456');
    await tester.pumpAndSettle();

    final confirmarSenhaField = find.widgetWithText(
      TextFormField,
      AppStrings.confirmarSenha,
    );
    await tester.tap(confirmarSenhaField);
    await tester.pumpAndSettle();
    await tester.enterText(confirmarSenhaField, '123456');
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.proximo));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // ── Etapa 2 — Dados do restaurante ───────────────────────────────────
    expect(find.text(AppStrings.etapa2de3), findsOneWidget);

    final cpfCnpjField = find.widgetWithText(TextFormField, AppStrings.cpfCnpj);
    await tester.tap(cpfCnpjField);
    await tester.pumpAndSettle();
    await tester.enterText(cpfCnpjField, '12345678000199');
    await tester.pumpAndSettle();

    final taxaField = find.widgetWithText(
      TextFormField,
      AppStrings.taxaEntrega,
    );
    await tester.tap(taxaField);
    await tester.pumpAndSettle();
    await tester.enterText(taxaField, '5.99');
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.proximo));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // ── Etapa 3 — Endereço + Localização ─────────────────────────────────
    expect(find.text(AppStrings.etapa3de3), findsOneWidget);

    // CEP: digita e aguarda debounce (450ms) + retorno da API
    final cepField = find.widgetWithText(TextFormField, AppStrings.cep);
    await tester.tap(cepField);
    await tester.pumpAndSettle();
    await tester.enterText(cepField, '08450560');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Número não é preenchido pela API — preenche manualmente
    final numeroField = find.widgetWithText(TextFormField, AppStrings.numero);
    await tester.tap(numeroField);
    await tester.pumpAndSettle();
    await tester.enterText(numeroField, '1578');
    await tester.pumpAndSettle();

    // Localização
    final latField = find.widgetWithText(TextFormField, AppStrings.latitude);
    await tester.tap(latField);
    await tester.pumpAndSettle();
    await tester.enterText(latField, '-23.5630');
    await tester.pumpAndSettle();

    final lngField = find.widgetWithText(TextFormField, AppStrings.longitude);
    await tester.tap(lngField);
    await tester.pumpAndSettle();
    await tester.enterText(lngField, '-46.6543');
    await tester.pumpAndSettle();

    // Finaliza cadastro
    final btnCadastrar = find.text(AppStrings.cadastrarRestaurante);
    expect(btnCadastrar, findsOneWidget);
    await tester.tap(btnCadastrar);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(
      find.text(AppStrings.restauranteCadastrado).evaluate().isNotEmpty ||
          find.text('Home').evaluate().isNotEmpty,
      isTrue,
      reason:
          'Cadastro não concluído: SnackBar de sucesso ou tela Home não encontrados',
    );
  });
}
