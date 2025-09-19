import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as mkv;

import 'package:video_surf_app/model/atleta.dart';
import 'package:video_surf_app/model/video.dart';
import 'package:video_surf_app/widget/custom_appbar_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io'; // <<--- necessário para File, Directory etc.
import 'package:path_provider/path_provider.dart'; // <<--- necessário

class VideoAnaliseScreen extends StatefulWidget {
  final Atleta atleta;
  final Video video;

  const VideoAnaliseScreen({
    super.key,
    required this.video,
    required this.atleta,
  });

  @override
  State<VideoAnaliseScreen> createState() => _VideoAnaliseScreenState();
}

class _VideoAnaliseScreenState extends State<VideoAnaliseScreen> {
  late final player = Player();
  late final controller = mkv.VideoController(player);

  final List<double> speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  double currentSpeed = 1.0;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = false;

  final Duration frameStep = const Duration(milliseconds: 33);

  // Lista para guardar os screenshots
  final List<Uint8List> screenshots = [];

  @override
  void initState() {
    super.initState();
    player.open(Media(widget.video.path));

    player.stream.position.listen((pos) {
      setState(() => position = pos);
    });
    player.stream.duration.listen((dur) {
      setState(() => duration = dur);
    });
    player.stream.playing.listen((playing) {
      setState(() => isPlaying = playing);
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "${d.inHours > 0 ? '${twoDigits(d.inHours)}:' : ''}$minutes:$seconds";
  }

  Future<void> _takeScreenshot() async {
    final data = await player.screenshot();
    if (data != null) {
      setState(() {
        screenshots.insert(0, data); // adiciona no topo
      });

      final directory =
          await getDownloadsDirectory(); // pasta Downloads no Windows
      if (directory != null) {
        final now = DateTime.now();
        final dateStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        String baseName = '${widget.atleta.nomeSnakeCase}_$dateStr';

        int counter = 1;
        File file;
        do {
          file = File('${directory.path}/${baseName}_$counter.png');
          counter++;
        } while (file.existsSync()); // incrementa até achar um nome livre

        await file.writeAsBytes(data);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Screenshot salvo em: ${file.path}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppbarWidget(),
      body: Row(
        children: [
          // Parte principal com vídeo e controles
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: mkv.Video(
                        controller: controller,
                        controls: mkv.NoVideoControls,
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey[900],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      // Barra de progresso
                      Row(
                        children: [
                          Text(
                            _formatDuration(position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              activeColor: Colors.blueAccent,
                              inactiveColor: Colors.grey,
                              min: 0,
                              max: duration.inMilliseconds.toDouble(),
                              value: position.inMilliseconds
                                  .clamp(0, duration.inMilliseconds.toDouble())
                                  .toDouble(),
                              onChanged: (value) {
                                player.seek(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Controles + botão screenshot
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.skip_previous,
                              color: Colors.white,
                            ),
                            tooltip: "Voltar 1 quadro",
                            onPressed: () {
                              final target = position - frameStep;
                              if (target > Duration.zero) {
                                player.seek(target);
                              } else {
                                player.seek(Duration.zero);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.replay_10,
                              color: Colors.white,
                            ),
                            tooltip: "Voltar 10s",
                            onPressed: () => player.seek(
                              position - const Duration(seconds: 10),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              size: 40,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              isPlaying ? player.pause() : player.play();
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.forward_10,
                              color: Colors.white,
                            ),
                            tooltip: "Avançar 10s",
                            onPressed: () => player.seek(
                              position + const Duration(seconds: 10),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.skip_next,
                              color: Colors.white,
                            ),
                            tooltip: "Avançar 1 quadro",
                            onPressed: () => player.seek(position + frameStep),
                          ),
                          const SizedBox(width: 20),
                          PopupMenuButton<double>(
                            initialValue: currentSpeed,
                            onSelected: (value) {
                              setState(() => currentSpeed = value);
                              player.setRate(value);
                            },
                            color: Colors.grey[850],
                            itemBuilder: (context) {
                              return speeds.map((speed) {
                                return PopupMenuItem<double>(
                                  value: speed,
                                  child: Text(
                                    "${speed}x",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: speed == currentSpeed
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.speed, color: Colors.white),
                                Text(
                                  "${currentSpeed}x",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Botão para tirar print
                          IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            tooltip: "Capturar frame",
                            onPressed: _takeScreenshot,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Barra lateral com prints
          // Barra lateral com prints
          Container(
            width: 120,
            color: Colors.grey[850],
            child: ListView.builder(
              itemCount: screenshots.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GestureDetector(
                    onTap: () {
                      // Dentro do GestureDetector -> onTap, após abrir o Dialog
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.black87,
                          insetPadding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InteractiveViewer(
                                child: Image.memory(
                                  screenshots[index],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.memory(
                        screenshots[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
