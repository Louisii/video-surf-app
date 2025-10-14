import 'package:flutter/material.dart';
import 'package:video_surf_app/model/avaliacao_manobra.dart';
import 'package:video_surf_app/model/onda.dart';

class OndaProvider with ChangeNotifier {
  Onda? _onda;

  Onda? get onda => _onda;

  addManobraAvaliada(AvaliacaoManobra manobraAvaliada) {
    if (_onda != null) {
      _onda!.manobrasAvaliadas.add(manobraAvaliada);
    }
    notifyListeners();
  }

  updateTerminouCaindo(bool terminouCaindo) {
    if (onda != null) {
      _onda!.terminouCaindo = terminouCaindo;
      notifyListeners();
    }
  }

  void setOnda(Onda? onda) {
    _onda = onda;
    notifyListeners();
  }
}
