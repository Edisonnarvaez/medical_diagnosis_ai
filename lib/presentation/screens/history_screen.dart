import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/hive_diagnosis_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('diagnosis_history');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        title: const Text('Historial Médico'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A2639),
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'No hay registros aún.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final HiveDiagnosisModel entry = box.getAt(index);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6E4F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.medical_services, color: Color(0xFF5D8CAE), size: 28),
                  ),
                  title: Text(
                    entry.result,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Síntomas: ${entry.symptoms.join(', ')}'),
                      Text('Confianza: ${(entry.confidence * 100).toStringAsFixed(1)}%'),
                      Text('Fecha: ${entry.createdAt.toLocal()}'),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Detalle de la Consulta'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Diagnóstico:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(entry.result),
                              const SizedBox(height: 12),
                              Text('Síntomas:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(entry.symptoms.join(', ')),
                              const SizedBox(height: 12),
                              Text('Nivel de confianza:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('${(entry.confidence * 100).toStringAsFixed(1)}%'),
                              const SizedBox(height: 12),
                              Text('Fecha:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('${entry.createdAt.toLocal()}'),
                              const SizedBox(height: 12),
                              Text('Recomendaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...entry.recommendations.map((r) => Text('- $r')).toList(),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
