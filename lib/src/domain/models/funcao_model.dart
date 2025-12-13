class Funcao {
  final String nome;
  final String descricao;

  Funcao({
    required this.nome,
    required this.descricao,
  });
}

class FuncoesRepository {
  static List<Funcao> getFuncoes() {
    return [
      Funcao(
        nome: 'Administrador',
        descricao: 'Gerencia toda a plataforma, cria novos usuários e tem acesso irrestrito aos relatórios financeiros sensíveis.',
      ),
      Funcao(
        nome: 'Secretaria',
        descricao: 'Foca no cadastro e atualização de dados dos dizimistas, além de lançar contribuições do dia a dia.',
      ),
      Funcao(
        nome: 'Financeiro',
        descricao: 'Visualiza fluxo de caixa, emite relatórios para contabilidade e analisa a saúde financeira da paróquia.',
      ),
    ];
  }
}