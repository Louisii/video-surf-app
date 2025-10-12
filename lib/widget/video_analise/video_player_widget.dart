import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as mkv;
import 'package:path_provider/path_provider.dart';
import 'package:video_surf_app/model/surfista.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Player player;
  final mkv.VideoController controller;
  final ValueChanged<Duration>? onPositionChanged;
  final Surfista surfista;

  const VideoPlayerWidget({
    super.key,
    required this.player,
    required this.controller,
    required this.surfista,
    this.onPositionChanged,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = false;

  // Lista para guardar os screenshots
  final List<Uint8List> screenshots = [];

  final List<double> speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  double currentSpeed = 1.0;
  final Duration frameStep = const Duration(milliseconds: 33);

  @override
  void initState() {
    super.initState();

    widget.player.stream.position.listen((pos) {
      if (mounted) {
        setState(() => position = pos);
        widget.onPositionChanged?.call(pos);
      }
    });

    widget.player.stream.duration.listen((dur) {
      if (mounted) setState(() => duration = dur);
    });

    widget.player.stream.playing.listen((playing) {
      if (mounted) setState(() => isPlaying = playing);
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "${d.inHours > 0 ? '${twoDigits(d.inHours)}:' : ''}$minutes:$seconds";
  }

  Future<void> _takeScreenshot() async {
    final data = await widget.player.screenshot();
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
        String baseName = '${widget.surfista.nomeSnakeCase}_$dateStr';

        int counter = 1;
        File file;
        do {
          file = File('${directory.path}/${baseName}_$counter.png');
          counter++;
        } while (file.existsSync()); // incrementa até achar um nome livre

        await file.writeAsBytes(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Screenshot salvo em: ${file.path}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;

    return Column(
      children: [
        // --- Player de vídeo ---
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: mkv.Video(
                controller: widget.controller,
                controls: mkv.NoVideoControls,
              ),
            ),
          ),
        ),

        // --- Controles ---
        Container(
          color: Colors.grey[900],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            children: [
              // Barra de progresso
              Row(
                children: [
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
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
                        player.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),

              // Controles inferiores
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    tooltip: "Voltar 1 quadro",
                    onPressed: () {
                      final target = position - frameStep;
                      player.seek(
                        target > Duration.zero ? target : Duration.zero,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.white),
                    tooltip: "Voltar 10s",
                    onPressed: () =>
                        player.seek(position - const Duration(seconds: 10)),
                  ),
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle : Icons.play_circle,
                      size: 40,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      isPlaying ? player.pause() : player.play();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.white),
                    tooltip: "Avançar 10s",
                    onPressed: () =>
                        player.seek(position + const Duration(seconds: 10)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    tooltip: "Avançar 1 quadro",
                    onPressed: () => player.seek(position + frameStep),
                  ),
                  const SizedBox(width: 20),

                  // Velocidade
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

                  // Screenshot
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    tooltip: "Capturar frame",
                    onPressed: _takeScreenshot,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
