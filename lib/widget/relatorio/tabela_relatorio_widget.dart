import 'package:flutter/material.dart';
import 'package:video_surf_app/model/relatorio_onda.dart';

class TabelaRelatorio extends StatelessWidget {
  final List<RelatorioOnda> relatorio;

  const TabelaRelatorio({required this.relatorio});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTable(
        columnSpacing: 16,
        columns: const [
          DataColumn(label: Text('Data')),
          DataColumn(label: Text('Local')),
          DataColumn(label: Text('Lado')),
          DataColumn(label: Text('Caiu')),
          DataColumn(label: Text('Manobras')),
          DataColumn(label: Text('Média')),
          DataColumn(label: Text('Desempenho')),
        ],
        rows: relatorio.map((r) {
          return DataRow(
            cells: [
              DataCell(Text('${r.data.day}/${r.data.month}/${r.data.year}')),
              DataCell(Text(r.local)),
              DataCell(Text(r.lado)),
              DataCell(Text(r.terminouCaindo ? 'Sim' : 'Não')),
              DataCell(Text(r.totalManobras.toString())),
              DataCell(Text(r.mediaIndicadores.toStringAsFixed(1))),
              DataCell(
                Text(
                  '${r.desempenhoPercent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: r.desempenhoPercent >= 70
                        ? Colors.green
                        : r.desempenhoPercent >= 40
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
