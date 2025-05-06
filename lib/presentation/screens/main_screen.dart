import 'package:flutter/material.dart';
import 'package:medical_diagnosis_ai/presentation/screens/history_screen.dart';
import 'package:medical_diagnosis_ai/presentation/screens/symptoms_form_screen.dart';
import 'package:medical_diagnosis_ai/presentation/screens/userProfileScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con saludo y avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido,',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2639),
                        ),
                      ),
                      Text(
                        'Usuario',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2639),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Color(0xFFAEC8E9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF3A5B83),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 50),
              
              // Botones principales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón de Nuevo Análisis
                  Column(
                    children: [
                      Text(
                        'Nuevo',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'análisis',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SymptomsFormScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(0xFF1D3557),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Botón de Ver Historial
                  Column(
                    children: [
                      Text(
                        'Ver',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Historial',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HistoryScreen()),
                          );
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(0xFF1D3557),
                            shape: BoxShape.circle,
                            border: Border.all(color: Color(0xFF1D3557), width: 2),
                          ),
                          child: Icon(
                            Icons.access_time,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 60),
              
              // Sección de Recomendaciones
              Text(
                'Recomendaciones Generales',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2639),
                ),
              ),
              
              SizedBox(height: 30),
              
              // Lista de recomendaciones con iconos personalizados
              RecommendationItem(
                icon: Icons.water_drop,
                text: 'Toma al menos 2 litros de agua al día.',
                iconColor: Color(0xFF5D8CAE),
                iconBgColor: Color(0xFFD6E4F0),
              ),
              
              SizedBox(height: 25),
              
              RecommendationItem(
                icon: Icons.directions_run,
                text: 'Haz ejercicio al menos 3 veces por semana.',
                iconColor: Color(0xFF5D8CAE),
                iconBgColor: Color(0xFFD6E4F0),
              ),
              
              SizedBox(height: 25),
              
              RecommendationItem(
                icon: Icons.nightlight_round,
                text: 'Duerme al menos 7-8 horas por noche.',
                iconColor: Color(0xFF5D8CAE),
                iconBgColor: Color(0xFFD6E4F0),
              ),
              
              Spacer(),
              
            
            ],
          ),
        ),
      ),
    );
  }
}

// Widget personalizado para los elementos de recomendación
class RecommendationItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final Color iconBgColor;

  const RecommendationItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.iconBgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 30,
          ),
        ),
        SizedBox(width: 20),
        Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A2639),
          ),
        ),
      ],
    );
  }
}
