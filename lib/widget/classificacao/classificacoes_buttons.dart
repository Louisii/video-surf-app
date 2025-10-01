import 'package:flutter/material.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'classificacao_button.dart'; // seu ClassificacaoButton

class ClassificacoesButtons extends StatefulWidget {
  const ClassificacoesButtons({super.key});

  @override
  State<ClassificacoesButtons> createState() => _ClassificacoesButtonsState();
}

class _ClassificacoesButtonsState extends State<ClassificacoesButtons> {
  Classificacao? _selecionado;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: Classificacao.values.map((classificacao) {
        final bool isSelecionado = classificacao == _selecionado;

        return ClassificacaoButton(
          classificacao: classificacao,
          selected: isSelecionado,
          onPressed: () {
            setState(() {
              _selecionado = classificacao;
            });
          },
        );
      }).toList(),
    );
  }
}
