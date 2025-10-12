import 'package:flutter/material.dart';
import 'package:video_surf_app/dao/avaliacao_indicador_dao.dart';
import 'package:video_surf_app/dao/avaliacao_manobra_dao.dart';
import 'package:video_surf_app/dao/onda_dao.dart';
import 'package:video_surf_app/dao/tipo_acao_dao.dart';
import 'package:video_surf_app/model/avaliacao_indicador.dart';
import 'package:video_surf_app/model/avaliacao_manobra.dart';
import 'package:video_surf_app/model/enum/base_surfista.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'package:video_surf_app/model/enum/lado_onda.dart';
import 'package:video_surf_app/model/enum/side.dart';
import 'package:video_surf_app/model/indicador.dart';
import 'package:video_surf_app/model/onda.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/model/tipo_acao.dart';
import 'package:video_surf_app/model/video.dart';
import 'package:video_surf_app/widget/classificacao/classificacoes_buttons.dart';
import 'package:video_surf_app/widget/video_analise/tagging/lado_onda_widget.dart';

class TaggingWidget extends StatefulWidget {
  final Surfista surfista;
  final Duration Function() getVideoPosition;
  final Video video;
  final VoidCallback? onNovaTagCriada;
  const TaggingWidget({
    super.key,
    required this.surfista,
    required this.getVideoPosition,
    required this.video,
    this.onNovaTagCriada,
  });

  @override
  State<TaggingWidget> createState() => _TaggingWidgetState();
}

class _TaggingWidgetState extends State<TaggingWidget> {
  TipoAcaoDao tipoAcaoDao = TipoAcaoDao();
  List<String> niveis = [];
  String? nivelSelecionado;
  List<TipoAcao> manobras = [];
  TipoAcao? manobraSelecionada;

  LadoOnda? ladoOnda;

  int? ondaAtualId;

  // estado da classificação
  Map<int, Classificacao?> classificacoes = {}; // indicadorId -> classificação

  int? indicadorSelecionadoId;

  @override
  void initState() {
    super.initState();
    _loadNiveis();
  }

  Future<void> _loadNiveis() async {
    List<String> lista = await tipoAcaoDao.getDistinctNiveis();
    setState(() {
      niveis = lista;
      if (niveis.isNotEmpty) {
        nivelSelecionado = niveis.first;
        _loadManobras(nivelSelecionado!);
      }
    });
  }

  Future<void> _loadManobras(String nivel) async {
    List<TipoAcao> lista = await tipoAcaoDao.getByNivel(nivel);
    setState(() {
      manobras = lista;
      manobraSelecionada = null;
      classificacoes.clear();
    });
  }

  Future<void> _selecionarManobra(TipoAcao manobra) async {
    if (manobra.tipoAcaoId == null) return;

    TipoAcao? carregada = await tipoAcaoDao.findWithIndicadores(
      manobra.tipoAcaoId!,
    );
    setState(() {
      manobraSelecionada = carregada;
      classificacoes.clear();
    });
  }

  Future<int?> salvarOnda({required bool terminouCaindo}) async {
    if (ladoOnda == null) {
      // TODO: mostrar mensagem ao usuário
      return null;
    }

    if (widget.surfista.surfistaId == null || widget.video.videoId == null) {
      return null;
    }

    Onda onda = Onda(
      ondaId: ondaAtualId,
      surfistaId: widget.surfista.surfistaId!,
      localId: widget.video.localId,
      videoId: widget.video.videoId!,
      data: DateTime.now(),
      ladoOnda: ladoOnda!,
      terminouCaindo: terminouCaindo,
    );

    if (ondaAtualId != null) {
      await OndaDao().update(onda);
      return ondaAtualId;
    } else {
      int ondaId = await OndaDao().createOnda(onda);
      return ondaId;
    }
  }

  clear() {
    setState(() {
      manobraSelecionada = null;
      classificacoes.clear();
      ladoOnda = null;
    });
  }

  Future<void> salvarManobra(int ondaId) async {
    if (manobraSelecionada == null) return;
    if (ladoOnda == null) {
      // TODO: mensagem de erro
      return;
    }

    List<AvaliacaoIndicador> indicadoresAvaliados =
        manobraSelecionada!.indicadores?.map((i) {
          return AvaliacaoIndicador(
            idIndicador: i.indicadorId!,
            classificacao:
                classificacoes[i.indicadorId] ?? Classificacao.naoRealizado,
          );
        }).toList() ??
        [];

    AvaliacaoManobra manobraAvaliada = AvaliacaoManobra(
      ondaId: ondaId,
      idTipoAcao: manobraSelecionada!.tipoAcaoId!,
      side: getSide(),
      tempoMs: widget.getVideoPosition().inMilliseconds,
      avaliacaoIndicadores: indicadoresAvaliados,
    );

    await AvaliacaoManobraDao().createManobra(manobraAvaliada);

    setState(() {
      manobraSelecionada = null;
      classificacoes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 460,
      // width: 324,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: const Border(left: BorderSide(color: Colors.black87, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- lado da onda
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LadoOndaWidget(
                        valorInicial: ladoOnda,
                        onSelecionar: (lado) {
                          setState(() {
                            ladoOnda = lado;
                          });
                        },
                      ),
                      //aqui os botoes com niveis para filtrar as manobras
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text(
                            "Nível",
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(color: Colors.white),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: niveis.map((n) {
                              final selecionado = nivelSelecionado == n;
                              return ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    nivelSelecionado = n;
                                  });
                                  _loadManobras(n);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selecionado
                                      ? Colors.teal.shade400
                                      : Colors.teal.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: selecionado
                                          ? Colors.tealAccent
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  n,
                                  style: TextStyle(
                                    fontWeight: selecionado
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Text(
                    "Manobras",
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(color: Colors.white),
                  ),

                  // --- lista de manobras
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: manobras.map((m) {
                      final selecionado =
                          manobraSelecionada?.tipoAcaoId == m.tipoAcaoId;
                      return GestureDetector(
                        onTap: () => _selecionarManobra(m),
                        child: Card(
                          color: selecionado
                              ? Colors.teal.shade400
                              : Colors.teal.shade700.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: selecionado
                                  ? Colors.tealAccent
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text(
                              m.nome,
                              style: TextStyle(
                                color: selecionado
                                    ? Colors.white
                                    : Colors.teal.shade100,
                                fontWeight: selecionado
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // --- indicadores
                  if (manobraSelecionada != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      "Indicadores",
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.copyWith(color: Colors.white),
                    ),

                    if (manobraSelecionada!.indicadores != null &&
                        manobraSelecionada!.indicadores!.isNotEmpty)
                      Expanded(
                        child: ListView(
                          children: manobraSelecionada!.indicadores!.map((i) {
                            final selecionado =
                                indicadorSelecionadoId == i.indicadorId;
                            final classificacao = classificacoes[i.indicadorId];

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selecionado
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade800,
                                  width: 2,
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  i.descricao,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: classificacao != null
                                    ? Container(
                                        width: 45,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: classificacao.backgroundColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: classificacao.borderColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: Text(
                                          classificacao.sigla,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,

                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        "Sem \nclassificação",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                onTap: () {
                                  setState(() {
                                    indicadorSelecionadoId = i.indicadorId;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    else
                      Text(
                        "Nenhum indicador encontrado",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                  ],

                  // --- barra inferior de classificação
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClassificacoesButtons(
              selecionado: classificacoes[indicadorSelecionadoId],
              onClassificar: (c) {
                setState(() {
                  if (indicadorSelecionadoId != null) {
                    classificacoes[indicadorSelecionadoId!] = c;
                  }
                });
              },
            ),
          ),

          Container(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // --- Próxima Manobra ---
                  ElevatedButton.icon(
                    onPressed: () async {
                      ondaAtualId ??= await salvarOnda(terminouCaindo: false);
                      if (ondaAtualId != null) {
                        salvarManobra(
                          ondaAtualId!,
                        ); // salva a manobra atual e limpa seleções
                        widget.onNovaTagCriada?.call();
                      }
                      // manter estado da onda
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text("Próxima Manobra"),
                  ),

                  // --- Saiu da Onda ---
                  ElevatedButton.icon(
                    onPressed: () {
                      salvarOnda(terminouCaindo: false);
                      ondaAtualId = null;
                      widget.onNovaTagCriada?.call();
                      clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.flag_rounded),
                    label: const Text("Finalizou"),
                  ),

                  // --- Caiu da Onda ---
                  ElevatedButton.icon(
                    onPressed: () {
                      salvarOnda(terminouCaindo: true);
                      ondaAtualId = null;
                      widget.onNovaTagCriada?.call();
                      clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: const Text("Caiu"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Side getSide() {
    final base = widget.surfista.base;
    final lado = ladoOnda;

    if (base == null || lado == null) {
      // Valor padrão ou tratamento de erro
      return Side.frontside;
    }

    if (base == BaseSurfista.regular && lado == LadoOnda.direita) {
      return Side.frontside;
    } else if (base == BaseSurfista.regular && lado == LadoOnda.esquerda) {
      return Side.backside;
    } else if (base == BaseSurfista.goofy && lado == LadoOnda.direita) {
      return Side.backside;
    } else if (base == BaseSurfista.goofy && lado == LadoOnda.esquerda) {
      return Side.frontside;
    }

    // Caso imprevisto
    return Side.frontside;
  }
}
