import 'dart:typed_data';

Future<void> downloadHistoryImage({
  required Uint8List bytes,
  required String fileName,
}) async {
  throw UnsupportedError("Download is only supported on web.");
}
