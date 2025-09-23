import 'package:flutter/material.dart';
import 'package:video_surf_app/dao/tipo_acao_dao.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/model/tipo_acao.dart';
import 'package:video_surf_app/widget/video_analise/filtro_por_nivel.dart';
import 'package:video_surf_app/widget/video_analise/lado_onda_widget.dart';

class TaggingWidget extends StatefulWidget {
  const TaggingWidget({super.key, required this.surfista});
  final Surfista surfista;

  @override
  State<TaggingWidget> createState() => _TaggingWidgetState();
}

class _TaggingWidgetState extends State<TaggingWidget> {
  final dao = TipoAcaoDao();
  List<String> niveis = [];
  String? nivelSelecionado;
  List<TipoAcao> manobras = [];
  TipoAcao? manobraSelecionada;

  // estado da classificação
  Map<int, Classificacao?> classificacoes = {}; // indicadorId -> classificação

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

  void _abrirClassificacao(int indicadorId, String nomeIndicador) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.grey[900],
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 4),
              Text(
                nomeIndicador, // 👈 mostra o indicador
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.grey),

              // Opções de classificação
              ...Classificacao.values.map((c) {
                final selecionado = classificacoes[indicadorId] == c;
                return Card(
                  color: selecionado
                      ? Colors.greenAccent.withOpacity(0.15)
                      : Colors.grey[850],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selecionado
                          ? Colors.greenAccent
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    trailing: estrelasClassificacao(c),

                    title: Row(
                      children: [
                        Text(
                          c.label,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: selecionado
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        classificacoes[indicadorId] = c;
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget estrelasClassificacao(Classificacao c) {
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
          size: 24,
        );
      }),
    );
  }

  void salvar() {
    // TODO: implementar persistência no banco
    // você já terá: manobraSelecionada, classificacoes[indicadorId] para cada indicador
    debugPrint("Salvar avaliação da manobra ${manobraSelecionada?.nome}");
    classificacoes.forEach((id, c) {
      debugPrint("Indicador $id => ${c?.nameDb}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 324,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: const Border(left: BorderSide(color: Colors.black87, width: 2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LadoOndaWidget(),

            Text(
              "Manobras",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),

            FiltroPorNivel(
              niveis: niveis,
              nivelSelecionado: nivelSelecionado,
              onSelecionarNivel: (nivel) {
                setState(() {
                  nivelSelecionado = nivel;
                });
                _loadManobras(nivel);
              },
            ),

            // lista de manobras
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

            if (manobraSelecionada != null) ...[
              Text(
                "Indicadores",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: Colors.white),
              ),

              if (manobraSelecionada!.indicadores != null &&
                  manobraSelecionada!.indicadores!.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: manobraSelecionada!.indicadores!.map((i) {
                        final classificacao = classificacoes[i.indicadorId];
                        return GestureDetector(
                          onTap: () =>
                              _abrirClassificacao(i.indicadorId!, i.descricao),
                          child: Card(
                            color: Colors.grey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      i.descricao,
                                      maxLines: 3,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (classificacao != null)
                                    Text(
                                      classificacao.label,
                                      style: const TextStyle(
                                        color: Colors.tealAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
              else
                Text(
                  "Nenhum indicador encontrado",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),

              if (classificacoes.isNotEmpty)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: salvar,
                    icon: const Icon(Icons.save),
                    label: const Text("Salvar Avaliação"),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
