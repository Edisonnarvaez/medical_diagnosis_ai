import 'package:hive/hive.dart';

part 'hive_diagnosis_model.g.dart';

@HiveType(typeId: 0)
class HiveDiagnosisModel extends HiveObject {
  @HiveField(0)
  String result;

  @HiveField(1)
  double confidence;

  @HiveField(2)
  List<String> symptoms;

  @HiveField(3)
  List<String> recommendations;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5) // Nuevo campo
  String userId;

  HiveDiagnosisModel({
    required this.result,
    required this.confidence,
    required this.symptoms,
    required this.recommendations,
    required this.createdAt,
    required this.userId, // Nuevo campo
  });
}
