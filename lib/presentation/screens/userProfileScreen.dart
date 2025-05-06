import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  int? _age;
  String? _gender;
  double _weight = 60;
  double _height = 160;
  List<String> _conditions = [];
  List<String> _medications = [];
  bool _isSmoker = false;
  bool _drinksAlcohol = false;
  String _activityLevel = 'Moderada';

  final List<String> _genders = ['Masculino', 'Femenino', 'Otro'];
  final List<String> _activityOptions = ['Sedentaria', 'Moderada', 'Activa'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Usuario')),
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
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (value) => value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
                onSaved: (value) => _name = value,
              ),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                onSaved: (value) => _age = int.tryParse(value!),
              ),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Género'),
                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (value) => _gender = value,
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
                decoration: const InputDecoration(
                  labelText: 'Condiciones médicas (separadas por coma)',
                ),
                onSaved: (value) => _conditions = value!.split(',').map((e) => e.trim()).toList(),
              ),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Medicamentos actuales (separados por coma)',
                ),
                onSaved: (value) => _medications = value!.split(',').map((e) => e.trim()).toList(),
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Aquí podrías guardar los datos en Appwrite, SQLite o Provider
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil guardado correctamente')),
                      );
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
