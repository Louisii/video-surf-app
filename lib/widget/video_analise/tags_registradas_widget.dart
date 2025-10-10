import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_surf_app/dao/onda_dao.dart';
import 'package:video_surf_app/dao/tipo_acao_dao.dart';
import 'package:video_surf_app/model/onda.dart';
import 'package:video_surf_app/model/tipo_acao.dart';

class TagsRegistradasWidget extends StatefulWidget {
  final int idVideo;

  const TagsRegistradasWidget({super.key, required this.idVideo});

  @override
  State<TagsRegistradasWidget> createState() => _TagsRegistradasWidgetState();
}

class _TagsRegistradasWidgetState extends State<TagsRegistradasWidget> {
  late Future<List<Onda>> _ondasFuture;

  // Guarda o estado de expansão de cada onda
  final Map<int, bool> _expanded = {};

  @override
  void initState() {
    super.initState();
    _ondasFuture = OndaDao().findByVideo(widget.idVideo);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // maior para expandir melhor
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border.all(color: Colors.black87),
      ),
      child: FutureBuilder<List<Onda>>(
        future: _ondasFuture,
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

          List<Onda> ondas = snapshot.data!;

          return ListView.builder(
            itemCount: ondas.length,
            itemBuilder: (context, index) {
              Onda onda = ondas[index];
              final isExpanded = _expanded[onda.ondaId] ?? false;

              return Card(
                color: Colors.teal[700],
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ExpansionTile(
                  key: PageStorageKey<int>(onda.ondaId!), // mantém o estado
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Onda ${onda.ondaId}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Manobras: ${onda.manobrasAvaliadas.length}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Desempenho: ${onda.mediaDesempenhoPercent().toStringAsFixed(0)}%",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  initiallyExpanded: isExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _expanded[onda.ondaId!] = expanded;
                    });
                  },
                  children: isExpanded
                      ? onda.manobrasAvaliadas.map((manobra) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            color: Colors.teal[900],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FutureBuilder<TipoAcao?>(
                                  future: TipoAcaoDao().getById(
                                    manobra.idTipoAcao,
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        "Erro: ${snapshot.error}",
                                        style: TextStyle(color: Colors.red),
                                      );
                                    } else if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return const Text(
                                        "Desconhecido",
                                        style: TextStyle(color: Colors.white),
                                      );
                                    } else {
                                      return Text(
                                        snapshot.data!.nome,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      );
                                    }
                                  },
                                ),

                                Text(
                                  "Média desempenho: ${manobra.mediaDesempenhoPercent().toStringAsFixed(0)}%",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                // aqui você pode adicionar mais detalhes de indicadores
                              ],
                            ),
                          );
                        }).toList()
                      : [],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
