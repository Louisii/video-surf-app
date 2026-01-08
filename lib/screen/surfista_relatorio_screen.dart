import 'package:flutter/material.dart';
import 'package:video_surf_app/dto/relatorio_surfista_dto.dart';
import 'package:video_surf_app/model/relatorio_onda.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/widget/custom_appbar_widget.dart';
import 'package:video_surf_app/widget/relatorio/resumo_relatorio_widget.dart';
import 'package:video_surf_app/widget/relatorio/tabela_relatorio_widget.dart';
import 'package:video_surf_app/utils/exportar_relatorio_csv.dart';

class SurfistaRelatorioScreen extends StatelessWidget {
  final Surfista surfista;

  const SurfistaRelatorioScreen({super.key, required this.surfista});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarWidget(),

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
              Container(
                color: Colors.teal,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Relatório – ${surfista.nome}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      ResumoRelatorio(relatorio: relatorio),
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        tooltip: 'Exportar CSV',
                        onPressed: () async {
                          final linhas = await RelatorioSurfistaDto()
                              .getRelatorioSurfista(surfista.surfistaId!);

                          final file = await exportarRelatorioCsv(
                            surfista,
                            linhas,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                showCloseIcon: true,
                                duration: Duration(minutes: 1),
                                content: Text(
                                  'CSV exportado com sucesso\n${file.path}',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: TabelaRelatorio(relatorio: relatorio)),
            ],
          );
        },
      ),
    );
  }
}
