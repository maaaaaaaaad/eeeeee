import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobile_owner/core/network/api_client.dart';

abstract class ImageRemoteDataSource {
  Future<String> uploadImage(File imageFile);
}

class ImageRemoteDataSourceImpl implements ImageRemoteDataSource {
  final ApiClient apiClient;

  ImageRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> uploadImage(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    });

    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/images/upload',
      data: formData,
    );

    return response.data!['url'] as String;
  }
}
