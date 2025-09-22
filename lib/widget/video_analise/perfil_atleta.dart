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
      width: 300,
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
          color: Colors.teal.shade400,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surfista.nome,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(color: foregroundColor),
                      ),
                      Text("Base: ${surfista.base.name}", style: textStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
