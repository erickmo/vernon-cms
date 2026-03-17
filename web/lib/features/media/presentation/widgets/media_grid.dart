import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/media_file.dart';
import 'media_card.dart';

/// Grid responsif untuk menampilkan daftar file media.
class MediaGrid extends StatelessWidget {
  /// Daftar file media.
  final List<MediaFile> files;

  /// Callback saat card ditekan.
  final void Function(MediaFile file) onTap;

  const MediaGrid({
    super.key,
    required this.files,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spacingXXL),
          child: Text(AppStrings.emptyData),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppDimensions.spacingM,
            mainAxisSpacing: AppDimensions.spacingM,
            childAspectRatio: 0.85,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            return MediaCard(
              file: file,
              onTap: () => onTap(file),
            );
          },
        );
      },
    );
  }

  /// Menghitung jumlah kolom berdasarkan lebar layar.
  /// 4 kolom desktop, 3 tablet, 2 mobile.
  int _getCrossAxisCount(double width) {
    if (width >= 1200) return 4;
    if (width >= 800) return 3;
    return 2;
  }
}
