import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../services/api_service.dart';
import 'guide_overlay_widget.dart';

class PhotoCaptureScreen extends StatefulWidget {
  final String patientId;
  const PhotoCaptureScreen({super.key, required this.patientId});

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  final Map<String, File?> _selectedPhotos = {};
  bool _isSaving = false;
  bool _isVerifying = false;

  int get _photoCount => _selectedPhotos.values.where((f) => f != null).length;
  bool get _canSave => _photoCount >= AppConstants.minPhotosRequired;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sesión de Fotos')),
      body: Column(children: [
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildSectionHeader('SECCIÓN CORPORAL'),
            const SizedBox(height: 12),
            _buildPhotoGrid(AppConstants.bodyPhotoTypes, isBody: true),
            const SizedBox(height: 24),
            _buildSectionHeader('SECCIÓN PIES'),
            const SizedBox(height: 12),
            _buildPhotoGrid(AppConstants.feetPhotoTypes, isBody: false),
          ]),
        )),
        _buildBottomBar(),
      ]),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 1.2));
  }

  Widget _buildPhotoGrid(List<String> types, {required bool isBody}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        return _buildPhotoSlot(type, _selectedPhotos[type], isBody: isBody);
      },
    );
  }

  Widget _buildPhotoSlot(String type, File? file, {required bool isBody}) {
    final label = AppConstants.photoTypeLabels[type] ?? type;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: file == null ? () => _showPickerOptions(type) : null,
        child: file != null ? _buildFilledSlot(type, file, label) : _buildEmptySlot(type, label, isBody: isBody),
      ),
    );
  }

  Widget _buildEmptySlot(String type, String label, {required bool isBody}) {
    return Stack(children: [
      Center(child: GuideOverlayWidget(isBody: isBody)),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          const Spacer(),
          Icon(isBody ? Icons.person_outline : Icons.footprint, size: 32, color: AppTheme.accent.withOpacity(0.5)),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildMiniButton(Icons.camera_alt, 'Tomar', () => _capturePhoto(type, ImageSource.camera)),
            const SizedBox(width: 8),
            _buildMiniButton(Icons.photo_library, 'Importar', () => _capturePhoto(type, ImageSource.gallery)),
          ]),
        ]),
      ),
    ]);
  }

  Widget _buildFilledSlot(String type, File file, String label) {
    return Stack(fit: StackFit.expand, children: [
      Image.file(file, fit: BoxFit.cover),
      Positioned(bottom: 0, left: 0, right: 0, child: Container(
        color: Colors.black54,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Column(children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GestureDetector(onTap: () => _showPickerOptions(type), child: const Text('Reemplazar', style: TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w500))),
            const SizedBox(width: 12),
            GestureDetector(onTap: () => _removePhoto(type), child: const Text('Eliminar', style: TextStyle(color: AppTheme.errorRed, fontSize: 11, fontWeight: FontWeight.w500))),
          ]),
        ]),
      )),
      const Positioned(top: 8, right: 8, child: Icon(Icons.check_circle, color: AppTheme.successGreen, size: 24)),
    ]);
  }

  Widget _buildMiniButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: AppTheme.accent),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.accent)),
        ]),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))]),
      child: SafeArea(child: Row(children: [
        Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$_photoCount/${AppConstants.totalPhotoSlots} fotografías', style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary)),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: _photoCount / AppConstants.totalPhotoSlots, backgroundColor: Colors.grey.shade200, color: _canSave ? AppTheme.successGreen : AppTheme.accent),
        ])),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _canSave && !_isSaving ? _saveSession : null,
          child: _isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('GUARDAR SESIÓN'),
        ),
      ])),
    );
  }

  void _showPickerOptions(String type) {
    showModalBottomSheet(context: context, builder: (context) => SafeArea(child: Wrap(children: [
      ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Tomar fotografía'), onTap: () { Navigator.pop(context); _capturePhoto(type, ImageSource.camera); }),
      ListTile(leading: const Icon(Icons.photo_library), title: const Text('Importar de galería'), onTap: () { Navigator.pop(context); _capturePhoto(type, ImageSource.gallery); }),
    ])));
  }

  Future<void> _capturePhoto(String type, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, maxWidth: 2000, maxHeight: 2000, imageQuality: 85);
      if (image == null) return;
      setState(() => _isVerifying = true);
      if (mounted) {
        showDialog(context: context, barrierDismissible: false, builder: (context) => const AlertDialog(
          content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Verificando imagen...')]),
        ));
      }
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);
      if (mounted) Navigator.pop(context);
      if (decodedImage.width < AppConstants.minPhotoWidth || decodedImage.height < AppConstants.minPhotoHeight) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La imagen no permite un análisis confiable. Por favor, repita la fotografía.'), backgroundColor: AppTheme.warningOrange, duration: Duration(seconds: 4)));
        return;
      }
      setState(() { _selectedPhotos[type] = file; _isVerifying = false; });
    } catch (e) {
      if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al capturar imagen: $e'), backgroundColor: AppTheme.errorRed)); }
      setState(() => _isVerifying = false);
    }
  }

  void _removePhoto(String type) => setState(() => _selectedPhotos.remove(type));

  Future<void> _saveSession() async {
    setState(() => _isSaving = true);
    try {
      int uploaded = 0;
      int failed = 0;
      for (final entry in _selectedPhotos.entries) {
        if (entry.value != null) {
          try {
            await _apiService.uploadPhoto(patientId: widget.patientId, filePath: entry.value!.path, photoType: entry.key);
            uploaded++;
          } catch (e) { failed++; }
        }
      }
      if (mounted) {
        final message = failed == 0 ? '$uploaded fotografías guardadas exitosamente' : '$uploaded guardadas, $failed con error. Intente nuevamente.';
        final bgColor = failed == 0 ? AppTheme.successGreen : AppTheme.warningOrange;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: bgColor));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar sesión: $e'), backgroundColor: AppTheme.errorRed));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
