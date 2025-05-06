import '../entities/diagnosis.dart';
import '../repositories/diagnosis_repository.dart';

class GetDiagnosisUseCase {
  final DiagnosisRepository repository;

  GetDiagnosisUseCase(this.repository);

  Future<Diagnosis> execute(List<String> symptoms) {
    return repository.getDiagnosis(symptoms);
  }
}
