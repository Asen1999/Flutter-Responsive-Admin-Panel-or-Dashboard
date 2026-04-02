import 'dart:typed_data';

import 'package:admin/features/generation/presentation/models/tile_style_option.dart';
import 'package:admin/features/history/presentation/models/generation_record.dart';
import 'package:flutter/material.dart';

class GenerationHistoryProvider extends ChangeNotifier {
  final List<TileStyleOption> _styleOptions = const <TileStyleOption>[
    TileStyleOption(
      id: "brick_a",
      module: TileModuleType.brick,
      name: "Brick Classic A",
    ),
    TileStyleOption(
      id: "brick_b",
      module: TileModuleType.brick,
      name: "Brick Classic B",
    ),
    TileStyleOption(
      id: "brick_c",
      module: TileModuleType.brick,
      name: "Brick Classic C",
    ),
    TileStyleOption(
      id: "pillar_a",
      module: TileModuleType.pillar,
      name: "Pillar Roman A",
    ),
    TileStyleOption(
      id: "pillar_b",
      module: TileModuleType.pillar,
      name: "Pillar Roman B",
    ),
    TileStyleOption(
      id: "pillar_c",
      module: TileModuleType.pillar,
      name: "Pillar Roman C",
    ),
    TileStyleOption(
      id: "window_a",
      module: TileModuleType.windowPattern,
      name: "Window Pattern A",
    ),
    TileStyleOption(
      id: "window_b",
      module: TileModuleType.windowPattern,
      name: "Window Pattern B",
    ),
    TileStyleOption(
      id: "window_c",
      module: TileModuleType.windowPattern,
      name: "Window Pattern C",
    ),
  ];

  late final List<GenerationRecord> _records = <GenerationRecord>[
    GenerationRecord(
      id: "G-20260331-001",
      sampleImageName: "sample_house_01.jpg",
      selectedStyleIds: <TileModuleType, String>{
        TileModuleType.brick: "brick_a",
        TileModuleType.pillar: "pillar_b",
        TileModuleType.windowPattern: "window_c",
      },
      createdAt: DateTime.now().subtract(const Duration(hours: 7)),
    ),
    GenerationRecord(
      id: "G-20260331-002",
      sampleImageName: "sample_house_02.jpg",
      selectedStyleIds: <TileModuleType, String>{
        TileModuleType.brick: "brick_c",
        TileModuleType.pillar: "pillar_a",
        TileModuleType.windowPattern: "window_b",
      },
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  List<TileStyleOption> get styleOptions =>
      List<TileStyleOption>.unmodifiable(_styleOptions);

  List<GenerationRecord> get records =>
      List<GenerationRecord>.unmodifiable(_records);

  List<TileStyleOption> optionsForModule(TileModuleType module) {
    return _styleOptions
        .where((TileStyleOption option) => option.module == module)
        .toList(growable: false);
  }

  TileStyleOption? optionById(String id) {
    for (final TileStyleOption option in _styleOptions) {
      if (option.id == id) {
        return option;
      }
    }
    return null;
  }

  String styleSummary(GenerationRecord record) {
    final List<String> pieces = <String>[];
    for (final TileModuleType module in TileModuleType.values) {
      final String? selectedStyleId = record.selectedStyleIds[module];
      final TileStyleOption? option =
          selectedStyleId == null ? null : optionById(selectedStyleId);
      pieces.add("${module.displayName}:${option?.name ?? '-'}");
    }
    return pieces.join(" / ");
  }

  void submitGenerationTask({
    required String sampleImageName,
    required Uint8List sampleImageBytes,
    required Map<TileModuleType, String> selectedStyleIds,
  }) {
    final GenerationRecord record = GenerationRecord(
      id: "G-${DateTime.now().millisecondsSinceEpoch}",
      sampleImageName: sampleImageName,
      sampleImageBytes: sampleImageBytes,
      thumbnailBytes: sampleImageBytes,
      selectedStyleIds: Map<TileModuleType, String>.from(selectedStyleIds),
      createdAt: DateTime.now(),
    );

    _records.insert(0, record);
    notifyListeners();
  }
}
