import 'package:dio/dio.dart';

import '../models/puzzle_diario.dart';

class LichessPuzzlesService {
  LichessPuzzlesService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

  final Dio _dio;

  Future<PuzzleDiario> obtenerDiario({CancelToken? cancelToken}) async {
    final response = await _dio.get<Object?>(
      'https://lichess.org/api/puzzle/daily',
      cancelToken: cancelToken,
    );
    if (response.data is! Map<String, dynamic>) {
      throw const FormatException('Lichess no devolvió un puzzle válido.');
    }
    return PuzzleDiario.fromJson(response.data! as Map<String, dynamic>);
  }

  void dispose() => _dio.close(force: true);
}
