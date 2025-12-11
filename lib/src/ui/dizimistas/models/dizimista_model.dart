class Dizimista {
  final int id;
  final String nome;
  final String cpf;
  final String telefone;
  final String email;
  final String status;
  final String endereco;
  final String cidade;
  final String estado;
  final DateTime dataRegistro;

  Dizimista({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.status,
    required this.endereco,
    required this.cidade,
    required this.estado,
    required this.dataRegistro,
  });

  Dizimista copyWith({
    int? id,
    String? nome,
    String? cpf,
    String? telefone,
    String? email,
    String? status,
    String? endereco,
    String? cidade,
    String? estado,
    DateTime? dataRegistro,
  }) {
    return Dizimista(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cpf: cpf ?? this.cpf,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      status: status ?? this.status,
      endereco: endereco ?? this.endereco,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      dataRegistro: dataRegistro ?? this.dataRegistro,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
      'status': status,
      'endereco': endereco,
      'cidade': cidade,
      'estado': estado,
      'data_registro': dataRegistro.millisecondsSinceEpoch,
    };
  }

  factory Dizimista.fromMap(Map<String, dynamic> map) {
    return Dizimista(
      id: map['id']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
      cpf: map['cpf'] ?? '',
      telefone: map['telefone'] ?? '',
      email: map['email'] ?? '',
      status: map['status'] ?? '',
      endereco: map['endereco'] ?? '',
      cidade: map['cidade'] ?? '',
      estado: map['estado'] ?? '',
      dataRegistro: DateTime.fromMillisecondsSinceEpoch(map['data_registro'] ?? 0),
    );
  }

  @override
  String toString() {
    return 'Dizimista(id: $id, nome: $nome, cpf: $cpf, telefone: $telefone, email: $email, status: $status, endereco: $endereco, cidade: $cidade, estado: $estado, dataRegistro: $dataRegistro)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Dizimista &&
           other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}