import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

enum MediaDownloadResult {
  success,
  permissionDenied,
  storageFull,
  unsupportedFormat,
  networkError,
  notFound,
  failed,
}

class MediaDownloadService {
  const MediaDownloadService({this.client});

  final HttpClient? client;

  Future<MediaDownloadResult> downloadAndSaveImage(String imageUrl) async {
    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isEmpty) {
      return MediaDownloadResult.notFound;
    }

    try {
      final httpClient = client ?? HttpClient();
      final uri = Uri.parse(trimmedUrl);
      final request = await httpClient.getUrl(uri);
      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        return MediaDownloadResult.networkError;
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      if (bytes.isEmpty) {
        return MediaDownloadResult.failed;
      }

      await Gal.putImageBytes(bytes);
      return MediaDownloadResult.success;
    } on GalException catch (e) {
      return switch (e.type) {
        GalExceptionType.accessDenied => MediaDownloadResult.permissionDenied,
        GalExceptionType.notEnoughSpace => MediaDownloadResult.storageFull,
        GalExceptionType.notSupportedFormat =>
          MediaDownloadResult.unsupportedFormat,
        GalExceptionType.unexpected => MediaDownloadResult.failed,
      };
    } on SocketException {
      return MediaDownloadResult.networkError;
    } on HttpException {
      return MediaDownloadResult.networkError;
    } catch (e) {
      debugPrint('MediaDownloadService error: $e');
      return MediaDownloadResult.failed;
    }
  }
}
