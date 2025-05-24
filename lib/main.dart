import 'package:flutter/material.dart';
import 'package:medical_diagnosis_ai/presentation/screens/login_screen.dart';
import 'package:medical_diagnosis_ai/presentation/screens/symptoms_form_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medical_diagnosis_ai/presentation/screens/main_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:medical_diagnosis_ai/data/models/hive_diagnosis_model.dart';
import 'package:get/get.dart';
import 'package:medical_diagnosis_ai/presentation/auth_controller.dart';
import 'package:medical_diagnosis_ai/presentation/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await Hive.initFlutter();
  Hive.registerAdapter(HiveDiagnosisModelAdapter());
  await Hive.openBox('diagnosis_history');
  final authController = Get.put(AuthController());

  // Verifica si hay sesión activa
  final isLogged = await authController.checkAuth();
  runApp(MedicalDiagnosisApp(initialRoute: isLogged ? '/home' : '/login'));
}

class MedicalDiagnosisApp extends StatelessWidget {
  final String initialRoute;
  const MedicalDiagnosisApp({super.key, this.initialRoute = '/login'});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Cambia a GetMaterialApp
      debugShowCheckedModeBanner: false,
      title: 'Diagnóstico Médico IA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: false,
      ),
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
      ],
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
