import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/model/video.dart';
import 'package:video_surf_app/dao/video_dao.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Galeria de Vídeos - ${widget.surfista.nome}"),
      ),
      body: FutureBuilder<List<Video>>(
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Platform.isWindows
                      ? Icon(
                          Icons.play_circle_fill,
                          size: 50,
                          color: Theme.of(context).colorScheme.primary,
                        )
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

                  title: Text(video.local.toString()),
                  subtitle: Text(_formatDate(video.data)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await videoDao.delete(video.videoId!);
                      _loadVideos();
                      setState(() {});
                    },
                  ),
                  onTap: () {
                    // Aqui você pode abrir um player ou detalhar o vídeo
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Abrir vídeo: ${video.path}")),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
