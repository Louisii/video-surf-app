import 'package:flutter/material.dart';
import 'package:video_surf_app/model/surfista.dart';

class PerfilAtleta extends StatelessWidget {
  const PerfilAtleta({super.key, required this.surfista});
  final Surfista surfista;
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: Colors.white);
    Color foregroundColor = Colors.white;
    return Container(
      width: 324,
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
            Icon(Icons.surfing, size: 40, color: Colors.white),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surfista.nome,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Base: ${surfista.base.name}", style: textStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
