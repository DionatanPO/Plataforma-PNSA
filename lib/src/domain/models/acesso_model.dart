class Acesso {
  final String id;
  final String nome;
  final String email;
  final String cpf;
  final String telefone;
  final String endereco;
  final String funcao;
  final String status;
  final DateTime ultimoAcesso;
  final bool pendencia;

  Acesso({
    required this.id,
    required this.nome,
    required this.email,
    required this.cpf,
    required this.telefone,
    required this.endereco,
    required this.funcao,
    required this.status,
    required this.ultimoAcesso,
    required this.pendencia,
  });

  Acesso copyWith({
    String? id,
    String? nome,
    String? email,
    String? cpf,
    String? telefone,
    String? endereco,
    String? funcao,
    String? status,
    DateTime? ultimoAcesso,
    bool? pendencia,
  }) {
    return Acesso(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
      funcao: funcao ?? this.funcao,
      status: status ?? this.status,
      ultimoAcesso: ultimoAcesso ?? this.ultimoAcesso,
      pendencia: pendencia ?? this.pendencia,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'endereco': endereco,
      'funcao': funcao,
      'status': status,
      'ultimoAcesso': ultimoAcesso.millisecondsSinceEpoch,
      'pendencia': pendencia,
    };
  }

  factory Acesso.fromMap(Map<String, dynamic> map) {
    return Acesso(
      id: map['id']?.toString() ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
      telefone: map['telefone'] ?? '',
      endereco: map['endereco'] ?? '',
      funcao: map['funcao'] ?? '',
      status: map['status'] ?? '',
      ultimoAcesso: DateTime.fromMillisecondsSinceEpoch(map['ultimoAcesso'] ?? 0),
      pendencia: map['pendencia'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Acesso(id: $id, nome: $nome, email: $email, cpf: $cpf, telefone: $telefone, endereco: $endereco, funcao: $funcao, status: $status, ultimoAcesso: $ultimoAcesso, pendencia: $pendencia)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Acesso &&
           other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}