import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';

/// Outcome of a save, kept separate from the copy so the caller decides how to
/// speak about it.
enum SaveImageResult { saved, permissionDenied, failed }

/// Pulls a remote image down and writes it into the device photo library.
///
/// Its own [Dio] rather than `DioClient`: these URLs are absolute media links,
/// they carry no auth, and the API client's JSON headers and body logging are
/// wrong for a binary the size of a photo.
abstract class ImageSaver {
  ImageSaver._();

  /// Saved to the camera roll, deliberately not into an app album: naming an
  /// album makes the platform *read* the photo library to find or create it,
  /// which on iOS needs `NSPhotoLibraryUsageDescription` — full-library access
  /// — and terminates the app if that key is absent. A receipt is not worth
  /// asking a customer for read access to every photo they own.
  static const String _fileName = 'amazonat_receipt';

  static Future<SaveImageResult> saveFromUrl(String url) async {
    final target = url.trim();
    if (target.isEmpty) return SaveImageResult.failed;

    try {
      // Add-only access, asked for at the moment of the tap rather than at
      // launch — the customer has just said what the permission is for.
      if (!await Gal.hasAccess()) {
        final granted = await Gal.requestAccess();
        if (!granted) return SaveImageResult.permissionDenied;
      }

      final response = await Dio().get<List<int>>(
        target,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) return SaveImageResult.failed;

      await Gal.putImageBytes(Uint8List.fromList(bytes), name: _fileName);
      return SaveImageResult.saved;
    } on GalException catch (exception) {
      return exception.type == GalExceptionType.accessDenied
          ? SaveImageResult.permissionDenied
          : SaveImageResult.failed;
    } catch (_) {
      return SaveImageResult.failed;
    }
  }
}
