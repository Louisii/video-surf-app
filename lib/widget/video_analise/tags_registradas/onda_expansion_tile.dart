import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_surf_app/dao/indicador_dao.dart';
import 'package:video_surf_app/dao/tipo_acao_dao.dart';
import 'package:video_surf_app/model/indicador.dart';
import 'package:video_surf_app/model/onda.dart';
import 'package:video_surf_app/model/tipo_acao.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'package:video_surf_app/providers/onda_provider.dart';

class OndaListTile extends StatefulWidget {
  const OndaListTile({
    super.key,
    required this.onda,
    required this.index,
    required this.isExpanded,
    required this.onExpansionChanged,
    this.onExcluirOnda,
    this.onExcluirManobra,
    this.onIrParaTempo,
  });

  final Onda onda;
  final int index;
  final bool isExpanded;
  final void Function(bool expanded) onExpansionChanged;
  final void Function(Onda onda)? onExcluirOnda;
  final void Function(int idManobra)? onExcluirManobra;
  final void Function(int tempoMs)? onIrParaTempo;

  @override
  State<OndaListTile> createState() => _OndaListTileState();
}

class _OndaListTileState extends State<OndaListTile> {
  final Map<int, Future<Indicador?>> _indicadoresCache = {};
  final Map<int, Future<TipoAcao?>> _tipoAcoesCache = {};

  late bool isExpanded;

  @override
  void initState() {
    isExpanded = widget.isExpanded;
    super.initState();
  }

  Future<void> _confirmarExclusao({
    required BuildContext context,
    required String titulo,
    required String mensagem,
    required VoidCallback onConfirmar,
  }) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        content: Text(mensagem, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(backgroundColor: Colors.teal[700]),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );
    if (confirmar == true) onConfirmar();
  }

  String formatTempo(int tempoMs) {
    final totalSeconds = (tempoMs / 1000).floor();
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final OndaProvider ondaProvider = Provider.of<OndaProvider>(context);
    bool isOndaAtual =
        ondaProvider.onda != null &&
        ondaProvider.onda!.ondaId == widget.onda.ondaId;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.teal[900],
        borderRadius: BorderRadius.circular(12),
        border: isOndaAtual
            ? Border.all(color: Colors.tealAccent, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
          ),
        ),
        child: ExpansionTile(
          key: PageStorageKey<int>(widget.onda.ondaId!),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() => isExpanded = expanded);
            widget.onExpansionChanged(expanded);
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          title: GestureDetector(
            onTap: () {
              if (widget.onIrParaTempo != null &&
                  widget.onda.manobrasAvaliadas.isNotEmpty) {
                final tempoMs = widget.onda.manobrasAvaliadas.first.tempoMs;
                widget.onIrParaTempo!(tempoMs);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Onda ${widget.index + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.onIrParaTempo != null &&
                        widget.onda.manobrasAvaliadas.isNotEmpty) {
                      final tempoMs =
                          widget.onda.manobrasAvaliadas.first.tempoMs;
                      widget.onIrParaTempo!(tempoMs);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Icon(Icons.timer_sharp, color: Colors.white70),
                      Text(
                        widget.onda.manobrasAvaliadas.isNotEmpty
                            ? formatTempo(
                                widget.onda.manobrasAvaliadas.first.tempoMs,
                              )
                            : "00:00",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                Text(
                  "${widget.onda.manobrasAvaliadas.length} ${widget.onda.manobrasAvaliadas.length == 1 ? "manobra" : "manobras"}",
                  style: const TextStyle(color: Colors.white70),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.insights, color: Colors.tealAccent),
                    const SizedBox(width: 4),
                    Text(
                      "${widget.onda.mediaDesempenhoPercent().toStringAsFixed(0)}%",
                      style: const TextStyle(color: Colors.tealAccent),
                    ),
                  ],
                ),

                widget.onda.terminouCaindo
                    ? SizedBox(
                        width: 103,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Card(
                              color: Colors.grey.shade700,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 8,
                                ),
                                child: Row(
                                  spacing: 4,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.warning_amber_rounded, size: 16),
                                    Text(
                                      "Caiu",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        width: 103,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Card(
                              color: Colors.teal.shade600,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 8,
                                ),
                                child: Row(
                                  spacing: 4,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.flag_rounded, size: 16),
                                    Text(
                                      "Finalizou",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                PopupMenuButton<String>(
                  color: Colors.grey[850],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  icon: const Icon(Icons.more_vert, color: Colors.white70),
                  onSelected: (value) {
                    if (value == 'excluir') {
                      _confirmarExclusao(
                        context: context,
                        titulo: 'Excluir onda',
                        mensagem:
                            'Tem certeza de que deseja excluir esta onda e todas as manobras associadas?',
                        onConfirmar: () =>
                            widget.onExcluirOnda?.call(widget.onda),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'excluir',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text(
                            'Excluir onda',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          children: widget.onda.manobrasAvaliadas.map((manobra) {
            return Card(
              color: Colors.teal[800],
              margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ExpansionTile(
                initiallyExpanded: false,
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                title: FutureBuilder<TipoAcao?>(
                  future: _tipoAcoesCache.putIfAbsent(
                    manobra.idTipoAcao,
                    () => TipoAcaoDao().getById(manobra.idTipoAcao),
                  ),
                  builder: (context, snapshot) {
                    final tipoNome = snapshot.data?.nome ?? 'Carregando...';
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 90,
                          child: Text(
                            tipoNome,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.insights, color: Colors.tealAccent),
                            const SizedBox(width: 4),
                            Text(
                              "${manobra.mediaDesempenhoPercent().toStringAsFixed(0)}%",
                              style: const TextStyle(color: Colors.tealAccent),
                            ),
                          ],
                        ),

                        PopupMenuButton<String>(
                          color: Colors.grey[850],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onSelected: (value) {
                            if (value == 'excluir') {
                              _confirmarExclusao(
                                context: context,
                                titulo: 'Excluir manobra',
                                mensagem:
                                    'Tem certeza de que deseja excluir esta manobra?',
                                onConfirmar: () => widget.onExcluirManobra
                                    ?.call(manobra.avaliacaoManobraId!),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'excluir',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Excluir manobra',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                children: manobra.avaliacaoIndicadores.map((indicador) {
                  return Container(
                    color: Colors.teal[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder<Indicador?>(
                          future: _indicadoresCache.putIfAbsent(
                            indicador.idIndicador,
                            () => IndicadorDao().getIndicadorById(
                              indicador.idIndicador,
                            ),
                          ),
                          builder: (context, asyncSnapshot) {
                            return Text(
                              asyncSnapshot.data?.descricao ?? '...',
                              style: const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                        Text(
                          "${(indicador.classificacao.valor * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(color: Colors.tealAccent),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
