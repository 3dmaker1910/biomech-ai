import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../services/api_service.dart';

class NewPatientScreen extends StatefulWidget {
  const NewPatientScreen({super.key});

  @override
  State<NewPatientScreen> createState() => _NewPatientScreenState();
}

class _NewPatientScreenState extends State<NewPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedSex;
  String? _selectedReason;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose(); _ageController.dispose(); _weightController.dispose();
    _heightController.dispose(); _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameController.text.trim(),
        'age': int.parse(_ageController.text),
        'sex': _selectedSex!.toLowerCase(),
        'weight_kg': double.parse(_weightController.text),
        'height_cm': double.parse(_heightController.text),
        'reason': _selectedReason!,
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      };
      await _apiService.createPatient(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paciente registrado exitosamente'), backgroundColor: AppTheme.successGreen));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorRed));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Paciente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person_outline)), textCapitalization: TextCapitalization.words, validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _ageController, decoration: const InputDecoration(labelText: 'Edad', prefixIcon: Icon(Icons.cake_outlined), suffixText: 'años'), keyboardType: TextInputType.number, validator: (v) { if (v == null || v.isEmpty) return 'La edad es obligatoria'; final age = int.tryParse(v); return (age == null || age < 0 || age > 150) ? 'Ingrese una edad válida' : null; }),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(value: _selectedSex, decoration: const InputDecoration(labelText: 'Sexo', prefixIcon: Icon(Icons.wc_outlined)), items: AppConstants.sexOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _selectedSex = v), validator: (v) => v == null ? 'Seleccione el sexo' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _weightController, decoration: const InputDecoration(labelText: 'Peso', prefixIcon: Icon(Icons.monitor_weight_outlined), suffixText: 'kg'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) { if (v == null || v.isEmpty) return 'El peso es obligatorio'; final w = double.tryParse(v); return (w == null || w <= 0 || w > 500) ? 'Ingrese un peso válido' : null; }),
              const SizedBox(height: 16),
              TextFormField(controller: _heightController, decoration: const InputDecoration(labelText: 'Talla', prefixIcon: Icon(Icons.height), suffixText: 'cm'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) { if (v == null || v.isEmpty) return 'La talla es obligatoria'; final h = double.tryParse(v); return (h == null || h <= 0 || h > 300) ? 'Ingrese una talla válida' : null; }),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(value: _selectedReason, decoration: const InputDecoration(labelText: 'Motivo de consulta', prefixIcon: Icon(Icons.medical_services_outlined)), items: AppConstants.reasonOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(), onChanged: (v) => setState(() => _selectedReason = v), validator: (v) => v == null ? 'Seleccione el motivo de consulta' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'Observaciones (opcional)', prefixIcon: Icon(Icons.notes_outlined), alignLabelWithHint: true), maxLines: 3, maxLength: 200),
              const SizedBox(height: 32),
              SizedBox(height: 52, child: ElevatedButton(onPressed: _isLoading ? null : _savePatient, child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('GUARDAR PACIENTE'))),
            ],
          ),
        ),
      ),
    );
  }
}
