import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_owner/config/env_config.dart';
import 'package:mobile_owner/features/beautishop/data/models/geocode_result_model.dart';

abstract class GeocodeRemoteDataSource {
  Future<List<GeocodeResultModel>> searchAddress(String query);
}

class GeocodeRemoteDataSourceImpl implements GeocodeRemoteDataSource {
  static const String _baseUrl = 'https://maps.apigw.ntruss.com';
  static const String _endpoint = '/map-geocode/v2/geocode';

  late final Dio _dio;

  GeocodeRemoteDataSourceImpl() {
    _dio = Dio();
  }

  @visibleForTesting
  GeocodeRemoteDataSourceImpl.withDio(Dio dio) : _dio = dio;

  @override
  Future<List<GeocodeResultModel>> searchAddress(String query) async {
    final url = '$_baseUrl$_endpoint';

    final response = await _dio.get<Map<String, dynamic>>(
      url,
      queryParameters: {'query': query},
      options: Options(
        headers: {
          'X-NCP-APIGW-API-KEY-ID': EnvConfig.naverClientId,
          'X-NCP-APIGW-API-KEY': EnvConfig.naverClientSecret,
        },
      ),
    );

    return GeocodeResultModel.fromApiResponse(response.data!);
  }
}
