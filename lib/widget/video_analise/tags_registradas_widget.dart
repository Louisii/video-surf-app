import 'package:flutter/material.dart';
import 'package:video_surf_app/dao/avaliacao_manobra_dao.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'package:video_surf_app/model/avaliacao_manobra.dart';
import 'package:video_surf_app/model/avaliacao_indicador.dart';

class TagsRegistradasWidget extends StatefulWidget {
  final int idVideo; // vídeo que queremos ler

  const TagsRegistradasWidget({super.key, required this.idVideo});

  @override
  State<TagsRegistradasWidget> createState() => _TagsRegistradasWidgetState();
}

class _TagsRegistradasWidgetState extends State<TagsRegistradasWidget> {
  AvaliacaoManobraDao dao = AvaliacaoManobraDao();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border.all(color: Colors.black87),
        borderRadius: BorderRadius.circular(12),
      ),
      child: FutureBuilder<List<AvaliacaoManobra>>(
        future: dao.findByVideo(widget.idVideo),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar tags: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma avaliação registrada',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final avaliacoes = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12,
              headingRowColor: MaterialStateProperty.all(Colors.grey[700]),
              columns: const [
                DataColumn(
                  label: Text('Manobra', style: TextStyle(color: Colors.white)),
                ),
                DataColumn(
                  label: Text('Tempo', style: TextStyle(color: Colors.white)),
                ),
                DataColumn(
                  label: Text('Lado', style: TextStyle(color: Colors.white)),
                ),
                DataColumn(
                  label: Text(
                    'Indicador',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Classificação',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
              rows: avaliacoes.expand((avaliacao) {
                // cada avaliacao pode ter vários indicadores
                final indicadores = avaliacao.avaliacaoIndicadores ?? [];
                return indicadores.map((i) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          avaliacao.tipoAcao?.nome ?? '-',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${(avaliacao.tempoMs / 1000).toStringAsFixed(2)}s',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          avaliacao.ladoOnda?.name ?? '-',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          i.indicador?.descricao ?? '-',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          i.classificacao?.label ?? '-',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                });
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
