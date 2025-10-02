import 'package:flutter/material.dart';
import 'package:video_surf_app/dao/avaliacao_indicador_dao.dart';
import 'package:video_surf_app/dao/avaliacao_manobra_dao.dart';
import 'package:video_surf_app/dao/tipo_acao_dao.dart';
import 'package:video_surf_app/model/avaliacao_indicador.dart';
import 'package:video_surf_app/model/avaliacao_manobra.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'package:video_surf_app/model/enum/lado_onda.dart';
import 'package:video_surf_app/model/enum/side.dart';
import 'package:video_surf_app/model/indicador.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/model/tipo_acao.dart';
import 'package:video_surf_app/model/video.dart';
import 'package:video_surf_app/widget/classificacao/classificacoes_buttons.dart';
import 'package:video_surf_app/widget/video_analise/lado_onda_widget.dart';

class TaggingWidget extends StatefulWidget {
  final Surfista surfista;
  final Duration Function() getVideoPosition;
  final Video video;

  const TaggingWidget({
    super.key,
    required this.surfista,
    required this.getVideoPosition,
    required this.video,
  });

  @override
  State<TaggingWidget> createState() => _TaggingWidgetState();
}

class _TaggingWidgetState extends State<TaggingWidget> {
  final dao = TipoAcaoDao();
  List<String> niveis = [];
  String? nivelSelecionado;
  List<TipoAcao> manobras = [];
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
    final lista = await dao.getDistinctNiveis();
    setState(() {
      niveis = lista;
      if (niveis.isNotEmpty) {
        nivelSelecionado = niveis.first;
        _loadManobras(nivelSelecionado!);
      }
    });
  }

  Future<void> _loadManobras(String nivel) async {
    final lista = await dao.getByNivel(nivel);
    setState(() {
      manobras = lista;
      manobraSelecionada = null;
      classificacoes.clear();
    });
  }

  Future<void> _selecionarManobra(TipoAcao manobra) async {
    if (manobra.tipoAcaoId == null) return;

    final carregada = await dao.findWithIndicadores(manobra.tipoAcaoId!);
    setState(() {
      manobraSelecionada = carregada;
      classificacoes.clear();
    });
  }

  Widget estrelasClassificacao(Classificacao c, double? starSize) {
    int count;
    switch (c) {
      case Classificacao.naoRealizado:
        count = 1;
        break;
      case Classificacao.imperfeito:
        count = 2;
        break;
      case Classificacao.quasePerfeito:
        count = 3;
        break;
      case Classificacao.perfeito:
        count = 4;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Icon(
          index < count ? Icons.star : Icons.star_border,
          color: Colors.tealAccent,
          size: starSize ?? 24,
        );
      }),
    );
  }

  void salvar() async {
    if (manobraSelecionada == null || ladoOnda == null) {
      debugPrint("Erro: manobra ou lado da onda não selecionados");
      return;
    }

    final tempoMs = widget.getVideoPosition().inMilliseconds;
    Side side = Side.desconhecido; // valor padrão
    if (manobraSelecionada != null) {
      final nome = manobraSelecionada!.nome.toUpperCase();
      if (nome.contains('BS')) {
        side = Side.backside;
      } else if (nome.contains('FS')) {
        side = Side.frontside;
      }
    }

    // Cria objeto AvaliacaoManobra
    AvaliacaoManobra avaliacaoManobra = AvaliacaoManobra(
      ondaId: widget.video.videoId!, // passar o id correto do vídeo
      idTipoAcao: manobraSelecionada!.tipoAcaoId!,
      side: side,
      tempoMs: tempoMs,
    );

    debugPrint("AvaliacaoManobra criada: $avaliacaoManobra");
    final manobraDao = AvaliacaoManobraDao();
    final indicadorDao = AvaliacaoIndicadorDao();

    // 1. Salvar AvaliacaoManobra e pegar ID
    final idAvaliacaoManobra = await manobraDao.insert(avaliacaoManobra);
    // 2. Salvar cada AvaliacaoIndicador com o ID gerado
    for (var entry in classificacoes.entries) {
      final indicadorId = entry.key;
      final classificacao = entry.value;
      if (classificacao != null) {
        final avaliacaoIndicador = AvaliacaoIndicador(
          idAvaliacaoManobra: idAvaliacaoManobra,
          idIndicador: indicadorId,
          classificacao: classificacao,
        );
        await indicadorDao.insert(avaliacaoIndicador);
      }
    }
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- lado da onda
            LadoOndaWidget(
              valorInicial: ladoOnda,
              onSelecionar: (lado) {
                setState(() {
                  ladoOnda = lado;
                });
              },
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
                                    borderRadius: BorderRadius.circular(8),
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
            if (indicadorSelecionadoId != null)
              Container(
                // color: Colors.black87,
                padding: const EdgeInsets.all(8),
                child: ClassificacoesButtons(
                  selecionado: classificacoes[indicadorSelecionadoId],
                  onClassificar: (c) {
                    setState(() {
                      classificacoes[indicadorSelecionadoId!] = c;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
