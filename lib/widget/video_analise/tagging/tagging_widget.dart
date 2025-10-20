import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_surf_app/dao/avaliacao_manobra_dao.dart';
import 'package:video_surf_app/dao/onda_dao.dart';
import 'package:video_surf_app/dao/tipo_acao_dao.dart';
import 'package:video_surf_app/model/avaliacao_indicador.dart';
import 'package:video_surf_app/model/avaliacao_manobra.dart';
import 'package:video_surf_app/model/enum/base_surfista.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'package:video_surf_app/model/enum/lado_onda.dart';
import 'package:video_surf_app/model/enum/side.dart';
import 'package:video_surf_app/model/onda.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/model/tipo_acao.dart';
import 'package:video_surf_app/model/video.dart';
import 'package:video_surf_app/providers/onda_provider.dart';
import 'package:video_surf_app/providers/ondas_provider.dart';
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
  List<TipoAcao> manobrasFiltradasPorSide = [];
  TipoAcao? manobraSelecionada;

  LadoOnda? ladoOnda;

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

      if (ladoOnda != null) {
        manobrasFiltradasPorSide = filtrarManobrasPorSide(
          manobras,
          ladoOnda!,
          widget.surfista.base,
        );
      } else {
        manobrasFiltradasPorSide = manobras;
      }
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

  Future<int?> salvarOndaDB(Onda onda) async {
    if (onda.ondaId != null) {
      await OndaDao().update(onda);
      return onda.ondaId;
    } else {
      int ondaId = await OndaDao().createOnda(onda);
      return ondaId;
    }
  }

  clear() {
    setState(() {
      manobraSelecionada = null;
      // classificacoes.clear();
      // ladoOnda = null;
    });
  }

  Future<void> salvarManobra(
    OndaProvider ondaProvider,
    OndasProvider ondasProvider,
  ) async {
    if (manobraSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione a manobra realizada!"),
          duration: Duration(seconds: 2),
        ),
      );

      return;
    }
    if (ladoOnda == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione o lado da onda!"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (ondaProvider.onda == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro: onda é null!"),
          duration: Duration(seconds: 2),
        ),
      );

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
      ondaId: ondaProvider.onda!.ondaId!,
      idTipoAcao: manobraSelecionada!.tipoAcaoId!,
      side: getSide(),
      tempoMs: widget.getVideoPosition().inMilliseconds,
      avaliacaoIndicadores: indicadoresAvaliados,
    );

    await AvaliacaoManobraDao().createManobra(manobraAvaliada);
    if (ondaProvider.onda == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro: onda é null!"),
            duration: Duration(seconds: 2),
          ),
        );
      }

      return;
    }
    ondaProvider.addManobraAvaliada(manobraAvaliada);
    ondasProvider.updateOnda(ondaProvider.onda!);
    setState(() {
      manobraSelecionada = null;
      classificacoes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final OndaProvider ondaProvider = Provider.of<OndaProvider>(
      context,
      listen: false,
    );
    final OndasProvider ondasProvider = Provider.of<OndasProvider>(
      context,
      listen: false,
    );
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
                          manobrasFiltradasPorSide = filtrarManobrasPorSide(
                            manobras,
                            lado,
                            widget.surfista.base,
                          );
                          setState(() {
                            ladoOnda = lado;
                            manobrasFiltradasPorSide;
                            manobraSelecionada = null;
                            classificacoes = {};
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
                    children: manobrasFiltradasPorSide.map((m) {
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
                    const SizedBox(height: 8),
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
                              child: Stack(
                                children: [
                                  ListTile(
                                    title: Text(
                                      i.descricao,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    trailing: classificacao != null
                                        ? Container(
                                            width: 45,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  classificacao.backgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color:
                                                    classificacao.borderColor,
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
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                    onTap: () {
                                      setState(() {
                                        indicadorSelecionadoId = i.indicadorId;
                                      });
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 0,
                                        left: 4,
                                      ),
                                      child: Text(
                                        i.ordemItem.toString(),
                                        style: TextStyle(
                                          color: Colors.white12,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                      if (ondaProvider.onda == null) {
                        await criarOnda(ondaProvider, false, ondasProvider);
                      }
                      salvarManobra(ondaProvider, ondasProvider);
                      clear();
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
                    onPressed: () async {
                      if (ondaProvider.onda == null) {
                        await criarOnda(ondaProvider, false, ondasProvider);
                        await salvarManobra(ondaProvider, ondasProvider);
                        ondaProvider.setOnda(null);
                      } else {
                        await salvarManobra(ondaProvider, ondasProvider);
                        ondaProvider.setOnda(null);
                      }

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
                    onPressed: () async {
                      if (ondaProvider.onda == null) {
                        await criarOnda(ondaProvider, true, ondasProvider);
                      } else {
                        ondaProvider.updateTerminouCaindo(true);
                        await salvarOndaDB(ondaProvider.onda!);
                      }

                      await salvarManobra(ondaProvider, ondasProvider);
                      ondaProvider.setOnda(null);

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

  criarOnda(
    OndaProvider ondaAtualProvider,
    bool terminouCaindo,
    OndasProvider ondasProvider,
  ) async {
    if (ladoOnda == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione o lado da onda!"),
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }

    if (widget.surfista.surfistaId == null || widget.video.videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao identificar surfista"),
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }

    Onda onda = Onda(
      ondaId: null,
      surfistaId: widget.surfista.surfistaId!,
      localId: widget.video.localId,
      videoId: widget.video.videoId!,
      data: DateTime.now(),
      ladoOnda: ladoOnda!,
      terminouCaindo: terminouCaindo,
    );

    try {
      int? ondaId = await salvarOndaDB(onda);
      onda.ondaId = ondaId;

      if (ondaId != null) {
        ondaAtualProvider.setOnda(onda);
        ondasProvider.addOnda(onda);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro: ondaid = null"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  Side getSide() {
    final base = widget.surfista.base;
    final lado = ladoOnda;

    if (lado == null) {
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

  List<TipoAcao> filtrarManobrasPorSide(
    List<TipoAcao> manobras,
    LadoOnda lado,
    BaseSurfista base,
  ) {
    late final Side sideEsperado;

    if (base == BaseSurfista.regular && lado == LadoOnda.direita) {
      sideEsperado = Side.frontside;
    } else if (base == BaseSurfista.regular && lado == LadoOnda.esquerda) {
      sideEsperado = Side.backside;
    } else if (base == BaseSurfista.goofy && lado == LadoOnda.direita) {
      sideEsperado = Side.backside;
    } else {
      sideEsperado = Side.frontside;
    }

    return manobras
        .where((m) => m.side == sideEsperado || m.side == Side.desconhecido)
        .toList();
  }
}
