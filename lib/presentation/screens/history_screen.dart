import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/hive_diagnosis_model.dart';
import '../../controllers/auth_controller.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final userId = authController.user.value?.$id;
    final box = Hive.box('diagnosis_history');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        title: const Text('Historial Médico'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A2639),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Descargar PDF',
            onPressed: () async {
              final pdf = pw.Document();
              final userEntries = box.values.where((entry) => entry.userId == userId).toList();

              pdf.addPage(
                pw.MultiPage(
                  build: (context) => [
                    pw.Text('Historial Médico', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 16),
                    ...userEntries.map((entry) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Diagnóstico: ${entry.result}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Síntomas: ${entry.symptoms.join(', ')}'),
                        pw.Text('Confianza: ${(entry.confidence * 100).toStringAsFixed(1)}%'),
                        pw.Text('Fecha: ${timeago.format(entry.createdAt)}'),
                        pw.Text('Recomendaciones:'),
                        ...entry.recommendations.map((r) => pw.Text('- $r')),
                        pw.Divider(),
                      ],
                    )),
                  ],
                ),
              );
              await Printing.layoutPdf(onLayout: (format) async => pdf.save());
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir historial',
            onPressed: () {
              final report = box.values
                  .where((entry) => entry.userId == userId)
                  .map((entry) =>
                      'Diagnóstico: ${entry.result}\n'
                      'Síntomas: ${entry.symptoms.join(', ')}\n'
                      'Confianza: ${(entry.confidence * 100).toStringAsFixed(1)}%\n'
                      'Fecha: ${timeago.format(entry.createdAt)}\n'
                      'Recomendaciones: ${entry.recommendations.join(', ')}\n'
                      '---')
                  .join('\n');
              if (report.isNotEmpty) {
                Share.share('Historial médico:\n\n$report');
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {
          final userEntries = box.values
              .where((entry) => entry.userId == userId)
              .toList();

          if (userEntries.isEmpty) {
            return const Center(
              child: Text(
                'No hay registros aún.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: userEntries.length,
            itemBuilder: (context, index) {
              final entry = userEntries[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  childrenPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Color(0xFF1D3557),
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 15, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        timeago.format(entry.createdAt),
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.share, color: Color(0xFF43A047)),
                    tooltip: 'Compartir este diagnóstico',
                    onPressed: () {
                      final shareText =
                          'Diagnóstico IA: ${entry.result}\n'
                          'Nivel de confianza: ${(entry.confidence * 100).toStringAsFixed(1)}%\n'
                          'Síntomas: ${entry.symptoms.join(', ')}\n'
                          'Fecha: ${timeago.format(entry.createdAt)}\n'
                          'Recomendaciones: ${entry.recommendations.join(', ')}';
                      Share.share(shareText);
                    },
                  ),
                  children: [
                    const Divider(height: 18, thickness: 1.2),
                    Row(
                      children: [
                        const Icon(Icons.sick, color: Color(0xFF1D3557), size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Síntomas: ${entry.symptoms.join(', ')}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.verified, color: entry.confidence >= 0.8 ? Colors.green : (entry.confidence >= 0.5 ? Colors.orange : Colors.red), size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Confianza: ${(entry.confidence * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 15,
                            color: entry.confidence >= 0.8 ? Colors.green : (entry.confidence >= 0.5 ? Colors.orange : Colors.red),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.tips_and_updates, color: Color(0xFF1D3557), size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Recomendaciones:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ...entry.recommendations.map((r) => Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Color(0xFF43A047), size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(r, style: const TextStyle(fontSize: 14))),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.home),
        label: const Text('Menú principal'),
        backgroundColor: const Color(0xFF1D3557),
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        },
      ),
    );
  }
}
