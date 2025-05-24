import 'package:flutter/material.dart';
import 'package:medical_diagnosis_ai/presentation/screens/history_screen.dart';
import '../../data/repositories/gemini_diagnosis_repository.dart';
import '../../domain/entities/diagnosis.dart';
import '../../domain/usecases/get_diagnosis_usecase.dart';
import 'package:hive/hive.dart';
import '../../data/models/hive_diagnosis_model.dart';

class SymptomsFormScreen extends StatefulWidget {
  const SymptomsFormScreen({super.key});

  @override
  State<SymptomsFormScreen> createState() => _SymptomsFormScreenState();
}

class _SymptomsFormScreenState extends State<SymptomsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _symptomController = TextEditingController();

  List<String> selectedSymptoms = [];

  void _addSymptom() {
    final text = _symptomController.text.trim();
    if (text.isNotEmpty && !selectedSymptoms.contains(text)) {
      setState(() {
        selectedSymptoms.add(text);
        _symptomController.clear();
      });
    }
  }

  void _submitSymptoms() {
    if (selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa al menos un síntoma')),
      );
      return;
    }

    // Aquí luego llamaremos al modelo IA (por ahora lo simulamos)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiagnosisResultScreen(symptoms: selectedSymptoms),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresa tus síntomas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _symptomController,
                      decoration: const InputDecoration(
                        labelText: 'Síntoma',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addSymptom,
                    child: const Text('Agregar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              children:
                  selectedSymptoms
                      .map(
                        (symptom) => Chip(
                          label: Text(symptom),
                          onDeleted: () {
                            setState(() {
                              selectedSymptoms.remove(symptom);
                            });
                          },
                        ),
                      )
                      .toList(),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _submitSymptoms,
              icon: const Icon(Icons.search),
              label: const Text('Analizar síntomas'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  50,
                ), // Altura mínima del botón
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ), // Padding horizontal
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Bordes redondeados
                ),
                elevation: 2, // Sombra del botón
              ),
            ),
            //const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('Ver historial médico'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  50,
                ), // Altura mínima del botón
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ), // Padding horizontal
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Bordes redondeados
                ),
                elevation: 2, // Sombra del botón
                backgroundColor:
                    Theme.of(context).primaryColor, // Color de fondo
                foregroundColor: Colors.white, // Color del texto e ícono
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla simulada para el resultado del diagnóstico
class DiagnosisResultScreen extends StatelessWidget {
  final List<String> symptoms;

  const DiagnosisResultScreen({super.key, required this.symptoms});

  void _saveDiagnosis(Diagnosis diagnosis, List<String> symptoms) async {
    final box = Hive.box('diagnosis_history');
    final entry = HiveDiagnosisModel(
      result: diagnosis.result,
      confidence: diagnosis.confidence,
      symptoms: symptoms,
      recommendations: diagnosis.recommendations,
      createdAt: DateTime.now(),
    );

    await box.add(entry);
  }

  @override
  Widget build(BuildContext context) {
    final usecase = GetDiagnosisUseCase(GeminiDiagnosisRepository());

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado del Diagnóstico')),
      body: FutureBuilder<Diagnosis>(
        future: usecase.execute(symptoms),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No se pudo obtener el diagnóstico'),
            );
          }

          final diagnosis = snapshot.data!;
          _saveDiagnosis(diagnosis, symptoms);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Síntomas ingresados:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(symptoms.join(', ')),
                const SizedBox(height: 24),
                Text(
                  'Diagnóstico: ${diagnosis.result}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Nivel de certeza: ${(diagnosis.confidence * 100).toStringAsFixed(1)}%',
                ),
                const SizedBox(height: 24),
                const Text(
                  'Recomendaciones:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...diagnosis.recommendations.map((r) => Text('- $r')).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
