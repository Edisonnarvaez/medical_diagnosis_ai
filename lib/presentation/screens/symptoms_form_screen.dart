import 'package:flutter/material.dart';
import 'package:medical_diagnosis_ai/presentation/screens/history_screen.dart';
import '../../data/repositories/gemini_diagnosis_repository.dart';
import '../../domain/entities/diagnosis.dart';
import '../../domain/usecases/get_diagnosis_usecase.dart';
import 'package:hive/hive.dart';
import '../../data/models/hive_diagnosis_model.dart';
import 'package:medical_diagnosis_ai/data/repositories/appwrite_diagnosis_repository.dart';
import 'package:medical_diagnosis_ai/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiagnosisResultScreen(symptoms: selectedSymptoms),
      ),
    );
  }

  final List<String> suggestedSymptoms = [
    'Fiebre', 'Tos', 'Dolor de cabeza', 'Náuseas', 'Fatiga', 'Dolor muscular'
  ];

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        title: const Text('Ingresa tus síntomas'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A2639),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. Síntomas sugeridos arriba
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Síntomas sugeridos:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2639)),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: suggestedSymptoms.map((symptom) => ActionChip(
                label: Text(symptom),
                onPressed: () {
                  if (!selectedSymptoms.contains(symptom)) {
                    setState(() => selectedSymptoms.add(symptom));
                  }
                },
              )).toList(),
            ),
            const SizedBox(height: 18),

            // 2. Campo para agregar síntoma manualmente
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _symptomController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.sick, color: Color(0xFF5D8CAE)),
                        labelText: 'Síntoma',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addSymptom,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D3557),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Chips de síntomas seleccionados
            Wrap(
              spacing: 8.0,
              children: selectedSymptoms
                  .map(
                    (symptom) => Chip(
                      label: Text(symptom),
                      backgroundColor: const Color(0xFFD6E4F0),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          selectedSymptoms.remove(symptom);
                        });
                      },
                    ),
                  )
                  .toList(),
            ),

            // 4. Botón "Eliminar todos" justo debajo de los chips seleccionados
            if (selectedSymptoms.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Eliminar todos'),
                  onPressed: () => setState(() => selectedSymptoms.clear()),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),

            const Spacer(),

            // 5. Botón Analizar y Ver historial
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _submitSymptoms,
                icon: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.search),
                label: isLoading
                  ? const Text('Analizando...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                  : const Text('Analizar síntomas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D3557),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Ver historial médico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D8CAE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla de resultado del diagnóstico REAL usando Gemini
class DiagnosisResultScreen extends StatelessWidget {
  final List<String> symptoms;

  const DiagnosisResultScreen({super.key, required this.symptoms});

  void _saveDiagnosis(Diagnosis diagnosis, List<String> symptoms, String userId) async {
    // Guardar en Hive (local)
    final box = Hive.box('diagnosis_history');
    final entry = HiveDiagnosisModel(
      result: diagnosis.result,
      confidence: diagnosis.confidence,
      symptoms: symptoms,
      recommendations: diagnosis.recommendations,
      createdAt: DateTime.now(),
      userId: userId,
    );
    await box.add(entry);

    // Guardar en Appwrite (nube)
    final appwriteRepo = AppwriteDiagnosisRepository();
    await appwriteRepo.saveDiagnosis(userId, {
      'userId': userId,
      'result': diagnosis.result,
      'confidence': diagnosis.confidence,
      'symptoms': symptoms.join(', '),
      'recommendations': diagnosis.recommendations.join(', '),
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Color getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final usecase = GetDiagnosisUseCase(GeminiDiagnosisRepository());
    final authController = Get.find<AuthController>();
    final userId = authController.user.value?.$id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        title: const Text('Resultado del Diagnóstico'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A2639),
        elevation: 0,
      ),
      body: FutureBuilder<Diagnosis>(
        future: usecase.execute(symptoms),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No se pudo obtener el diagnóstico'),
            );
          }

          final diagnosis = snapshot.data!;
          _saveDiagnosis(diagnosis, symptoms, userId);

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFFAEC8E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.medical_services, size: 54, color: Color(0xFF1A2639)),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Diagnóstico IA',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2639),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Síntomas ingresados:',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2639)),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  symptoms.join(', '),
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Diagnóstico: ${diagnosis.result}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1D3557),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Nivel de certeza: ${(diagnosis.confidence * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Recomendaciones:',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2639)),
                                ),
                                const SizedBox(height: 6),
                                ...diagnosis.recommendations.map(
                                  (r) => Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Color(0xFF5D8CAE), size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(r, style: const TextStyle(color: Colors.black87))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                // Botones fijos abajo
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Tooltip(
                          message: 'Compartir resultado',
                          child: IconButton(
                            icon: const Icon(Icons.share, color: Color(0xFF43A047), size: 28),
                            onPressed: () {
                              final shareText =
                                  'Diagnóstico IA: ${diagnosis.result}\n'
                                  'Nivel de certeza: ${(diagnosis.confidence * 100).toStringAsFixed(1)}%\n'
                                  'Síntomas: ${symptoms.join(', ')}\n'
                                  'Recomendaciones: ${diagnosis.recommendations.join(', ')}';
                              Share.share(shareText);
                            },
                          ),
                        ),
                        Tooltip(
                          message: 'Ver historial médico',
                          child: IconButton(
                            icon: const Icon(Icons.history, color: Color(0xFF5D8CAE), size: 28),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const HistoryScreen()),
                              );
                            },
                          ),
                        ),
                        Tooltip(
                          message: 'Crear otro análisis',
                          child: IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1D3557), size: 28),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const SymptomsFormScreen()),
                              );
                            },
                          ),
                        ),
                        Tooltip(
                          message: 'Volver al menú principal',
                          child: IconButton(
                            icon: const Icon(Icons.home, color: Color(0xFF1D3557), size: 28),
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
