class Dizimista {
  final int id;
  final String numeroRegistro;
  final String nome;
  final String cpf;
  final DateTime? dataNascimento;
  final String? sexo;
  final String telefone;
  final String? email;
  final String? rua;
  final String? numero;
  final String? bairro;
  final String cidade;
  final String estado;
  final String? cep;
  final String? estadoCivil;
  final String? nomeConjugue;
  final DateTime? dataCasamento;
  final DateTime? dataNascimentoConjugue;
  final String? observacoes;
  final bool consentimento;
  final String status;
  final DateTime dataRegistro;

  Dizimista({
    required this.id,
    required this.numeroRegistro,
    required this.nome,
    required this.cpf,
    this.dataNascimento,
    this.sexo,
    required this.telefone,
    this.email,
    this.rua,
    this.numero,
    this.bairro,
    required this.cidade,
    required this.estado,
    this.cep,
    this.estadoCivil,
    this.nomeConjugue,
    this.dataCasamento,
    this.dataNascimentoConjugue,
    this.observacoes,
    required this.consentimento,
    required this.status,
    required this.dataRegistro,
  });

  Dizimista copyWith({
    int? id,
    String? numeroRegistro,
    String? nome,
    String? cpf,
    DateTime? dataNascimento,
    String? sexo,
    String? telefone,
    String? email,
    String? rua,
    String? numero,
    String? bairro,
    String? cidade,
    String? estado,
    String? cep,
    String? estadoCivil,
    String? nomeConjugue,
    DateTime? dataCasamento,
    DateTime? dataNascimentoConjugue,
    String? observacoes,
    bool? consentimento,
    String? status,
    DateTime? dataRegistro,
  }) {
    return Dizimista(
      id: id ?? this.id,
      numeroRegistro: numeroRegistro ?? this.numeroRegistro,
      nome: nome ?? this.nome,
      cpf: cpf ?? this.cpf,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      sexo: sexo ?? this.sexo,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      rua: rua ?? this.rua,
      numero: numero ?? this.numero,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      cep: cep ?? this.cep,
      estadoCivil: estadoCivil ?? this.estadoCivil,
      nomeConjugue: nomeConjugue ?? this.nomeConjugue,
      dataCasamento: dataCasamento ?? this.dataCasamento,
      dataNascimentoConjugue: dataNascimentoConjugue ?? this.dataNascimentoConjugue,
      observacoes: observacoes ?? this.observacoes,
      consentimento: consentimento ?? this.consentimento,
      status: status ?? this.status,
      dataRegistro: dataRegistro ?? this.dataRegistro,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero_registro': numeroRegistro,
      'nome': nome,
      'cpf': cpf,
      'data_nascimento': dataNascimento?.millisecondsSinceEpoch,
      'sexo': sexo,
      'telefone': telefone,
      'email': email,
      'rua': rua,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'estado_civil': estadoCivil,
      'nome_conjugue': nomeConjugue,
      'data_casamento': dataCasamento?.millisecondsSinceEpoch,
      'data_nascimento_conjugue': dataNascimentoConjugue?.millisecondsSinceEpoch,
      'observacoes': observacoes,
      'consentimento': consentimento,
      'status': status,
      'data_registro': dataRegistro.millisecondsSinceEpoch,
    };
  }

  factory Dizimista.fromMap(Map<String, dynamic> map) {
    return Dizimista(
      id: map['id']?.toInt() ?? 0,
      numeroRegistro: map['numero_registro'] ?? '',
      nome: map['nome'] ?? '',
      cpf: map['cpf'] ?? '',
      dataNascimento: map['data_nascimento'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['data_nascimento'])
          : null,
      sexo: map['sexo'],
      telefone: map['telefone'] ?? '',
      email: map['email'],
      rua: map['rua'],
      numero: map['numero'],
      bairro: map['bairro'],
      cidade: map['cidade'] ?? '',
      estado: map['estado'] ?? '',
      cep: map['cep'],
      estadoCivil: map['estado_civil'],
      nomeConjugue: map['nome_conjugue'],
      dataCasamento: map['data_casamento'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['data_casamento'])
          : null,
      dataNascimentoConjugue: map['data_nascimento_conjugue'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['data_nascimento_conjugue'])
          : null,
      observacoes: map['observacoes'],
      consentimento: map['consentimento'] ?? false,
      status: map['status'] ?? '',
      dataRegistro: DateTime.fromMillisecondsSinceEpoch(map['data_registro'] ?? 0),
    );
  }

  @override
  String toString() {
    return 'Dizimista(id: $id, numeroRegistro: $numeroRegistro, nome: $nome, cpf: $cpf, dataNascimento: $dataNascimento, sexo: $sexo, telefone: $telefone, email: $email, rua: $rua, numero: $numero, bairro: $bairro, cidade: $cidade, estado: $estado, cep: $cep, estadoCivil: $estadoCivil, nomeConjugue: $nomeConjugue, dataCasamento: $dataCasamento, dataNascimentoConjugue: $dataNascimentoConjugue, observacoes: $observacoes, consentimento: $consentimento, status: $status, dataRegistro: $dataRegistro)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Dizimista &&
           other.id == id;
  }

  // Computed property to get full address string
  String get endereco {
    final parts = [
      if (rua != null && rua!.isNotEmpty) rua,
      if (numero != null && numero!.isNotEmpty) numero,
      if (bairro != null && bairro!.isNotEmpty) bairro,
      if (cidade.isNotEmpty) cidade,
      if (estado.isNotEmpty) estado,
      if (cep != null && cep!.isNotEmpty) cep,
    ];
    return parts.join(', ');
  }

  @override
  int get hashCode => id.hashCode;
}