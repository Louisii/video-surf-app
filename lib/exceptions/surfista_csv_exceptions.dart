class SurfistaCsvException implements Exception {
  final String message;
  SurfistaCsvException(this.message);

  @override
  String toString() => "Erro ao importar CSV: $message";
}

class CampoAusenteException extends SurfistaCsvException {
  CampoAusenteException(String campo)
    : super("O campo '$campo' está ausente no CSV.");
}

class CpfInvalidoException extends SurfistaCsvException {
  CpfInvalidoException(String cpf)
    : super("O CPF informado '$cpf' é inválido.");
}

class DataInvalidaException extends SurfistaCsvException {
  DataInvalidaException(String data) : super("A data '$data' não é válida.");
}
