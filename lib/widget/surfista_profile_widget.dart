import 'package:flutter/material.dart';
import 'package:video_surf_app/dao/onda_dao.dart';
import 'package:video_surf_app/dao/surfista_dao.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/screen/surfista_relatorio_screen.dart';
import 'package:video_surf_app/widget/dialogs/novo_video_dialog.dart';

class SurfistaProfileWidget extends StatefulWidget {
  const SurfistaProfileWidget({super.key, required this.surfista});
  final Surfista surfista;

  @override
  State<SurfistaProfileWidget> createState() => _SurfistaProfileWidgetState();
}

class _SurfistaProfileWidgetState extends State<SurfistaProfileWidget> {
  @override
  Widget build(BuildContext context) {
    Surfista surfista = widget.surfista;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: OndaDao().findBySurfista(widget.surfista.surfistaId!),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.hasData) {
              surfista.ondas = asyncSnapshot.data!;
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 16,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.surfing,
                        size: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          surfista.nome,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("CPF: ${surfista.cpf}"),

                            Text("Idade: ${surfista.idade}"),
                            Text(
                              "Data de nascimento: ${surfista.dataNascimentoFormatada}",
                            ),
                            Text("Base: ${surfista.base.name}"),

                            FutureBuilder(
                              future: surfista.nVideosDb,
                              builder: (context, asyncSnapshot) {
                                int n = asyncSnapshot.data ?? 0;
                                return Text(
                                  n != 1 ? "$n vídeos" : "$n vídeo",
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(color: Colors.grey),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  width: 210,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 8,
                    children: [
                      SizedBox(height: 8),
                      Column(
                        spacing: 8,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 80,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    spacing: 8,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final result = await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                NovoVideoDialog(
                                                  surfista: surfista,
                                                ),
                                          );

                                          if (result == true) {
                                            setState(() {});
                                          }
                                        },
                                        icon: Icon(Icons.library_add),
                                        label: Text("Novo Vídeo"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  SurfistaRelatorioScreen(
                                                    surfista: surfista,
                                                  ),
                                            ),
                                          );
                                        },

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.white, // fundo branco
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary, // texto + ícones
                                          elevation: 0, // remove sombra
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary, // borda primary
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ), // ajuste se quiser
                                          ),
                                        ),
                                        child: Row(
                                          spacing: 4,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.tsunami),
                                            Text(
                                              surfista.ondas.length != 1
                                                  ? "${surfista.ondas.length} ondas"
                                                  : "${surfista.ondas.length} onda",
                                            ),
                                            Text(" | "),
                                            Icon(Icons.insights),
                                            Text(
                                              "${surfista.mediaDesempenhoPercent().toStringAsFixed(0)}%",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
