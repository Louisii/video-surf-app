import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as mkv;

import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/model/video.dart';
import 'package:video_surf_app/widget/custom_appbar_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_surf_app/widget/video_analise/local_widget.dart';
import 'package:video_surf_app/widget/video_analise/perfil_atleta.dart';
import 'dart:io'; // <<--- necessário para File, Directory etc.
import 'package:video_surf_app/widget/video_analise/screenshots_widget.dart';
import 'package:video_surf_app/widget/video_analise/tagging/tagging_widget.dart';
import 'package:video_surf_app/widget/video_analise/tags_registradas/tags_registradas_widget.dart';
import 'package:video_surf_app/widget/video_analise/video_player_widget.dart'; // <<--- necessário

class VideoAnaliseScreen extends StatefulWidget {
  final Surfista surfista;
  final Video video;

  const VideoAnaliseScreen({
    super.key,
    required this.video,
    required this.surfista,
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

  int reloadKey = 0;

  @override
  void initState() {
    super.initState();
    player.open(Media(widget.video.path));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                    child: VideoPlayerWidget(
                      surfista: widget.surfista,
                      player: player,
                      controller: controller,
                      onPositionChanged: (pos) => position = pos,
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: TagsRegistradasWidget(
                          key: ValueKey(reloadKey),
                          idVideo: widget.video.videoId!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            //barra lateral com tags e indicadors
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PerfilAtleta(surfista: widget.surfista),
                    if (widget.video.local != null)
                      PerfilLocal(local: widget.video.local!),
                  ],
                ),

                Expanded(
                  child: TaggingWidget(
                    surfista: widget.surfista,
                    video: widget.video,
                    getVideoPosition: () => position,
                    onNovaTagCriada: _onNovaTagCriada,
                  ),
                ),
              ],
            ),
            // // Barra lateral com prints
            // ScreenshotsWidget(screenshots: screenshots),
          ],
        ),
      ),
    );
  }

  void _onNovaTagCriada() {
    setState(() {
      reloadKey++; // força rebuild com nova Key
    });
  }
}
