import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_surf_app/dao/indicador_dao.dart';
import 'package:video_surf_app/dao/onda_dao.dart';
import 'package:video_surf_app/dao/tipo_acao_dao.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'package:video_surf_app/model/indicador.dart';
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
      height: 260, // maior para expandir melhor
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
                color: Colors.teal[900],
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ), // menos espaço
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ), // menos espaço para children

                  key: PageStorageKey<int>(onda.ondaId!), // mantém o estado
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Onda ${index + 1}",
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
                          return Card(
                            color: Colors.teal[600],
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ), // menos espaço
                              childrenPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ), // menos espaço para children

                              key: PageStorageKey<int>(
                                manobra.avaliacaoManobraId!,
                              ),
                              title: FutureBuilder<TipoAcao?>(
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
                                      style: const TextStyle(color: Colors.red),
                                    );
                                  } else if (!snapshot.hasData ||
                                      snapshot.data == null) {
                                    return const Text(
                                      "Desconhecido",
                                      style: TextStyle(color: Colors.white),
                                    );
                                  } else {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          snapshot.data!.nome,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          "Desempenho: ${manobra.mediaDesempenhoPercent().toStringAsFixed(0)}%",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              children: manobra.avaliacaoIndicadores.map((
                                indicador,
                              ) {
                                return Container(
                                  color: Colors.teal[400],
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      FutureBuilder<Indicador?>(
                                        future: IndicadorDao().getIndicadorById(
                                          indicador.idIndicador,
                                        ),
                                        builder: (context, asyncSnapshot) {
                                          if (asyncSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            );
                                          } else if (asyncSnapshot.hasError) {
                                            return Text(
                                              'Erro',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            );
                                          } else if (!asyncSnapshot.hasData ||
                                              asyncSnapshot.data == null) {
                                            return const Text(
                                              'Desconhecido',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            );
                                          }

                                          return Text(
                                            asyncSnapshot.data!.descricao,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                      Text(
                                        "${indicador.classificacao.label} (${(indicador.classificacao.valor * 100).toStringAsFixed(0)}%)",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
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
