import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_diagnosis_ai/controllers/auth_controller.dart';
import 'package:medical_diagnosis_ai/data/repositories/user_profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
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
        _conditionsController.text = (data['conditions'] as String?) ?? '';
        _medicationsController.text = (data['medications'] as String?) ?? '';
        _isSmoker = data['isSmoker'] ?? false;
        _drinksAlcohol = data['drinksAlcohol'] ?? false;
        _activityLevel = data['activityLevel'] ?? 'Moderada';
      });
    }
  }

  Future<void> _saveProfile() async {
    final authController = Get.find<AuthController>();
    final userId = authController.user.value?.$id;
    if (userId == null) return;
    final data = {
      'userId': userId,
      'name': _nameController.text,
      'age': int.tryParse(_ageController.text),
      'gender': _gender,
      'weight': _weight,
      'height': _height,
      'conditions': _conditionsController.text,
      'medications': _medicationsController.text,
      'isSmoker': _isSmoker,
      'drinksAlcohol': _drinksAlcohol,
      'activityLevel': _activityLevel,
    };
    try {
      await _profileRepo.saveProfile(userId, data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil guardado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar perfil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A2639),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await Get.find<AuthController>().logout();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFAEC8E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 54, color: Color(0xFF1A2639)),
                ),
                const SizedBox(height: 18),
                Text(
                  'Tus datos personales',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2639),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF5D8CAE)),
                    labelText: 'Nombre completo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.cake_outlined, color: Color(0xFF5D8CAE)),
                    labelText: 'Edad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.wc, color: Color(0xFF5D8CAE)),
                    labelText: 'Género',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _gender,
                  items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (value) => setState(() => _gender = value),
                  validator: (value) => value == null ? 'Seleccione una opción' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Peso: ${_weight.toStringAsFixed(1)} kg"),
                          Slider(
                            min: 30,
                            max: 150,
                            value: _weight,
                            divisions: 120,
                            label: "${_weight.toStringAsFixed(1)} kg",
                            onChanged: (value) => setState(() => _weight = value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Estatura: ${_height.toStringAsFixed(1)} cm"),
                          Slider(
                            min: 100,
                            max: 220,
                            value: _height,
                            divisions: 120,
                            label: "${_height.toStringAsFixed(1)} cm",
                            onChanged: (value) => setState(() => _height = value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _conditionsController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.healing, color: Color(0xFF5D8CAE)),
                    labelText: 'Condiciones médicas (separadas por coma)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _medicationsController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.medication_outlined, color: Color(0xFF5D8CAE)),
                    labelText: 'Medicamentos actuales (separados por coma)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("¿Fuma actualmente?"),
                  value: _isSmoker,
                  onChanged: (val) => setState(() => _isSmoker = val),
                  activeColor: const Color(0xFF1D3557),
                ),
                SwitchListTile(
                  title: const Text("¿Consume alcohol?"),
                  value: _drinksAlcohol,
                  onChanged: (val) => setState(() => _drinksAlcohol = val),
                  activeColor: const Color(0xFF1D3557),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.directions_run, color: Color(0xFF5D8CAE)),
                    labelText: 'Nivel de actividad física',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _activityLevel,
                  items: _activityOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _activityLevel = val!),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar Perfil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D3557),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
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
      ),
    );
  }
}
