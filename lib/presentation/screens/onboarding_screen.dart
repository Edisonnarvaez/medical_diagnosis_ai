import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      "icon": Icons.medical_services,
      "title": "Diagnóstico Inteligente",
      "desc": "Recibe orientación médica basada en IA según tus síntomas."
    },
    {
      "icon": Icons.lock,
      "title": "Historial Seguro",
      "desc": "Guarda y consulta tu historial médico de manera privada."
    },
    {
      "icon": Icons.favorite,
      "title": "Recomendaciones Saludables",
      "desc": "Obtén consejos personalizados para mejorar tu bienestar."
    },
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0ecff), Color(0xFFf6f9fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text("Saltar", style: TextStyle(fontSize: 16, color: Color(0xFF5D8CAE))),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: onboardingData.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final data = onboardingData[index];
                        return Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                data["icon"],
                                size: 120,
                                color: Colors.blue[300],
                              ),
                              const SizedBox(height: 40),
                              Text(
                                data["title"]!,
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                data["desc"]!,
                                style: const TextStyle(fontSize: 20, color: Colors.black54),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 20),
                        width: _currentPage == index ? 28 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? const Color(0xFF5D8CAE) : Colors.grey[400],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage != 0)
                          TextButton(
                            onPressed: () {
                              _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                            },
                            child: const Text("Atrás"),
                          )
                        else
                          const SizedBox(width: 60),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentPage == onboardingData.length - 1) {
                              _finishOnboarding();
                            } else {
                              _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                            }
                          },
                          child: Text(_currentPage == onboardingData.length - 1 ? "Empezar" : "Siguiente"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}