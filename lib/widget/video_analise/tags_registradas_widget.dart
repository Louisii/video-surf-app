import 'package:flutter/material.dart';
import 'package:video_surf_app/dao/avaliacao_manobra_dao.dart';
import 'package:video_surf_app/model/avaliacao_manobra.dart';

class TagsRegistradasWidget extends StatefulWidget {
  final int idVideo;

  const TagsRegistradasWidget({super.key, required this.idVideo});

  @override
  State<TagsRegistradasWidget> createState() => _TagsRegistradasWidgetState();
}

class _TagsRegistradasWidgetState extends State<TagsRegistradasWidget> {
  late final AvaliacaoManobraDao avaliacaoManobraDao;

  @override
  void initState() {
    super.initState();
    avaliacaoManobraDao = AvaliacaoManobraDao();
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder();

    // Container(
    //   height: 200,
    //   padding: const EdgeInsets.all(8),
    //   decoration: BoxDecoration(
    //     color: Colors.grey[850],
    //     border: Border.all(color: Colors.black87),
    //     // borderRadius: BorderRadius.circular(12),
    //   ),
    //   child: FutureBuilder<List<AvaliacaoManobra>>(
    //     future: avaliacaoManobraDao.findByVideo(widget.idVideo),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const Center(child: CircularProgressIndicator());
    //       } else if (snapshot.hasError) {
    //         return Center(
    //           child: Text(
    //             'Erro ao carregar tags: ${snapshot.error}',
    //             style: const TextStyle(color: Colors.red),
    //           ),
    //         );
    //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
    //         return const Center(
    //           child: Text(
    //             'Nenhuma avaliação registrada',
    //             style: TextStyle(color: Colors.white70),
    //           ),
    //         );
    //       }

    //       List<AvaliacaoManobra> avaliacoesManobras = snapshot.data!;
    //       print(avaliacoesManobras.length);
    //       return Text("has data");
    //       // return Column(
    //       //   children: avaliacoesManobras
    //       //       .map(
    //       //         (avaliacaoManobra) =>
    //       //             Text(avaliacaoManobra.tipoAcao?.nome ?? "-"),
    //       //       )
    //       //       .toList(),
    //       // );

    //       //  Column(
    //       //   children: [
    //       //     Row(children: [Flexible(child: Text("Manobra"))]),
    //       //     Expanded(
    //       //       child: SingleChildScrollView(
    //       //         child: Column(
    //       //           children: avaliacoesManobras
    //       //               .map(
    //       //                 (avaliacaoManobra) => Row(
    //       //                   children: [
    //       //                     Text(avaliacaoManobra.tipoAcao?.nome ?? "-"),
    //       //                   ],
    //       //                 ),
    //       //               )
    //       //               .toList(),
    //       //         ),
    //       //       ),
    //       //     ),
    //       //   ],
    //       // );
    //     },
    //   ),
    // );
  }
}
