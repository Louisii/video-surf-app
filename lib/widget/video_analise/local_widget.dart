import 'package:flutter/material.dart';
import 'package:video_surf_app/model/local.dart';

class PerfilLocal extends StatelessWidget {
  const PerfilLocal({super.key, required this.local});
  final Local local;
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: Colors.white);
    Color foregroundColor = Colors.white;
    return Container(
      width: 220,
      decoration: BoxDecoration(
        // color: Colors.grey[850],
        border: const Border(
          left: BorderSide(
            color: Colors.black87, // cor da borda
            width: 2, // espessura da borda
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 16,
          children: [
            // surfista.iconeSurfista(Colors.white),
            Icon(Icons.beach_access, size: 36, color: Colors.white),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    local.toString(),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("${local.cidade} - ${local.pais}", style: textStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
