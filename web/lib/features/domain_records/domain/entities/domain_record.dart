import 'package:equatable/equatable.dart';

/// Entity record domain (instance data dari sebuah domain).
class DomainRecord extends Equatable {
  /// ID unik record.
  final String id;

  /// Slug domain yang memiliki record ini.
  final String domainSlug;

  /// Data record dalam bentuk key-value.
  final Map<String, dynamic> data;

  /// Tanggal dibuat.
  final DateTime createdAt;

  /// Tanggal terakhir diperbarui.
  final DateTime updatedAt;

  const DomainRecord({
    required this.id,
    required this.domainSlug,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, domainSlug, data, createdAt, updatedAt];
}
