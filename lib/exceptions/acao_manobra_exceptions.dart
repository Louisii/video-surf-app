class AvaliacaoManobraException implements Exception {
  final String message;
  AvaliacaoManobraException(this.message);

  @override
  String toString() => "Erro ao criar acao/manobra: $message";
}
