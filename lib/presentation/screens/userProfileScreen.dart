import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_diagnosis_ai/presentation/auth_controller.dart';
import 'package:medical_diagnosis_ai/data/repositories/user_profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();

  String? _gender;
  double _weight = 60;
  double _height = 160;
  bool _isSmoker = false;
  bool _drinksAlcohol = false;
  String _activityLevel = 'Moderada';

  final List<String> _genders = ['Masculino', 'Femenino', 'Otro'];
  final List<String> _activityOptions = ['Sedentaria', 'Moderada', 'Activa'];

  final UserProfileRepository _profileRepo = UserProfileRepository();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authController = Get.find<AuthController>();
    final userId = authController.user.value?.$id;
    if (userId == null) return;
    final data = await _profileRepo.getProfile(userId);
    if (data != null) {
      setState(() {
        _nameController.text = data['name'] ?? '';
        _ageController.text = data['age']?.toString() ?? '';
        _gender = data['gender'];
        _weight = (data['weight'] as num?)?.toDouble() ?? 60;
        _height = (data['height'] as num?)?.toDouble() ?? 160;
        final condiciones = (data['conditions'] as String).split(',').map((e) => e.trim()).toList();
        _conditionsController.text = condiciones.join(', ');
        final medicamentos = (data['medications'] as String).split(',').map((e) => e.trim()).toList();
        _medicationsController.text = medicamentos.join(', ');
        _isSmoker = data['isSmoker'] ?? false;
        _drinksAlcohol = data['drinksAlcohol'] ?? false;
        _activityLevel = data['activityLevel'] ?? 'Moderada';
      });
    }
  }

  Future<void> _saveProfile() async {
    print('Intentando guardar perfil...');
    final authController = Get.find<AuthController>();
    final userId = authController.user.value?.$id;
    print('userId: $userId');
    if (userId == null) {
      print('No hay usuario autenticado');
      return;
    }
    final data = {
      'userId': userId,
      'name': _nameController.text,
      'age': int.tryParse(_ageController.text),
      'gender': _gender,
      'weight': _weight,
      'height': _height,
      'conditions': _conditionsController.text, // <-- texto plano
      'medications': _medicationsController.text, // <-- texto plano
      'isSmoker': _isSmoker,
      'drinksAlcohol': _drinksAlcohol,
      'activityLevel': _activityLevel,
    };
    print('Datos a guardar: $data');
    try {
      await _profileRepo.saveProfile(userId, data);
      print('Perfil guardado correctamente');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil guardado correctamente')),
      );
    } catch (e) {
      print('Error al guardar perfil: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar perfil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Datos Personales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (value) => value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
              ),

              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Género'),
                value: _gender,
                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (value) => setState(() => _gender = value),
                validator: (value) => value == null ? 'Seleccione una opción' : null,
              ),

              const SizedBox(height: 16),
              const Text("Salud General", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Text("Peso: ${_weight.toStringAsFixed(1)} kg"),
              Slider(
                min: 30,
                max: 150,
                value: _weight,
                divisions: 120,
                label: "${_weight.toStringAsFixed(1)} kg",
                onChanged: (value) => setState(() => _weight = value),
              ),

              Text("Estatura: ${_height.toStringAsFixed(1)} cm"),
              Slider(
                min: 100,
                max: 220,
                value: _height,
                divisions: 120,
                label: "${_height.toStringAsFixed(1)} cm",
                onChanged: (value) => setState(() => _height = value),
              ),

              TextFormField(
                controller: _conditionsController,
                decoration: const InputDecoration(
                  labelText: 'Condiciones médicas (separadas por coma)',
                ),
              ),

              TextFormField(
                controller: _medicationsController,
                decoration: const InputDecoration(
                  labelText: 'Medicamentos actuales (separados por coma)',
                ),
              ),

              const SizedBox(height: 16),
              const Text("Estilo de Vida", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              SwitchListTile(
                title: const Text("¿Fuma actualmente?"),
                value: _isSmoker,
                onChanged: (val) => setState(() => _isSmoker = val),
              ),

              SwitchListTile(
                title: const Text("¿Consume alcohol?"),
                value: _drinksAlcohol,
                onChanged: (val) => setState(() => _drinksAlcohol = val),
              ),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Nivel de actividad física'),
                value: _activityLevel,
                items: _activityOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _activityLevel = val!),
              ),

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Guardar Perfil"),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _saveProfile();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
