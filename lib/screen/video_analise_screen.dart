import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_surf_app/widget/custom_appbar_widget.dart';

class VideoAnaliseScreen extends StatefulWidget {
  final String videoPath;

  const VideoAnaliseScreen({super.key, required this.videoPath});

  @override
  State<VideoAnaliseScreen> createState() => _VideoAnaliseScreenState();
}

class _VideoAnaliseScreenState extends State<VideoAnaliseScreen> {
  late final player = Player();
  late final controller = VideoController(player);

  final List<double> speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  double currentSpeed = 1.0;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = false;

  // Supondo 30 FPS (~33ms por quadro)
  final Duration frameStep = const Duration(milliseconds: 33);

  @override
  void initState() {
    super.initState();
    player.open(Media(widget.videoPath));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppbarWidget(),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Video(controller: controller, controls: NoVideoControls),
              ),
            ),
          ),
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          // aqui você pode atualizar a UI em tempo real enquanto arrasta
                          setState(() {
                            position = Duration(milliseconds: value.toInt());
                          });
                        },
                        onChangeEnd: (value) async {
                          // aqui aplica o seek real no player
                          await player.seek(
                            Duration(milliseconds: value.toInt()),
                          );
                        },
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Controles de reprodução
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
                        final newPosition = position - frameStep;
                        if (newPosition < Duration.zero) {
                          player.seek(Duration.zero);
                        } else {
                          player.seek(newPosition);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white),
                      tooltip: "Voltar 10s",
                      onPressed: () async {
                        final current = player.state.position;
                        await player.seek(
                          current - const Duration(seconds: 10),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                        size: 40,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        if (isPlaying) {
                          await player.pause();
                        } else {
                          await player.play();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10, color: Colors.white),
                      tooltip: "Avançar 10s",
                      onPressed: () async {
                        final current = player.state.position;
                        await player.seek(
                          current + const Duration(seconds: 10),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      tooltip: "Avançar 1 quadro",
                      onPressed: () async {
                        final current = player.state.position;
                        await player.seek(current + frameStep);
                      },
                    ),
                    const SizedBox(width: 20),
                    // Seletor de velocidade
                    PopupMenuButton<double>(
                      initialValue: currentSpeed,
                      onSelected: (value) async {
                        setState(() => currentSpeed = value);
                        await player.setRate(value);
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
