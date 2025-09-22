import 'package:flutter/material.dart';
import 'package:video_surf_app/model/surfista.dart';

class PerfilAtleta extends StatelessWidget {
  const PerfilAtleta({super.key, required this.surfista});
  final Surfista surfista;
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: Colors.white);
    return Container(
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
        child: Card(
          color: Theme.of(context).colorScheme.primary,
          // decoration: BoxDecoration(
          //   color: Theme.of(context).colorScheme.primary,
          //   border: Border.all(color: Colors.white, width: 2),
          //   borderRadius: BorderRadius.all(Radius.circular(10)),
          // ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 8,
              children: [
                surfista.iconeSurfista(Colors.white),
                Column(
                  children: [
                    Text(surfista.nome, style: textStyle),
                    Text("Base: ${surfista.base.name}", style: textStyle),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
