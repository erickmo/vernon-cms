import 'package:equatable/equatable.dart';

/// Entity opsi record untuk field tipe relation (dropdown).
class RecordOption extends Equatable {
  /// ID record.
  final String id;

  /// Label yang ditampilkan.
  final String label;

  const RecordOption({
    required this.id,
    required this.label,
  });

  @override
  List<Object?> get props => [id, label];
}
