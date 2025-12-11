class Contribuicao {
  final int id;
  final int dizimistaId;
  final String dizimistaNome;
  final String tipo;
  final double valor;
  final String metodo;
  final DateTime dataRegistro;

  Contribuicao({
    required this.id,
    required this.dizimistaId,
    required this.dizimistaNome,
    required this.tipo,
    required this.valor,
    required this.metodo,
    required this.dataRegistro,
  });

  Contribuicao copyWith({
    int? id,
    int? dizimistaId,
    String? dizimistaNome,
    String? mesReferencia,
    String? tipo,
    double? valor,
    String? metodo,
    DateTime? dataRegistro,
  }) {
    return Contribuicao(
      id: id ?? this.id,
      dizimistaId: dizimistaId ?? this.dizimistaId,
      dizimistaNome: dizimistaNome ?? this.dizimistaNome,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      metodo: metodo ?? this.metodo,
      dataRegistro: dataRegistro ?? this.dataRegistro,
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
    };
  }

  factory Contribuicao.fromMap(Map<String, dynamic> map) {
    return Contribuicao(
      id: map['id']?.toInt() ?? 0,
      dizimistaId: map['dizimistaId']?.toInt() ?? 0,
      dizimistaNome: map['dizimistaNome'] ?? '',
      tipo: map['tipo'] ?? '',
      valor: (map['valor'] is int) ? (map['valor'] as int).toDouble() : map['valor']?.toDouble() ?? 0.0,
      metodo: map['metodo'] ?? '',
      dataRegistro: DateTime.fromMillisecondsSinceEpoch(map['dataRegistro'] ?? 0),
    );
  }

  @override
  String toString() {
    return 'Contribuicao(id: $id, dizimistaId: $dizimistaId, dizimistaNome: $dizimistaNome,  tipo: $tipo, valor: $valor, metodo: $metodo, dataRegistro: $dataRegistro)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Contribuicao &&
           other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}