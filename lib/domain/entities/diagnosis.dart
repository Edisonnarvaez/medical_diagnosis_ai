class Diagnosis {
  final String result;
  final double confidence;
  final List<String> recommendations;

  Diagnosis({
    required this.result,
    required this.confidence,
    required this.recommendations,
  });
}
