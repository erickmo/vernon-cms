import 'package:equatable/equatable.dart';

/// Entity halaman CMS.
/// Dinamakan PageEntity untuk menghindari konflik dengan Flutter's Page.
class PageEntity extends Equatable {
  /// ID unik halaman (uuid).
  final String id;

  /// Nama halaman.
  final String name;

  /// Slug URL-friendly (unik).
  final String slug;

  /// Variables JSON fleksibel untuk template fields.
  final Map<String, dynamic> variables;

  /// Apakah halaman aktif.
  final bool isActive;

  /// Tanggal dibuat.
  final DateTime createdAt;

  /// Tanggal terakhir diperbarui.
  final DateTime updatedAt;

  const PageEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.variables = const {},
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        variables,
        isActive,
        createdAt,
        updatedAt,
      ];
}
