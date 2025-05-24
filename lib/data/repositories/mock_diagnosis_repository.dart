import '../../domain/entities/diagnosis.dart';
import '../../domain/repositories/diagnosis_repository.dart';

class MockDiagnosisRepository implements DiagnosisRepository {
  @override
  Future<Diagnosis> getDiagnosis(List<String> symptoms, [Map<String, dynamic>? profile]) async {
    // Simulación de IA: espera 5 segundos y devuelve datos "falsos"
    await Future.delayed(const Duration(seconds: 5));

    return Diagnosis(
      result: "Gripe común",
      confidence: 0.87,
      recommendations: [
        "Descansar bien y mantenerse hidratado",
        "Consultar al médico si los síntomas empeoran",
        "Evitar contacto cercano con otras personas"
      ],
    );
  }
}
