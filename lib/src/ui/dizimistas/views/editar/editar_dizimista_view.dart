import 'package:flutter/material.dart';
import '../../models/dizimista_model.dart';
import '../cadastro/cadastro_dizimista_view.dart';

/// Wrapper para reaproveitar a lógica e design de CadastroDizimistaView
/// na edição de dizimistas, mantendo a consistência visual e de comportamento (teclado/scroll).
class EditarDizimistaView extends StatelessWidget {
  final Dizimista? dizimista;

  const EditarDizimistaView({Key? key, this.dizimista}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CadastroDizimistaView(dizimista: dizimista);
  }
}
