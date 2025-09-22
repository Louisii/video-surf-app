import 'package:flutter/material.dart';
import 'package:video_surf_app/dao/tipo_acao_dao.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/model/tipo_acao.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.grey[900],
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: niveis.map((nivel) {
                final selecionado = nivel == nivelSelecionado;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      nivelSelecionado = nivel;
                    });
                    _loadManobras(nivel);
                  },
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
                        nivel,
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
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: manobras.map((m) {
                return Card(
                  color: Colors.teal.shade300.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      m.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
