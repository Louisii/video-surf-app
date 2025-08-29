import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../dao/video_dao.dart';
import '../model/video.dart';

class AddVideosWidget extends StatefulWidget {
  const AddVideosWidget({super.key});

  @override
  State<AddVideosWidget> createState() => _AddVideosWidgetState();
}

class _AddVideosWidgetState extends State<AddVideosWidget> {
  final List<Video> videos = [];
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final loadedVideos = await VideoDAO.instance.getAll();
    setState(() {
      videos.addAll(loadedVideos);
    });
  }

  Future<void> _addVideo(String path) async {
    final video = Video(path: path);
    final saved = await VideoDAO.instance.insert(video);
    setState(() {
      videos.add(saved);
    });
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path!;
      await _addVideo(path);
    }
  }

  void _handleDrop(List<String> paths) async {
    for (final path in paths) {
      await _addVideo(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropTarget(
          onDragDone: (details) {
            final paths = details.files.map((f) => f.path).toList();
            _handleDrop(paths);
          },
          onDragEntered: (details) {
            setState(() => _dragging = true);
          },
          onDragExited: (details) {
            setState(() => _dragging = false);
          },
          child: Container(
            height: 150,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _dragging ? Colors.blue.withOpacity(0.3) : Colors.grey[200],
              border: Border.all(
                color: _dragging ? Colors.blue : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Arraste seus vídeos aqui',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _pickVideo,
          child: const Text('Selecionar vídeo no PC'),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return ListTile(
                leading: const Icon(Icons.video_file),
                title: Text(video.path.split('/').last),
                subtitle: Text(video.path),
              );
            },
          ),
        ),
      ],
    );
  }
}
