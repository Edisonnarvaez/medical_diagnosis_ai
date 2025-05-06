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
      appBar: AppBar(title: const Text('Historial Médico')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No hay registros aún.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final HiveDiagnosisModel entry = box.getAt(index);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(entry.result),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Síntomas: ${entry.symptoms.join(', ')}'),
                      Text('Confianza: ${(entry.confidence * 100).toStringAsFixed(1)}%'),
                      Text('Fecha: ${entry.createdAt.toLocal()}'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
