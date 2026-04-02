// ignore_for_file: deprecated_member_use

import 'dart:html' as html;
import 'dart:typed_data';

Future<void> downloadHistoryImage({
  required Uint8List bytes,
  required String fileName,
}) async {
  final String mimeType = _mimeTypeFromFileName(fileName);
  final html.Blob blob = html.Blob(<Uint8List>[bytes], mimeType);
  final String objectUrl = html.Url.createObjectUrlFromBlob(blob);
  final html.AnchorElement anchor = html.AnchorElement(href: objectUrl)
    ..download = fileName
    ..style.display = "none";

  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(objectUrl);
}

String _mimeTypeFromFileName(String fileName) {
  final String lowerName = fileName.toLowerCase();
  if (lowerName.endsWith(".jpg") || lowerName.endsWith(".jpeg")) {
    return "image/jpeg";
  }
  if (lowerName.endsWith(".webp")) {
    return "image/webp";
  }
  return "image/png";
}
