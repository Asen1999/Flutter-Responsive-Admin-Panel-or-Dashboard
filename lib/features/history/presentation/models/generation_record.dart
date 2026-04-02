import 'dart:typed_data';

import 'package:admin/features/generation/presentation/models/tile_style_option.dart';

class GenerationRecord {
  const GenerationRecord({
    required this.id,
    required this.sampleImageName,
    required this.selectedStyleIds,
    required this.createdAt,
    this.sampleImageBytes,
    this.thumbnailBytes,
  });

  final String id;
  final String sampleImageName;
  final Uint8List? sampleImageBytes;
  final Uint8List? thumbnailBytes;
  final Map<TileModuleType, String> selectedStyleIds;
  final DateTime createdAt;
}
