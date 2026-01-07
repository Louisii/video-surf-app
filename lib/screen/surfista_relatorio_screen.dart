import 'package:flutter/material.dart';
import 'package:video_surf_app/dto/relatorio_surfista_dto.dart';
import 'package:video_surf_app/model/relatorio_onda.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/widget/relatorio/resumo_relatorio_widget.dart';
import 'package:video_surf_app/widget/relatorio/tabela_relatorio_widget.dart';

class SurfistaRelatorioScreen extends StatelessWidget {
  final Surfista surfista;

  const SurfistaRelatorioScreen({super.key, required this.surfista});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório – ${surfista.nome}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exportar CSV',
            onPressed: () async {
              final linhas = await RelatorioSurfistaDto().getRelatorioSurfista(
                surfista.surfistaId!,
              );

              // TODO: usar seu helper de exportação CSV
              // await exportarRelatorioCsv(surfista, linhas);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV exportado com sucesso')),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<RelatorioOnda>>(
        future: RelatorioSurfistaDto().getRelatorioSurfista(
          surfista.surfistaId!,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma onda registrada'));
          }

          final relatorio = snapshot.data!;

          return Column(
            children: [
              ResumoRelatorio(relatorio: relatorio),
              const Divider(),
              Expanded(child: TabelaRelatorio(relatorio: relatorio)),
            ],
          );
        },
      ),
    );
  }
}
