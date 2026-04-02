import 'dart:typed_data';

import 'package:admin/constants.dart';
import 'package:admin/features/generation/presentation/models/tile_style_option.dart';
import 'package:admin/features/history/presentation/models/generation_record.dart';
import 'package:admin/features/history/presentation/providers/generation_history_provider.dart';
import 'package:admin/features/history/presentation/utils/history_image_download.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryImageListPage extends StatefulWidget {
  const HistoryImageListPage({super.key});

  @override
  State<HistoryImageListPage> createState() => _HistoryImageListPageState();
}

class _HistoryImageListPageState extends State<HistoryImageListPage> {
  static const Duration _panelAnimationDuration = Duration(milliseconds: 260);

  GenerationRecord? _selectedRecord;
  bool _isDetailOpen = false;

  void _openDetail(GenerationRecord record) {
    setState(() {
      _selectedRecord = record;
      _isDetailOpen = true;
    });
  }

  void _closeDetail() {
    if (_selectedRecord == null) {
      return;
    }

    setState(() {
      _isDetailOpen = false;
    });

    Future<void>.delayed(_panelAnimationDuration, () {
      if (!mounted || _isDetailOpen) {
        return;
      }
      setState(() {
        _selectedRecord = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final GenerationHistoryProvider provider =
        context.watch<GenerationHistoryProvider>();
    final double panelWidth = _detailPanelWidth(context);

    return SafeArea(
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            primary: false,
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Header(title: "History Image List"),
                const SizedBox(height: defaultPadding),
                Container(
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
                        "Generated History",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: defaultPadding),
                      if (provider.records.isEmpty)
                        Text(
                          "No records yet. Submit from Image Create first.",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        )
                      else
                        _buildResponsiveTable(provider),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_selectedRecord != null)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_isDetailOpen,
                child: GestureDetector(
                  onTap: _closeDetail,
                  child: AnimatedContainer(
                    duration: _panelAnimationDuration,
                    color: _isDetailOpen ? Colors.black45 : Colors.transparent,
                  ),
                ),
              ),
            ),
          if (_selectedRecord != null)
            AnimatedPositioned(
              duration: _panelAnimationDuration,
              curve: Curves.easeOutCubic,
              left: _isDetailOpen ? 0 : -panelWidth,
              top: 0,
              bottom: 0,
              width: panelWidth,
              child: _HistoryDetailPanel(
                record: _selectedRecord!,
                provider: provider,
                onClose: _closeDetail,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTable(GenerationHistoryProvider provider) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double styleCellWidth =
            (constraints.maxWidth * 0.42).clamp(220.0, 420.0).toDouble();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: defaultPadding,
              columns: const <DataColumn>[
                DataColumn(label: Text("Thumbnail")),
                DataColumn(label: Text("Style")),
                DataColumn(label: Text("Created At")),
                DataColumn(label: Text("Action")),
              ],
              rows: provider.records
                  .map(
                    (GenerationRecord record) =>
                        _recordRow(record, provider, styleCellWidth),
                  )
                  .toList(growable: false),
            ),
          ),
        );
      },
    );
  }

  DataRow _recordRow(
    GenerationRecord record,
    GenerationHistoryProvider provider,
    double styleCellWidth,
  ) {
    return DataRow(
      cells: <DataCell>[
        DataCell(_thumbnail(record, 78, 46)),
        DataCell(
          SizedBox(
            width: styleCellWidth,
            child: Text(
              provider.styleSummary(record),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(_formatDateTime(record.createdAt))),
        DataCell(
          TextButton(
            onPressed: () => _openDetail(record),
            child: const Text("Details"),
          ),
        ),
      ],
    );
  }

  Widget _thumbnail(GenerationRecord record, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: record.thumbnailBytes == null
          ? const Center(
              child: Icon(Icons.image_outlined, color: Colors.white54),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                record.thumbnailBytes!,
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  double _detailPanelWidth(BuildContext context) {
    final double fullWidth = MediaQuery.of(context).size.width;
    if (Responsive.isMobile(context)) {
      return fullWidth * 0.96;
    }
    if (Responsive.isTablet(context)) {
      return (fullWidth * 0.86).clamp(520.0, 840.0).toDouble();
    }
    return (fullWidth * 0.72).clamp(760.0, 1100.0).toDouble();
  }

  String _formatDateTime(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, "0");
    return "${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} "
        "${twoDigits(value.hour)}:${twoDigits(value.minute)}";
  }
}

class _HistoryDetailPanel extends StatelessWidget {
  const _HistoryDetailPanel({
    required this.record,
    required this.provider,
    required this.onClose,
  });

  final GenerationRecord record;
  final GenerationHistoryProvider provider;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final Uint8List? previewBytes = record.sampleImageBytes ?? record.thumbnailBytes;

    return Material(
      color: secondaryColor,
      elevation: 8,
      child: SafeArea(
        minimum: const EdgeInsets.all(defaultPadding),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              height: constraints.maxHeight,
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        "Details",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: defaultPadding),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          flex: 11,
                          child: _buildPreviewPanel(previewBytes),
                        ),
                        const SizedBox(width: defaultPadding),
                        Expanded(
                          flex: 10,
                          child: _buildDetailPanel(context, previewBytes),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPreviewPanel(Uint8List? previewBytes) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: previewBytes == null
          ? const Center(
              child:
                  Icon(Icons.image_outlined, size: 42, color: Colors.white54),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                previewBytes,
                fit: BoxFit.contain,
              ),
            ),
    );
  }

  Widget _buildDetailPanel(BuildContext context, Uint8List? previewBytes) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _detailText(context, "Task ID", record.id),
            _detailText(context, "Sample Image", record.sampleImageName),
            _detailText(
              context,
              "Created At",
              _formatDateTime(record.createdAt),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              "Selected Tile Style",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: defaultPadding / 2),
            for (final TileModuleType module in TileModuleType.values)
              _detailText(
                context,
                module.displayName,
                provider.optionById(record.selectedStyleIds[module] ?? "")?.name ??
                    "-",
              ),
            const SizedBox(height: defaultPadding),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: previewBytes == null
                    ? null
                    : () => _downloadImage(context, previewBytes),
                icon: const Icon(Icons.download_outlined),
                label: const Text("Download Image"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadImage(BuildContext context, Uint8List bytes) async {
    final String fileName = record.sampleImageName.trim().isEmpty
        ? "${record.id}.png"
        : record.sampleImageName;

    try {
      await downloadHistoryImage(bytes: bytes, fileName: fileName);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download started: $fileName")),
      );
    } on UnsupportedError {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download is currently supported on web.")),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download failed. Please try again.")),
      );
    }
  }

  Widget _detailText(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: <InlineSpan>[
            TextSpan(
              text: "$label: ",
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, "0");
    return "${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} "
        "${twoDigits(value.hour)}:${twoDigits(value.minute)}";
  }
}
