import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/diagnosis.dart';
import '../../domain/repositories/diagnosis_repository.dart';

class GeminiDiagnosisRepository implements DiagnosisRepository {
  @override
  //Future<Diagnosis> getDiagnosis(List<String> symptoms) async {
  Future<Diagnosis> getDiagnosis(List<String> symptoms, [Map<String, dynamic>? profile]) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not found. Please add it to your .env file.');
    }

    final model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: apiKey,
    );

    // No profile information available, so profileText is empty
    //final profileText = '';
    final profileText = profile != null
      ? '''
Datos del paciente:
- Nombre: ${profile['name']}
- Edad: ${profile['age']}
- Género: ${profile['gender']}
- Peso: ${profile['weight']} kg
- Estatura: ${profile['height']} cm
- Condiciones médicas: ${(profile['conditions'] as List?)?.join(', ') ?? ''}
- Medicamentos: ${(profile['medications'] as List?)?.join(', ') ?? ''}
- Fuma: ${profile['isSmoker'] == true ? 'Sí' : 'No'}
- Alcohol: ${profile['drinksAlcohol'] == true ? 'Sí' : 'No'}
- Actividad física: ${profile['activityLevel']}
'''
      : '';

    final prompt = '''
$profileText

Síntomas: ${symptoms.join(', ')}

Eres un asistente médico. Analiza los síntomas y el perfil del paciente y proporciona:
- Un diagnóstico preliminar (máximo 1 línea)
- Un nivel de certeza (porcentaje entre 0 y 100)
- 3 recomendaciones claras para el paciente

Responde en formato JSON:
{
  "diagnostico": "...",
  "certeza": ...,
  "recomendaciones": ["...", "...", "..."]
}
''';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      throw Exception('No se pudo obtener un diagnóstico.');
    }

    // Extraer el JSON de la respuesta
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    if (jsonMatch == null) throw Exception('Respuesta IA no válida: $text');
    final json = jsonMatch.group(0)!;

    // Decodificar el JSON
    final map = Map<String, dynamic>.from(
      jsonDecode(json) as Map,
    );

    return Diagnosis(
      result: map['diagnostico'] ?? 'Diagnóstico no disponible',
      confidence: (map['certeza'] is num)
          ? (map['certeza'] as num) / 100.0
          : 0.5,
      recommendations: (map['recomendaciones'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }
}