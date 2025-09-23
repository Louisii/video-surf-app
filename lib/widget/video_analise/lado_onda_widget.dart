import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_surf_app/model/enum/lado_onda.dart';

class LadoOndaWidget extends StatefulWidget {
  final LadoOnda? valorInicial;
  final ValueChanged<LadoOnda> onSelecionar;

  const LadoOndaWidget({
    super.key,
    this.valorInicial,
    required this.onSelecionar,
  });

  @override
  State<LadoOndaWidget> createState() => _LadoOndaWidgetState();
}

class _LadoOndaWidgetState extends State<LadoOndaWidget> {
  LadoOnda? ladoSelecionado;

  @override
  void initState() {
    super.initState();
    ladoSelecionado = widget.valorInicial;
  }

  void _selecionar(LadoOnda lado) {
    setState(() {
      ladoSelecionado = lado;
    });
    widget.onSelecionar(lado);
  }

  Widget _buildBotaoLado({
    required LadoOnda lado,
    required String label,
    bool flipIcon = false,
  }) {
    final selecionado = ladoSelecionado == lado;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selecionar(lado),
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
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: flipIcon
                      ? Matrix4.rotationY(math.pi)
                      : Matrix4.identity(),
                  child: Icon(
                    Icons.tsunami,
                    size: 32,
                    color: selecionado ? Colors.white : Colors.teal.shade100,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: selecionado ? Colors.white : Colors.teal.shade100,
                    fontWeight: selecionado
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Identificação de Onda",
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildBotaoLado(
              lado: LadoOnda.direita,
              label: "Direita",
              flipIcon: true,
            ),
            const SizedBox(width: 8),
            _buildBotaoLado(lado: LadoOnda.esquerda, label: "Esquerda"),
          ],
        ),
      ],
    );
  }
}
