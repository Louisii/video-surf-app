import 'package:flutter/material.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'classificacao_button.dart'; // seu botão estilizado

class ClassificacoesButtons extends StatelessWidget {
  final Classificacao? selecionado;
  final ValueChanged<Classificacao> onClassificar;

  const ClassificacoesButtons({
    super.key,
    required this.selecionado,
    required this.onClassificar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: Classificacao.values.map((classificacao) {
        final bool isSelecionado = classificacao == selecionado;

        return ClassificacaoButton(
          classificacao: classificacao,
          selected: isSelecionado,
          onPressed: () => onClassificar(classificacao),
        );
      }).toList(),
    );
  }
}
