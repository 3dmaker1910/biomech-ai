import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/patient.dart';
import '../../models/photo.dart';
import '../../services/api_service.dart';
import '../capture/photo_grid_widget.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final ApiService _apiService = ApiService();
  Patient? _patient;
  List<Photo> _photos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final patient = await _apiService.getPatient(widget.patientId);
      final photos = await _apiService.getPatientPhotos(widget.patientId);
      setState(() { _patient = patient; _photos = photos; _isLoading = false; });
    } catch (e) {
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_patient?.name ?? 'Paciente'),
        actions: [IconButton(icon: const Icon(Icons.delete_outline), onPressed: _confirmDelete)],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async { await context.push('/patients/${widget.patientId}/capture'); _loadData(); },
        icon: const Icon(Icons.camera_alt),
        label: const Text('NUEVA SESIÓN DE FOTOS'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(24.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
        const SizedBox(height: 16),
        Text(_errorMessage!, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _loadData, child: const Text('Reintentar')),
      ])));
    }
    if (_patient == null) return const Center(child: Text('Paciente no encontrado'));
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildPatientInfoCard(),
          const SizedBox(height: 24),
          _buildPhotosSection(),
          const SizedBox(height: 24),
          _buildStudiesSection(),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    final patient = _patient!;
    return Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(radius: 28, backgroundColor: AppTheme.primary.withOpacity(0.1), child: Text(patient.name[0].toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(patient.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('${patient.age} años • ${patient.sex}', style: TextStyle(color: Colors.grey.shade600)),
        ])),
      ]),
      const Divider(height: 32),
      _buildInfoRow(Icons.monitor_weight_outlined, 'Peso', '${patient.weightKg} kg'),
      const SizedBox(height: 8),
      _buildInfoRow(Icons.height, 'Talla', '${patient.heightCm} cm'),
      const SizedBox(height: 8),
      _buildInfoRow(Icons.medical_services_outlined, 'Motivo', patient.reason),
      if (patient.notes != null && patient.notes!.isNotEmpty) ...[const SizedBox(height: 8), _buildInfoRow(Icons.notes_outlined, 'Notas', patient.notes!)],
    ])));
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 20, color: AppTheme.accent),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
      Expanded(child: Text(value)),
    ]);
  }

  Widget _buildPhotosSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('FOTOGRAFÍAS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 1)),
      const SizedBox(height: 12),
      if (_photos.isEmpty)
        Card(child: Padding(padding: const EdgeInsets.all(24), child: Center(child: Column(children: [
          Icon(Icons.photo_camera_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text('No hay fotografías registradas', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text('Inicie una sesión de fotos para comenzar', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ]))))
      else
        PhotoGridWidget(photos: _photos, apiBaseUrl: AppConstants.apiBaseUrl),
    ]);
  }

  Widget _buildStudiesSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ESTUDIOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 1)),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(24), child: Center(child: Column(children: [
        Icon(Icons.analytics_outlined, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text('Próximamente: análisis disponible en V0.2', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
      ])))),
    ]);
  }

  void _confirmDelete() {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Eliminar paciente'),
      content: const Text('¿Está seguro de eliminar este paciente? Esta acción no se puede deshacer y eliminará todas las fotografías asociadas.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            try {
              await _apiService.deletePatient(widget.patientId);
              if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paciente eliminado'), backgroundColor: AppTheme.successGreen)); context.pop(); }
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorRed));
            }
          },
          style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
          child: const Text('ELIMINAR'),
        ),
      ],
    ));
  }
}
