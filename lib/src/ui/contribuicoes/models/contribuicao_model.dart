class ContribuicaoCompetencia {
  final String mesReferencia; // ex: 2024-03
  final double valor;
  final DateTime? dataPagamento;

  ContribuicaoCompetencia({
    required this.mesReferencia,
    required this.valor,
    this.dataPagamento,
  });

  Map<String, dynamic> toMap() {
    return {
      'mesReferencia': mesReferencia,
      'valor': valor,
      'dataPagamento': dataPagamento?.millisecondsSinceEpoch,
    };
  }

  factory ContribuicaoCompetencia.fromMap(Map<String, dynamic> map) {
    return ContribuicaoCompetencia(
      mesReferencia: map['mesReferencia'] ?? '',
      valor: (map['valor'] is int)
          ? (map['valor'] as int).toDouble()
          : map['valor']?.toDouble() ?? 0.0,
      dataPagamento: map['dataPagamento'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dataPagamento'])
          : null,
    );
  }

  @override
  String toString() => '($mesReferencia: R\$ $valor em $dataPagamento)';
}

class Contribuicao {
  final String id;
  final String dizimistaId;
  final String dizimistaNome;
  final String tipo;
  final double valor;
  final String metodo;
  final DateTime dataRegistro;
  final DateTime dataPagamento;
  final String status; // ex: 'Pago', 'A Receber'
  final String usuarioId;
  final String? observacao;
  final List<ContribuicaoCompetencia> competencias;
  final List<String> mesesCompetencia;

  Contribuicao({
    required this.id,
    required this.dizimistaId,
    required this.dizimistaNome,
    required this.tipo,
    required this.valor,
    required this.metodo,
    required this.dataRegistro,
    required this.dataPagamento,
    required this.status,
    required this.usuarioId,
    this.observacao,
    this.competencias = const [],
    this.mesesCompetencia = const [],
  });

  Contribuicao copyWith({
    String? id,
    String? dizimistaId,
    String? dizimistaNome,
    String? tipo,
    double? valor,
    String? metodo,
    DateTime? dataRegistro,
    DateTime? dataPagamento,
    String? status,
    String? usuarioId,
    String? observacao,
    List<ContribuicaoCompetencia>? competencias,
    List<String>? mesesCompetencia,
  }) {
    return Contribuicao(
      id: id ?? this.id,
      dizimistaId: dizimistaId ?? this.dizimistaId,
      dizimistaNome: dizimistaNome ?? this.dizimistaNome,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      metodo: metodo ?? this.metodo,
      dataRegistro: dataRegistro ?? this.dataRegistro,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      status: status ?? this.status,
      usuarioId: usuarioId ?? this.usuarioId,
      observacao: observacao ?? this.observacao,
      competencias: competencias ?? this.competencias,
      mesesCompetencia: mesesCompetencia ?? this.mesesCompetencia,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dizimistaId': dizimistaId,
      'dizimistaNome': dizimistaNome,
      'tipo': tipo,
      'valor': valor,
      'metodo': metodo,
      'dataRegistro': dataRegistro.millisecondsSinceEpoch,
      'dataPagamento': dataPagamento.millisecondsSinceEpoch,
      'status': status,
      'usuarioId': usuarioId,
      'observacao': observacao,
      'competencias': competencias.map((x) => x.toMap()).toList(),
      'mesesCompetencia': mesesCompetencia,
    };
  }

  factory Contribuicao.fromMap(Map<String, dynamic> map) {
    return Contribuicao(
      id: map['id']?.toString() ?? '',
      dizimistaId: map['dizimistaId']?.toString() ?? '',
      dizimistaNome: map['dizimistaNome'] ?? '',
      tipo: map['tipo'] ?? '',
      valor: (map['valor'] is int)
          ? (map['valor'] as int).toDouble()
          : map['valor']?.toDouble() ?? 0.0,
      metodo: map['metodo'] ?? '',
      dataRegistro:
          DateTime.fromMillisecondsSinceEpoch(map['dataRegistro'] ?? 0),
      dataPagamento:
          DateTime.fromMillisecondsSinceEpoch(map['dataPagamento'] ?? 0),
      status: map['status'] ?? 'Pago',
      usuarioId: map['usuarioId'] ?? '',
      observacao: map['observacao'],
      competencias: map['competencias'] != null
          ? List<ContribuicaoCompetencia>.from(map['competencias']
              .map((x) => ContribuicaoCompetencia.fromMap(x)))
          : [],
      mesesCompetencia: map['mesesCompetencia'] != null
          ? List<String>.from(map['mesesCompetencia'])
          : [],
    );
  }

  @override
  String toString() {
    return 'Contribuicao(id: $id, dizimistaId: $dizimistaId, dizimistaNome: $dizimistaNome, tipo: $tipo, valor: $valor, metodo: $metodo, dataRegistro: $dataRegistro, competencias: $competencias)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Contribuicao && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
