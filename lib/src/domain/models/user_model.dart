import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final int createdAt;
  final int lastLoginAt;
  final String nome;
  final String cpf;
  final String telefone;
  final String endereco;
  final String funcao;
  final String status;
  final DateTime ultimoAcesso;
  final bool pendencia;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.endereco,
    required this.funcao,
    required this.status,
    required this.ultimoAcesso,
    required this.pendencia,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime parseUltimoAcesso(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoURL: json['photoURL'] ?? '',
      createdAt: json['createdAt'] ?? 0,
      lastLoginAt: json['lastLoginAt'] ?? 0,
      nome: json['nome'] ?? '',
      cpf: json['cpf'] ?? '',
      telefone: json['telefone'] ?? '',
      endereco: json['endereco'] ?? '',
      funcao: json['funcao'] ?? '',
      status: json['status'] ?? '',
      ultimoAcesso: parseUltimoAcesso(json['ultimoAcesso']),
      pendencia: json['pendencia'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'nome': nome,
      'cpf': cpf,
      'telefone': telefone,
      'endereco': endereco,
      'funcao': funcao,
      'status': status,
      'ultimoAcesso': ultimoAcesso.millisecondsSinceEpoch,
      'pendencia': pendencia,
    };
  }
}
