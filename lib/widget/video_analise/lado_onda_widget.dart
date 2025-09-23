import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_surf_app/model/enum/lado_onda.dart';

class LadoOndaWidget extends StatefulWidget {
  const LadoOndaWidget({super.key});

  @override
  State<LadoOndaWidget> createState() => _LadoOndaWidgetState();
}

class _LadoOndaWidgetState extends State<LadoOndaWidget> {
  LadoOnda? ladoSelecionado;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Identificação de Onda",
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: Colors.white),
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    ladoSelecionado = LadoOnda.direita;
                  });
                },
                child: Card(
                  color: ladoSelecionado == LadoOnda.direita
                      ? Colors.teal.shade400
                      : Colors.teal.shade700.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: ladoSelecionado == LadoOnda.direita
                          ? Colors.tealAccent
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      spacing: 8,
                      children: [
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: Icon(
                            Icons.tsunami,
                            size: 32,
                            color: ladoSelecionado == LadoOnda.direita
                                ? Colors.white
                                : Colors.teal.shade100,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Direita",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ladoSelecionado == LadoOnda.direita
                                ? Colors.white
                                : Colors.teal.shade100,
                            fontWeight: ladoSelecionado == LadoOnda.direita
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    ladoSelecionado = LadoOnda.esquerda;
                  });
                },
                child: Card(
                  color: ladoSelecionado == LadoOnda.esquerda
                      ? Colors.teal.shade400
                      : Colors.teal.shade700.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: ladoSelecionado == LadoOnda.esquerda
                          ? Colors.tealAccent
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      spacing: 8,
                      children: [
                        Icon(
                          Icons.tsunami,
                          size: 32,
                          color: ladoSelecionado == LadoOnda.esquerda
                              ? Colors.white
                              : Colors.teal.shade100,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Esquerda",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ladoSelecionado == LadoOnda.esquerda
                                ? Colors.white
                                : Colors.teal.shade100,
                            fontWeight: ladoSelecionado == LadoOnda.esquerda
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
