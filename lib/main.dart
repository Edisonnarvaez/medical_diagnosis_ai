import 'package:flutter/material.dart';
import 'package:medical_diagnosis_ai/presentation/screens/symptoms_form_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medical_diagnosis_ai/presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('diagnosis_history');

  runApp(MedicalDiagnosisApp());
}

class MedicalDiagnosisApp extends StatelessWidget {
  const MedicalDiagnosisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diagnóstico Médico IA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: false,
      ),
      //home: const WelcomeScreen(),
      home: const HomeScreen(),

    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido')),
      body: const Center(
        child: Text(
          'Aplicación de Diagnóstico Médico Asistido por IA',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
