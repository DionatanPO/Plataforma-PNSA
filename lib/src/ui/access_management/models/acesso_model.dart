class Acesso {
  final int id;
  final String nome;
  final String email;
  final String funcao;
  final String status;
  final DateTime ultimoAcesso;

  Acesso({
    required this.id,
    required this.nome,
    required this.email,
    required this.funcao,
    required this.status,
    required this.ultimoAcesso,
  });

  Acesso copyWith({
    int? id,
    String? nome,
    String? email,
    String? funcao,
    String? status,
    DateTime? ultimoAcesso,
  }) {
    return Acesso(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      funcao: funcao ?? this.funcao,
      status: status ?? this.status,
      ultimoAcesso: ultimoAcesso ?? this.ultimoAcesso,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'funcao': funcao,
      'status': status,
      'ultimoAcesso': ultimoAcesso.millisecondsSinceEpoch,
    };
  }

  factory Acesso.fromMap(Map<String, dynamic> map) {
    return Acesso(
      id: map['id']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      funcao: map['funcao'] ?? '',
      status: map['status'] ?? '',
      ultimoAcesso: DateTime.fromMillisecondsSinceEpoch(map['ultimoAcesso'] ?? 0),
    );
  }

  @override
  String toString() {
    return 'Acesso(id: $id, nome: $nome, email: $email, funcao: $funcao, status: $status, ultimoAcesso: $ultimoAcesso)';
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