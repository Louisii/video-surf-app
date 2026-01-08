import 'package:flutter/material.dart';
import 'package:video_surf_app/model/relatorio_onda.dart';

class TabelaRelatorio extends StatelessWidget {
  final List<RelatorioOnda> relatorio;

  const TabelaRelatorio({super.key, required this.relatorio});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          headingRowHeight: 48,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 56,
          columnSpacing: 24,
          horizontalMargin: 16,

          // 🎨 Cabeçalho
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),

          dividerThickness: 1,

          columns: const [
            DataColumn(label: Text('Onda', style: _headerStyle)),
            DataColumn(label: Text('Data', style: _headerStyle)),
            DataColumn(label: Text('Local', style: _headerStyle)),
            DataColumn(label: Text('Lado', style: _headerStyle)),
            DataColumn(label: Text('Finalizou', style: _headerStyle)),
            DataColumn(
              numeric: true,
              label: Text('Manobras', style: _headerStyle),
            ),
            DataColumn(
              numeric: true,
              label: Text('Desempenho', style: _headerStyle),
            ),
          ],
          rows: relatorio.asMap().entries.map((entry) {
            final index = entry.key;
            final r = entry.value;

            return DataRow(
              color: MaterialStateProperty.resolveWith(
                (states) => index.isEven ? Colors.grey.shade50 : Colors.white,
              ),
              cells: [
                DataCell(Text('Onda ${index + 1}')),
                DataCell(Text(_formatDate(r.data))),
                DataCell(Text(r.local)),
                DataCell(_ladoChip(r.lado)),
                DataCell(
                  Text(
                    r.terminouCaindo ? "Caiu" : "Finalizou",
                    style: TextStyle(
                      color: r.terminouCaindo ? Colors.red : Colors.green,
                      // size: 20,
                    ),
                  ),
                ),
                DataCell(
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(r.totalManobras.toString()),
                  ),
                ),
                DataCell(_desempenhoBadge(r.desempenhoPercent)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ───────────────────────── helpers ─────────────────────────

  static const _headerStyle = TextStyle(fontWeight: FontWeight.w600);

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  static Widget _ladoChip(String lado) {
    return Chip(
      label: Text(lado),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      backgroundColor: Colors.blueGrey.shade50,
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  static Widget _desempenhoBadge(double percent) {
    final color = percent >= 70
        ? Colors.green
        : percent >= 40
        ? Colors.orange
        : Colors.red;

    return Container(
      height: 36,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '${percent.toStringAsFixed(0)}%',
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
