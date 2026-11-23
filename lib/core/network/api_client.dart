import 'package:dio/dio.dart';

import 'api_config.dart';

/// Error API yang sudah disederhanakan supaya UI tidak bergantung pada `dio`.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Klien HTTP berbasis `dio`. Belum dipanggil dari UI; nanti dipakai oleh
/// implementasi repository yang menggantikan data dummy.
class ApiClient {
  ApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
              headers: {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<T>(path, queryParameters: query));

  Future<T> post<T>(String path, {Object? body}) => _send(() => _dio.post<T>(path, data: body));

  /// Untuk API publik Web Admin (`/api/public/...`): semua balasannya berbentuk
  /// `{ success, data, message? }`. Mengembalikan isi `data`; bila server menolak,
  /// [ApiException.message] berisi pesan dari server (aman ditampilkan ke pengguna).
  Future<dynamic> getJson(String path, {Map<String, String>? query}) =>
      _envelope(() => _dio.get<dynamic>(path, queryParameters: query));

  Future<dynamic> postJson(String path, Map<String, Object?> body) =>
      _envelope(() => _dio.post<dynamic>(path, data: body));

  Future<dynamic> _envelope(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      final body = response.data;
      if (body is Map<String, dynamic> && body['success'] == true) return body['data'];
      throw ApiException(_serverMessage(body) ?? 'Balasan server tidak dikenali.', statusCode: response.statusCode);
    } on DioException catch (e) {
      throw ApiException(_serverMessage(e.response?.data) ?? _messageFor(e), statusCode: e.response?.statusCode);
    }
  }

  static String? _serverMessage(Object? body) {
    final message = body is Map<String, dynamic> ? body['message'] : null;
    return message is String && message.isNotEmpty ? message : null;
  }

  Future<T> _send<T>(Future<Response<T>> Function() request) async {
    try {
      final response = await request();
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException(_messageFor(e), statusCode: e.response?.statusCode);
    }
  }

  String _messageFor(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi ke server terlalu lama. Coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';
      case DioExceptionType.badResponse:
        return 'Server mengembalikan error (${e.response?.statusCode}).';
      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }
}
