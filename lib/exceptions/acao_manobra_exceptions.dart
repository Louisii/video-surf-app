class AcaoManobraException implements Exception {
  final String message;
  AcaoManobraException(this.message);

  @override
  String toString() => "Erro ao criar acao/manobra: $message";
}