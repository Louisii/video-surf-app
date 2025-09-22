import 'dart:typed_data';

import 'package:flutter/material.dart';

class ScreenshotsWidget extends StatelessWidget {
  const ScreenshotsWidget({super.key, required this.screenshots});
  final List<Uint8List> screenshots;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: const Border(
          left: BorderSide(
            color: Colors.black87, // cor da borda
            width: 2, // espessura da borda
          ),
        ),
      ),
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
                child: Image.memory(screenshots[index], fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }
}
