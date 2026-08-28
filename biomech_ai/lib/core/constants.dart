class AppConstants {
  static const String appName = 'BIOMECH AI';
  static const String appSubtitle = 'Análisis Biomecánico Asistido';
  static const String appVersion = 'v0.1';
  static const String footerText = 'v0.1 — Solo para uso profesional';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  static const int minPhotoWidth = 200;
  static const int minPhotoHeight = 200;
  static const int totalPhotoSlots = 8;
  static const int minPhotosRequired = 2;

  static const List<String> bodyPhotoTypes = ['frontal','posterior','perfil_izq','perfil_der'];
  static const List<String> feetPhotoTypes = ['huella_izq','huella_der','pie_izq','pie_der'];

  static const Map<String, String> photoTypeLabels = {
    'frontal': 'Frontal',
    'posterior': 'Posterior',
    'perfil_izq': 'Perfil Izquierdo',
    'perfil_der': 'Perfil Derecho',
    'huella_izq': 'Huella Plantar Izq',
    'huella_der': 'Huella Plantar Der',
    'pie_izq': 'Pie Izquierdo',
    'pie_der': 'Pie Derecho',
  };

  static const List<String> reasonOptions = ['Dolor','Revisión','Deportista','Control','Otro'];
  static const List<String> sexOptions = ['Masculino','Femenino','Otro'];
}
