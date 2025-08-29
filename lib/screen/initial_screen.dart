import 'package:flutter/material.dart';
import 'package:video_surf_app/widget/add_videos_widget.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Bem vindo!",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AddVideosWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
