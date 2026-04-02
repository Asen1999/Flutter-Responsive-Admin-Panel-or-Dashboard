enum TileModuleType {
  brick,
  pillar,
  windowPattern,
}

extension TileModuleTypeX on TileModuleType {
  String get displayName {
    switch (this) {
      case TileModuleType.brick:
        return "\u7816\u7247";
      case TileModuleType.pillar:
        return "\u67F1\u5B50";
      case TileModuleType.windowPattern:
        return "\u7A97\u82B1";
    }
  }
}

class TileStyleOption {
  const TileStyleOption({
    required this.id,
    required this.module,
    required this.name,
    this.previewAsset,
  });

  final String id;
  final TileModuleType module;
  final String name;
  final String? previewAsset;
}
