import 'dart:typed_data';

import 'history_image_download_stub.dart'
    if (dart.library.html) 'history_image_download_web.dart' as impl;

Future<void> downloadHistoryImage({
  required Uint8List bytes,
  required String fileName,
}) {
  return impl.downloadHistoryImage(bytes: bytes, fileName: fileName);
}
