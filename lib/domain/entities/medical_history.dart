import 'symptom.dart';
import 'diagnosis.dart';

class MedicalHistory {
  final DateTime date;
  final List<Symptom> symptoms;
  final Diagnosis diagnosis;

  MedicalHistory({
    required this.date,
    required this.symptoms,
    required this.diagnosis,
  });
}
