import 'package:flutter/material.dart';

class CustomAppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Row(
        mainAxisSize: MainAxisSize.min,
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
    );
  }

  // Define a altura da AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
