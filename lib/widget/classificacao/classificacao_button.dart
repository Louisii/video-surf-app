import 'package:flutter/material.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';

class ClassificacaoButton extends StatelessWidget {
  final Classificacao classificacao;
  final bool selected;
  final VoidCallback onPressed;

  const ClassificacaoButton({
    super.key,
    required this.classificacao,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = selected
        ? classificacao.backgroundColor.withValues(alpha: 0.9)
        : classificacao.backgroundColor.withValues(alpha: 0.4);
    Color borderColor = selected
        ? classificacao.borderColor
        : Colors.transparent;

    Color textColor = selected ? Colors.white : Colors.white70;

    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: selected ? 2 : 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: onPressed,
        child: Text(
          classificacao.sigla,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
