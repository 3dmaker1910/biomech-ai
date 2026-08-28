import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../models/patient.dart';
import '../models/photo.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<List<Patient>> getPatients({String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      final response = await _dio.get('/api/v1/patients', queryParameters: queryParams);
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => Patient.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Patient> getPatient(String id) async {
    try {
      final response = await _dio.get('/api/v1/patients/$id');
      return Patient.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Patient> createPatient(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/v1/patients', data: data);
      return Patient.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Patient> updatePatient(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/api/v1/patients/$id', data: data);
      return Patient.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePatient(String id) async {
    try {
      await _dio.delete('/api/v1/patients/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Photo>> getPatientPhotos(String patientId) async {
    try {
      final response = await _dio.get('/api/v1/patients/$patientId/photos');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => Photo.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Photo> uploadPhoto({
    required String patientId,
    required String filePath,
    required String photoType,
  }) async {
    try {
      final formData = FormData.fromMap({
        'photo_type': photoType,
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(
        '/api/v1/patients/$patientId/photos',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return Photo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePhoto(String photoId) async {
    try {
      await _dio.delete('/api/v1/photos/$photoId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Error de conexión: el servidor no responde.';
      case DioExceptionType.connectionError:
        return 'No se pudo conectar al servidor.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        if (statusCode == 404) return 'Recurso no encontrado.';
        if (statusCode == 422) {
          if (responseData is Map && responseData.containsKey('detail')) {
            return 'Error de validación: ${responseData[\'detail\']}';
          }
          return 'Datos inválidos.';
        }
        if (statusCode == 500) return 'Error interno del servidor.';
        return 'Error del servidor (código $statusCode).';
      default:
        return 'Error inesperado. Intente nuevamente.';
    }
  }
}
