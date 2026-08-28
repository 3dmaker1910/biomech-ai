import 'package:go_router/go_router.dart';
import '../modules/home/home_screen.dart';
import '../modules/patients/patient_list_screen.dart';
import '../modules/patients/patient_detail_screen.dart';
import '../modules/patients/new_patient_screen.dart';
import '../modules/capture/photo_capture_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/patients', builder: (context, state) => const PatientListScreen()),
    GoRoute(path: '/patients/new', builder: (context, state) => const NewPatientScreen()),
    GoRoute(
      path: '/patients/:id',
      builder: (context, state) => PatientDetailScreen(patientId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/patients/:id/capture',
      builder: (context, state) => PhotoCaptureScreen(patientId: state.pathParameters['id']!),
    ),
  ],
);
