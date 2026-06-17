import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AppFormatters {
  AppFormatters._();

  static MaskTextInputFormatter cpf() => MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  static MaskTextInputFormatter cnpj() => MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  static MaskTextInputFormatter telefone() => MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  static MaskTextInputFormatter data() => MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {'#': RegExp(r'[0-9]')},
  );
}
