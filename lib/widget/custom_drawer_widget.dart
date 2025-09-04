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
            leading: Icon(
              Icons.surfing,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text("Surfistas"),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
            },
            leading: Icon(
              Icons.beach_access,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text("Picos"),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
            },
            leading: Icon(
              Icons.bookmarks_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text("Indicadores"),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
            },
            leading: Icon(
              Icons.video_library,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text("Vídeos"),
          ),
        ],
      ),
    );
  }
}
