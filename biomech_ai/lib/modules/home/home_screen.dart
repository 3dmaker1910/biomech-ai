import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 48),
              _buildHeader(),
              const SizedBox(height: 48),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionCard(context, icon: Icons.person_add_rounded, label: '+ NUEVO PACIENTE', color: AppTheme.primary, onTap: () => context.push('/patients/new')),
                    const SizedBox(height: 16),
                    _buildActionCard(context, icon: Icons.people_rounded, label: 'PACIENTES', color: AppTheme.accent, onTap: () => context.push('/patients')),
                    const SizedBox(height: 16),
                    _buildActionCard(context, icon: Icons.settings_rounded, label: 'CONFIGURACIÓN', color: Colors.grey, onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuración disponible en V0.2')));
                    }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(AppConstants.footerText, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.accessibility_new_rounded, color: Colors.white, size: 44),
        ),
        const SizedBox(height: 16),
        const Text(AppConstants.appName, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 2)),
        const SizedBox(height: 4),
        Text(AppConstants.appSubtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(colors: [color, color.withOpacity(0.85)], begin: Alignment.centerLeft, end: Alignment.centerRight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
