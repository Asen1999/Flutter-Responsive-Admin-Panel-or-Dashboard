import 'dart:typed_data';

import 'package:admin/constants.dart';
import 'package:admin/features/generation/presentation/models/tile_style_option.dart';
import 'package:admin/features/history/presentation/providers/generation_history_provider.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ImageCreatePage extends StatefulWidget {
  const ImageCreatePage({super.key});

  @override
  State<ImageCreatePage> createState() => _ImageCreatePageState();
}

class _ImageCreatePageState extends State<ImageCreatePage> {
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _sampleImageBytes;
  String? _sampleImageName;

  final Map<TileModuleType, String?> _selectedStyleIds =
      <TileModuleType, String?>{
    for (final TileModuleType module in TileModuleType.values) module: null,
  };

  Future<void> _pickSampleImage() async {
    final XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      return;
    }

    final Uint8List bytes = await pickedImage.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _sampleImageBytes = bytes;
      _sampleImageName = pickedImage.name;
    });
  }

  void _submitGeneration(GenerationHistoryProvider provider) {
    if (_sampleImageBytes == null || _sampleImageName == null) {
      _showHint("Please upload one sample image first.");
      return;
    }

    final bool hasUnselectedModule = TileModuleType.values.any(
      (TileModuleType module) => _selectedStyleIds[module] == null,
    );
    if (hasUnselectedModule) {
      _showHint("Please select one style for each module.");
      return;
    }

    provider.submitGenerationTask(
      sampleImageName: _sampleImageName!,
      sampleImageBytes: _sampleImageBytes!,
      selectedStyleIds: <TileModuleType, String>{
        for (final TileModuleType module in TileModuleType.values)
          module: _selectedStyleIds[module]!,
      },
    );

    _showHint(
        "Task submitted. Please open History Image List to view results.");
  }

  void _showHint(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GenerationHistoryProvider provider =
        context.watch<GenerationHistoryProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Header(title: "Image Create"),
            const SizedBox(height: defaultPadding),
            if (Responsive.isMobile(context))
              Column(
                children: <Widget>[
                  _buildSampleUploadCard(),
                  const SizedBox(height: defaultPadding),
                  _buildStyleSelectionCard(provider),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: _buildSampleUploadCard(),
                  ),
                  const SizedBox(width: defaultPadding),
                  Expanded(
                    flex: 3,
                    child: _buildStyleSelectionCard(provider),
                  ),
                ],
              ),
            const SizedBox(height: defaultPadding),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _submitGeneration(provider),
                icon: const Icon(Icons.auto_awesome),
                label: const Text("Generate Effect Image"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleUploadCard() {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Sample Upload",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: defaultPadding),
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24),
              color: bgColor,
            ),
            child: _sampleImageBytes == null
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.cloud_upload_outlined, size: 36),
                        SizedBox(height: 8),
                        Text("Upload one sample image"),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      _sampleImageBytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(height: defaultPadding),
          Row(
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: _pickSampleImage,
                icon: const Icon(Icons.file_upload_outlined),
                label: Text(
                    _sampleImageBytes == null ? "Choose Image" : "Re-upload"),
              ),
              const SizedBox(width: defaultPadding / 2),
              if (_sampleImageBytes != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _sampleImageBytes = null;
                      _sampleImageName = null;
                    });
                  },
                  child: const Text("Remove"),
                ),
            ],
          ),
          if (_sampleImageName != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              "Current file: $_sampleImageName",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStyleSelectionCard(GenerationHistoryProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Tile Style",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: defaultPadding),
          for (final TileModuleType module
              in TileModuleType.values) ...<Widget>[
            Text(
              module.displayName,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: defaultPadding / 2),
            Wrap(
              spacing: defaultPadding / 2,
              runSpacing: defaultPadding / 2,
              children: provider
                  .optionsForModule(module)
                  .map(
                    (TileStyleOption option) => _StyleOptionCard(
                      option: option,
                      selected: _selectedStyleIds[module] == option.id,
                      onTap: () {
                        setState(() {
                          _selectedStyleIds[module] = option.id;
                        });
                      },
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: defaultPadding),
          ],
        ],
      ),
    );
  }
}

class _StyleOptionCard extends StatelessWidget {
  const _StyleOptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final TileStyleOption option;
  final bool selected;
  final VoidCallback onTap;

  static const List<Color> _palette = <Color>[
    Color(0xFF4A7D8C),
    Color(0xFF8C6A4A),
    Color(0xFF6A4A8C),
    Color(0xFF3E7A6E),
    Color(0xFF8A4D5A),
    Color(0xFF6B7D3C),
  ];

  Color _previewColor() {
    final int seed = option.id.codeUnits.fold<int>(0, (int a, int b) => a + b);
    return _palette[seed % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        padding: const EdgeInsets.all(defaultPadding / 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? primaryColor : Colors.white24,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: <Color>[
                    _previewColor(),
                    _previewColor().withValues(alpha: 0.55),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              option.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
