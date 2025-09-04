import 'package:flutter/material.dart';
import 'package:video_surf_app/screen/surfistar_screen.dart';

class CustomDrawerWidget extends StatelessWidget {
  const CustomDrawerWidget({super.key});

  @override
  Drawer build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Surf Tag",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.surfing,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 34,
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context); // fecha o drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SurfistarScreen(),
                ),
              );
            },
            leading: const Icon(Icons.surfing),
            title: const Text("Surfistas"),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
            },
            leading: const Icon(Icons.beach_access),
            title: const Text("Picos"),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
            },
            leading: const Icon(Icons.bookmarks_rounded),
            title: const Text("Indicadores"),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
            },
            leading: const Icon(Icons.video_library),
            title: const Text("Vídeos"),
          ),
        ],
      ),
    );
  }
}
