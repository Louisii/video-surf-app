import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_surf_app/dao/onda_dao.dart';
import 'package:video_surf_app/model/onda.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/model/video.dart';
import 'package:video_surf_app/dao/video_dao.dart';
import 'package:intl/intl.dart';
import 'package:video_surf_app/screen/video_analise_screen.dart';
import 'package:video_surf_app/widget/custom_appbar_widget.dart';
import 'package:video_surf_app/widget/novo_video_dialog.dart';

class VideosScreen extends StatefulWidget {
  final Surfista surfista;

  const VideosScreen({super.key, required this.surfista});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final videoDao = VideoDao();
  late Future<List<Video>> videosFuture;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  void _loadVideos() {
    videosFuture = videoDao.getBySurfistaId(widget.surfista.atletaId!);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    Surfista surfista = widget.surfista;
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: CustomAppbarWidget(),
      body: Padding(
        padding: EdgeInsets.all(18.0),
        child: Column(
          spacing: 8,
          children: [
            Row(
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
                  width: 160,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 8,
                    children: [
                      SizedBox(height: 8),
                      Column(
                        spacing: 8,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          NovoVideoDialog(surfista: surfista),
                                    );

                                    if (result == true) {
                                      setState(() {});
                                    }
                                  },
                                  icon: Icon(Icons.library_add),
                                  label: Text("Novo Vídeo"),
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
            ),

            Expanded(
              child: FutureBuilder<List<Video>>(
                future: videosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao carregar vídeos: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Nenhum vídeo encontrado"));
                  }

                  final videos = snapshot.data!;

                  return Column(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            Video video = videos[index];
                            return FutureBuilder(
                              future: OndaDao().findByVideo(video.videoId!),
                              builder: (context, asyncSnapshot) {
                                if (asyncSnapshot.hasData) {
                                  video.ondas = asyncSnapshot.data!;
                                  return _buildVideoCard(
                                    video,
                                    context,
                                    surfista,
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildVideoCard(
    Video video,
    BuildContext context,
    Surfista surfista,
  ) {
    return ElevatedButton(
      onPressed: () {
        if (video.path.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VideoAnaliseScreen(video: video, surfista: surfista),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Caminho do vídeo não disponível")),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 16,
              children: [
                Platform.isWindows
                    ? Icon(Icons.play_circle_fill, size: 50)
                    : FutureBuilder<Uint8List?>(
                        future: video.videoThumbnail,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasData) {
                            return Image.memory(
                              snapshot.data!,
                              width: 100,
                              height: 70,
                              fit: BoxFit.cover,
                            );
                          } else {
                            return Icon(
                              Icons.play_circle_fill,
                              size: 50,
                              color: Theme.of(context).colorScheme.primary,
                            );
                          }
                        },
                      ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.local.toString(),
                      style: TextStyle(fontSize: 17),
                    ),
                    Text(_formatDate(video.data)),
                  ],
                ),
              ],
            ),

            Row(
              spacing: 16,
              children: [
                if (video.ondas.isNotEmpty)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal.shade800,
                    ),
                    onPressed: () {},
                    child: Row(
                      spacing: 4,
                      children: [
                        Icon(Icons.tsunami),
                        Text(
                          video.ondas.length != 1
                              ? "${video.ondas.length} ondas"
                              : "${video.ondas.length} onda".toString(),
                        ),
                        Text(" | "),
                        Icon(Icons.insights),
                        Text(
                          "${video.mediaDesempenhoPercent().toStringAsFixed(0)}%",
                        ),
                      ],
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'excluir') {
                      await videoDao.delete(video.videoId!);
                      _loadVideos();
                      setState(() {});
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'excluir',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Excluir"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
