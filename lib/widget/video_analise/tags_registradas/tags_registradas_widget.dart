import 'package:flutter/material.dart';
import 'package:video_surf_app/dao/onda_dao.dart';
import 'package:video_surf_app/dao/avaliacao_manobra_dao.dart';
import 'package:video_surf_app/model/onda.dart';
import 'package:video_surf_app/widget/video_analise/tags_registradas/onda_expansion_tile.dart';

class TagsRegistradasWidget extends StatefulWidget {
  final int idVideo;
  final void Function(int tempoMs)? onIrParaTempo;

  const TagsRegistradasWidget({
    super.key,
    required this.idVideo,
    this.onIrParaTempo,
  });

  @override
  State<TagsRegistradasWidget> createState() => _TagsRegistradasWidgetState();
}

class _TagsRegistradasWidgetState extends State<TagsRegistradasWidget> {
  late Future<List<Onda>> _ondasFuture;
  final Map<int, bool> _ondaExpandedMap = {};

  @override
  void initState() {
    super.initState();
    _carregarOndas();
  }

  void _carregarOndas() {
    _ondasFuture = OndaDao().findByVideo(widget.idVideo);
  }

  Future<void> _excluirOnda(Onda onda) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Excluir onda",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Tem certeza que deseja excluir esta onda?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Excluir",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await OndaDao().delete(onda.ondaId!);
      setState(_carregarOndas);
    }
  }

  Future<void> _excluirManobra(int manobraId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Excluir manobra",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Deseja realmente excluir esta manobra?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Excluir",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AvaliacaoManobraDao().delete(manobraId);
      setState(_carregarOndas);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
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
              final bool isExpanded = _ondaExpandedMap[onda.ondaId] ?? false;

              return OndaListTile(
                onda: onda,
                index: index,
                isExpanded: isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _ondaExpandedMap[onda.ondaId!] = expanded;
                  });
                },
                onExcluirOnda: (onda) => _excluirOnda(onda),
                onExcluirManobra: (idManobra) => _excluirManobra(idManobra),
                 onIrParaTempo: widget.onIrParaTempo,
              );
            },
          );
        },
      ),
    );
  }
}
