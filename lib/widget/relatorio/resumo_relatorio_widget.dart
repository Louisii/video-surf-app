import 'package:flutter/material.dart';
import 'package:video_surf_app/model/relatorio_onda.dart';
import 'package:video_surf_app/widget/relatorio/resumo_item_widget.dart';

class ResumoRelatorio extends StatelessWidget {
  final List<RelatorioOnda> relatorio;

  const ResumoRelatorio({required this.relatorio});

  @override
  Widget build(BuildContext context) {
    final totalOndas = relatorio.length;

    final mediaGeral = totalOndas == 0
        ? 0
        : relatorio
                .map((r) => r.desempenhoPercent)
                .reduce((a, b) => a + b) /
            totalOndas;

    final melhorOnda = relatorio.reduce(
      (a, b) => a.desempenhoPercent > b.desempenhoPercent ? a : b,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          ResumoItem(
            icon: Icons.tsunami,
            label: 'Ondas',
            value: totalOndas.toString(),
          ),
          ResumoItem(
            icon: Icons.insights,
            label: 'Média',
            value: '${mediaGeral.toStringAsFixed(0)}%',
          ),
          ResumoItem(
            icon: Icons.emoji_events,
            label: 'Melhor Onda',
            value: '${melhorOnda.desempenhoPercent.toStringAsFixed(0)}%',
          ),
        ],
      ),
    );
  }
}
