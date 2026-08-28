import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/patient.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Patient> _patients = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients({String? search}) async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final patients = await _apiService.getPatients(search: search);
      setState(() { _patients = patients; _isLoading = false; });
    } catch (e) {
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar paciente por nombre...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _loadPatients(); })
                    : null,
              ),
              onChanged: (value) => _loadPatients(search: value),
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async { await context.push('/patients/new'); _loadPatients(); },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.errorRed)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => _loadPatients(), child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }
    if (_patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No hay pacientes registrados', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('Presiona + para agregar el primer paciente', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _loadPatients(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _patients.length,
        itemBuilder: (context, index) => _buildPatientCard(_patients[index]),
      ),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: Text(patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${patient.age} años • ${patient.sex} • ${patient.reason}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 2),
            Text(dateFormat.format(patient.createdAt), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async { await context.push('/patients/${patient.id}'); _loadPatients(); },
      ),
    );
  }
}
