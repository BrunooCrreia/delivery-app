import 'package:flutter/material.dart';

class TermosEntregadorTexto extends StatelessWidget {
  const TermosEntregadorTexto({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Theme.of(context).colorScheme.onSurface,
    );
    const bodyStyle = TextStyle(fontSize: 13, height: 1.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TERMO DE CONDIÇÕES DE USO', style: titleStyle),
        const SizedBox(height: 16),
        Text('1. OBJETO', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          '1.1. O presente Termo de Condições de Uso regula a intermediação da TRANS DELIVERY LTDA, doravante denominada INTERMEDIADORA, em relação aos ESTABELECIMENTOS PARCEIROS e os ENTREGADORES cadastrados no banco de dados da INTERMEDIADORA.',
          style: bodyStyle,
        ),
        const SizedBox(height: 8),
        const Text(
          '1.2. A INTERMEDIADORA é uma empresa de administração logística que atua como agente/intermediário entre os ESTABELECIMENTOS que desejam vender os seus produtos aos CLIENTES FINAIS.',
          style: bodyStyle,
        ),
        const SizedBox(height: 8),
        const Text(
          '1.3. A aceitação plena e integral deste termo de uso é condição indispensável para efetivação da prestação de serviços ora pactuada.',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),
        Text('2. ACEITAÇÃO DOS TERMOS E CONDIÇÕES', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          '2.1. O ENTREGADOR declara que leu, compreendeu e aceita integralmente as disposições deste Termo. O não cumprimento pode resultar na suspensão ou exclusão do ENTREGADOR do banco de dados da INTERMEDIADORA.',
          style: bodyStyle,
        ),
        const SizedBox(height: 8),
        const Text(
          '2.2. A INTERMEDIADORA poderá alterar, a qualquer tempo, as condições deste Termo, sendo as modificações publicadas no aplicativo.',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),
        Text('3. DA UTILIZAÇÃO DA PLATAFORMA', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          '3.1. O ENTREGADOR tem o direito de acessar e utilizar a plataforma para realizar entregas de mercadorias, conforme as condições descritas neste Termo.\n\n'
          '3.2. O ENTREGADOR deverá manter seu cadastro e seus dados atualizados.',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),
        Text('4. DAS RESPONSABILIDADES DO ENTREGADOR', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          '(i) Cumprir rigorosamente as normas de trânsito e as leis aplicáveis.\n'
          '(ii) Manter sua CNH válida e compatível com a categoria exigida.\n'
          '(iii) Garantir que seu veículo esteja devidamente licenciado.\n'
          '(iv) Utilizar equipamentos de segurança como capacete e vestuário adequado.\n'
          '(v) Garantir que a mercadoria esteja devidamente acondicionada.\n'
          '(vi) Realizar a entrega no prazo estimado pelo ESTABELECIMENTO.\n'
          '(vii) Atuar de forma profissional, ética, cortês e respeitosa.\n'
          '(viii) Obedecer às instruções de entrega fornecidas pelos ESTABELECIMENTOS.',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),
        Text('5. POLÍTICA DE OCORRÊNCIAS OPERACIONAIS', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          '5.1. Na hipótese de o cliente não ser localizado, o ENTREGADOR deverá entrar em contato com o ESTABELECIMENTO e aguardar até 10 (dez) minutos. Persistindo a impossibilidade, deverá retornar o pedido à loja.',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),
        Text('6. REMUNERAÇÃO E PAGAMENTOS', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          '6.1. A INTERMEDIADORA realizará o pagamento ao ENTREGADOR pelas entregas realizadas, de acordo com o valor estabelecido para cada serviço prestado.\n\n'
          '6.2. Os valores poderão ser compostos por um valor fixo pelo dia de trabalho, podendo ser acrescido de taxas de entrega variáveis.\n\n'
          '6.4. O pagamento será efetuado na conta bancária informada pelo ENTREGADOR, de acordo com o ciclo de pagamento estabelecido pela INTERMEDIADORA.',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),
        Text('7. AUTONOMIA DO ENTREGADOR', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          '7.1. O ENTREGADOR confirma que não há qualquer relação de hierarquia, dependência ou subordinação trabalhista com a INTERMEDIADORA.\n\n'
          '7.2. Os ENTREGADORES são livres para realizarem as entregas quando, como e onde quiserem.\n\n'
          '7.3. O ENTREGADOR poderá prestar serviços por meio de outras plataformas simultaneamente, não havendo exclusividade entre as Partes.',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),
        Text('11. PRIVACIDADE E PROTEÇÃO DE DADOS', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          '11.1. A INTERMEDIADORA se compromete a tratar os dados pessoais do ENTREGADOR em conformidade com a LGPD (Lei nº 13.709/2018), garantindo que os dados serão coletados e processados para fins de cadastro, execução das entregas e pagamentos.',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),
        Text('14. DA AUSÊNCIA DE VÍNCULO EMPREGATÍCIO', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          '14.1. O ENTREGADOR reconhece que está atuando de maneira autônoma e independente, sem vínculo de subordinação com a INTERMEDIADORA.\n\n'
          '14.2. Este TERMO DE USO não cria, sob qualquer hipótese, qualquer vínculo trabalhista ou relação de emprego.',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),
        Text('23. DISPOSIÇÕES FINAIS', style: titleStyle),
        const SizedBox(height: 8),
        const Text(
          '23.4. As partes elegem o foro central da Comarca da Sede da INTERMEDIADORA como único e competente para dirimir quaisquer questões oriundas do presente contrato.',
          style: bodyStyle,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
