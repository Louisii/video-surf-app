import 'package:flutter/material.dart';
import 'package:video_surf_app/dao/tipo_acao_dao.dart';
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
      manobraSelecionada = null; // reseta seleção quando troca nível
    });
  }

  Future<void> _selecionarManobra(TipoAcao manobra) async {
    if (manobra.tipoAcaoId == null) return;

    final carregada = await dao.findWithIndicadores(manobra.tipoAcaoId!);
    setState(() {
      manobraSelecionada = carregada;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LadoOndaWidget(),

            const SizedBox(height: 20),
            Text(
              "Manobras",
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),

            // filtros por nível
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

            const SizedBox(height: 8),

            // lista de manobras
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: manobras.map((m) {
                final selecionado =
                    manobraSelecionada?.tipoAcaoId == m.tipoAcaoId;
                return GestureDetector(
                  onTap: () => _selecionarManobra(m), // 👈 carrega indicadores
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

            const SizedBox(height: 16),

            // indicadores da manobra selecionada
            if (manobraSelecionada != null) ...[
              Text(
                "Indicadores",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              (manobraSelecionada!.indicadores != null &&
                      manobraSelecionada!.indicadores!.isNotEmpty)
                  ? Wrap(
                      children: manobraSelecionada!.indicadores!.map((i) {
                        return Card(
                          color: Colors.grey[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              i.descricao,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : Text(
                      "Nenhum indicador encontrado",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}
