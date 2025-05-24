import '../entities/diagnosis.dart';

abstract class DiagnosisRepository {
  Future<Diagnosis> getDiagnosis(List<String> symptoms, [Map<String, dynamic>? profile]);
}
