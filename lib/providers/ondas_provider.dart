import 'package:flutter/material.dart';
import 'package:video_surf_app/model/onda.dart';

class OndasProvider with ChangeNotifier {
  List<Onda> _ondas = [];

  List<Onda> get ondas => _ondas;

  void inicializarOndas(List<Onda> ondas) {
    _ondas = ondas;
  }

  void setOndas(List<Onda> ondas) {
    _ondas = ondas;
    notifyListeners();
  }

  addOnda(Onda onda) {
    _ondas.add(onda);
    notifyListeners();
  }

  updateOnda(Onda onda) {
    for (int i = 0; i < _ondas.length; i++) {
      if (_ondas[i].ondaId == onda.ondaId) {
        _ondas[i] = onda;
        break;
      }
    }
    notifyListeners();
  }

  removeOnda(int ondaId) {
    _ondas.removeWhere((onda) => onda.ondaId == ondaId);
    notifyListeners();
  }

  void removeManobra(int manobraAvaliadaId) {
    // _ondas.removeWhere((onda) => onda.ondaId == ondaId);
    notifyListeners();
  }
}
