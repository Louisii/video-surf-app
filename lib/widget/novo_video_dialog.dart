import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_surf_app/model/local.dart';
import 'package:video_surf_app/dao/local_dao.dart';
import 'package:video_surf_app/model/video.dart';
import 'package:video_surf_app/dao/video_dao.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:intl/intl.dart';

class NovoVideoDialog extends StatefulWidget {
  final Surfista surfista;

  const NovoVideoDialog({super.key, required this.surfista});

  @override
  State<NovoVideoDialog> createState() => _NovoVideoDialogState();
}

class _NovoVideoDialogState extends State<NovoVideoDialog> {
  File? selectedVideo;
  Local? selectedPico;
  DateTime selectedDateTime = DateTime.now(); // 🔹 começa com data atual

  final localDao = LocalDao();
  final videoDao = VideoDao();

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      if (result != null && result.files.single.path != null) {
        setState(() {
          selectedVideo = File(result.files.single.path!);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Vídeo selecionado com sucesso!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Nenhum vídeo selecionado."),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao selecionar vídeo: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selecionarData() async {
    final DateTime? novaData = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (novaData != null) {
      final TimeOfDay? novoHorario = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (novoHorario != null) {
        setState(() {
          selectedDateTime = DateTime(
            novaData.year,
            novaData.month,
            novaData.day,
            novoHorario.hour,
            novoHorario.minute,
          );
        });
      }
    }
  }

  Future<void> _salvar() async {
    if (selectedVideo == null || selectedPico == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Selecione um vídeo e um pico antes de salvar."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      final novoVideo = Video(
        atletaId: widget.surfista.atletaId!,
        localId: selectedPico!.localId!,
        path: selectedVideo!.path,
        data: selectedDateTime, // ✅ data escolhida
      );

      await videoDao.create(novoVideo);

      if (mounted) {
        Navigator.pop(context, true); // sucesso → fecha o dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vídeo salvo com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao salvar vídeo: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Adicionar novo vídeo"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.video_file),
              label: Text(
                selectedVideo == null
                    ? "Selecionar vídeo"
                    : "Selecionado: ${selectedVideo!.path.split('/').last}",
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 DateTime Picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Data: ${DateFormat('dd/MM/yyyy – HH:mm').format(selectedDateTime)}",
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selecionarData,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Dropdown de Pico
            FutureBuilder<List<Local>>(
              future: localDao.getAll(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return DropdownButtonFormField<Local>(
                  value: selectedPico,
                  items: snapshot.data!.map((local) {
                    return DropdownMenuItem(
                      value: local,
                      child: Text("${local.praia} - ${local.pico}"),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedPico = value),
                  decoration: const InputDecoration(
                    labelText: "Selecionar Pico",
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(onPressed: _salvar, child: const Text("Salvar")),
      ],
    );
  }
}
