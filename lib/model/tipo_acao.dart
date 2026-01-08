import 'package:video_surf_app/model/enum/side.dart';
import 'package:video_surf_app/model/indicador.dart';

class TipoAcao {
  final int? tipoAcaoId;
  final String nome;
  final String? nivel;

  Side side;

  /// relação opcional: lista de indicadores dessa ação
  final List<Indicador>? indicadores;

  TipoAcao({
    this.tipoAcaoId,
    required this.nome,
     this.nivel,
    required this.side,
    this.indicadores,
  });

  Map<String, dynamic> toMap() {
    return {
      TipoAcaoFields.tipoAcaoId: tipoAcaoId,
      TipoAcaoFields.nome: nome,
      TipoAcaoFields.nivel: nivel,
      TipoAcaoFields.side: side.nameDb,
      // não persiste indicadores aqui, só na tabela indicador
    };
  }

  factory TipoAcao.fromMap(Map<String, dynamic> map) {
    return TipoAcao(
      tipoAcaoId: map[TipoAcaoFields.tipoAcaoId] as int?,
      nome: map[TipoAcaoFields.nome] as String,
      nivel: map[TipoAcaoFields.nivel] as String,
      side: SideExt.fromDb(map[TipoAcaoFields.side] as String),
      indicadores: null, // só preenche quando carregar via JOIN
    );
  }

  TipoAcao copyWith({
    int? tipoAcaoId,
    String? nome,
    String? nivel,
    Side? side,
    List<Indicador>? indicadores,
  }) {
    return TipoAcao(
      tipoAcaoId: tipoAcaoId ?? this.tipoAcaoId,
      nome: nome ?? this.nome,
      nivel: nivel ?? this.nivel,
      side: side ?? this.side,
      indicadores: indicadores ?? this.indicadores,
    );
  }
}

class TipoAcaoFields {
  static const String tableName = 'tipoacao';

  static const String tipoAcaoId = 'tipoAcao_id';
  static const String nome = 'nome';
  static const String nivel = 'nivel';
  static const String side = 'side';

  static const List<String> values = [tipoAcaoId, nome, nivel, side];
}
