class PredictionException implements Exception {
  final String message;

  PredictionException(this.message);

  @override
  String toString() => 'PredictionException: $message';
}
