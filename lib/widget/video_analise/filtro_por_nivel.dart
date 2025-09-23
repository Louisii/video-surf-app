import 'package:flutter/material.dart';

class FiltroPorNivel extends StatelessWidget {
  const FiltroPorNivel({
    super.key,
    required this.niveis,
    required this.nivelSelecionado,
    required this.onSelecionarNivel,
  });

  final List<String> niveis;
  final String? nivelSelecionado;
  final ValueChanged<String> onSelecionarNivel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: niveis.map((nivel) {
        final selecionado = nivel == nivelSelecionado;
        return GestureDetector(
          onTap: () => onSelecionarNivel(nivel),
          child: Card(
            color: selecionado
                ? Colors.teal.shade400
                : Colors.teal.shade700.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: selecionado ? Colors.tealAccent : Colors.transparent,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Text(
                nivel,
                style: TextStyle(
                  color: selecionado ? Colors.white : Colors.teal.shade100,
                  fontWeight:
                      selecionado ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
