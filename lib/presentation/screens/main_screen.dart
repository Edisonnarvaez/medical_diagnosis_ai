import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_diagnosis_ai/controllers/auth_controller.dart';
import 'package:medical_diagnosis_ai/presentation/screens/history_screen.dart';
import 'package:medical_diagnosis_ai/presentation/screens/symptoms_form_screen.dart';
import 'package:medical_diagnosis_ai/presentation/screens/userProfileScreen.dart';
import 'package:medical_diagnosis_ai/data/repositories/user_profile_repository.dart';
import 'package:medical_diagnosis_ai/data/repositories/appwrite_diagnosis_repository.dart';
import 'package:hive/hive.dart';
import 'package:medical_diagnosis_ai/data/models/hive_diagnosis_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String? userPhotoUrl;
  final UserProfileRepository _profileRepo = UserProfileRepository();

  // Lista de recomendaciones posibles
  List<Map<String, dynamic>> allRecommendations = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    loadRecommendations();
    _syncRemoteDiagnoses();
  }

  Future<void> _loadUserName() async {
    final authController = Get.find<AuthController>();
    final userId = authController.user.value?.$id;
    if (userId != null) {
      final data = await _profileRepo.getProfile(userId);
      setState(() {
        userName = data?['name'] ?? 'Usuario';
        userPhotoUrl = data?['photoUrl']; // Cargar URL de la foto
      });
    }
  }

  Future<void> loadRecommendations() async {
    final String jsonString = await rootBundle.loadString('assets/recommendations.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    setState(() {
      allRecommendations = jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
    });
  }

  Future<void> _syncRemoteDiagnoses() async {
    final authController = Get.find<AuthController>();
    final userId = authController.user.value?.$id;
    if (userId == null) return;

    final appwriteRepo = AppwriteDiagnosisRepository();
    final remoteDiagnoses = await appwriteRepo.getDiagnoses(userId);

    // Opcional: Limpia Hive y guarda los diagnósticos remotos localmente
    final box = Hive.box('diagnosis_history');
    await box.clear();
    for (final diag in remoteDiagnoses) {
      box.add(HiveDiagnosisModel(
        result: diag['result'],
        confidence: (diag['confidence'] as num).toDouble(),
        symptoms: (diag['symptoms'] as String).split(',').map((e) => e.trim()).toList(),
        recommendations: (diag['recommendations'] as String).split(',').map((e) => e.trim()).toList(),
        createdAt: DateTime.parse(diag['createdAt']),
        userId: userId,
      ));
    }
  }

  List<Map<String, dynamic>> getRandomRecommendations(int count) {
    final random = Random();
    final recs = List<Map<String, dynamic>>.from(allRecommendations);
    recs.shuffle(random);
    return recs.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    final today = DateTime.now().day;
    final recommendations = allRecommendations.isNotEmpty
        ? getRandomRecommendations(3)
        : [];

    if (allRecommendations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await authController.logout();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0ecff), Color(0xFFf6f9fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadUserName();
              await loadRecommendations();
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con saludo y avatar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Usa Expanded para que el texto se adapte
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenido,',
                              style: TextStyle(
                                fontSize: 28, // Más pequeño para móviles
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2639),
                              ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                            Text(
                              userName ?? 'Usuario',
                              style: TextStyle(
                                fontSize: 28, // Más pequeño para móviles
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2639),
                              ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16), // Espacio entre texto y avatar
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          ).then((_) => _loadUserName());
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Color(0xFFAEC8E9),
                            shape: BoxShape.circle,
                            image: (userPhotoUrl != null && userPhotoUrl!.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(userPhotoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (userPhotoUrl == null || userPhotoUrl!.isEmpty)
                              ? Icon(Icons.person, size: 36, color: Color(0xFF3A5B83))
                              : null,
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
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2639),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Aquí la lista de recomendaciones ocupa todo el ancho y crece verticalmente
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: recommendations.length,
                    separatorBuilder: (_, __) => SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final rec = recommendations[index];
                      if (rec == null) return SizedBox.shrink();
                      return RecommendationItem(
                        icon: getIconData(rec['icon']),
                        text: rec['text'],
                        iconColor: Color(int.parse(rec['iconColor'].replaceFirst('#', '0xFF'))),
                        iconBgColor: Color(int.parse(rec['iconBgColor'].replaceFirst('#', '0xFF'))),
                      );
                    },
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Campo para editar la URL de la foto de perfil
                  
                ],
              ),
            ),
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
        Expanded( // <-- ¡Agrega esto!
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A2639),
            ),
            //overflow: TextOverflow.ellipsis, // Opcional: puntos suspensivos si es muy largo
            //maxLines: 3, // Opcional: máximo 2 líneas
            softWrap: true,
          ),
        ),
      ],
    );
  }
}

IconData getIconData(String iconName) {
  switch (iconName) {
    case 'water_drop':
      return Icons.water_drop;
    case 'directions_run':
      return Icons.directions_run;
    case 'nightlight_round':
      return Icons.nightlight_round;
    case 'restaurant':
      return Icons.restaurant;
    case 'self_improvement':
      return Icons.self_improvement;
    case 'sunny':
      return Icons.sunny;
    case 'emoji_emotions':
      return Icons.emoji_emotions;
    case 'group':
      return Icons.group;
    case 'local_hospital':
      return Icons.local_hospital;
    case 'sports_gymnastics':
      return Icons.sports_gymnastics;
    case 'accessibility_new':
      return Icons.accessibility_new;
    case 'favorite':
      return Icons.favorite;
    case 'emoji_objects':
      return Icons.emoji_objects;
    case 'fastfood':
      return Icons.fastfood;
    case 'mood':
      return Icons.mood;
    case 'check_circle':
      return Icons.check_circle;
    default:
      return Icons.star;
  }
}
