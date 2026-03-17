import 'package:equatable/equatable.dart';

/// Entity opsi untuk field tipe select.
class SelectOption extends Equatable {
  /// Label yang ditampilkan ke user.
  final String label;

  /// Nilai yang disimpan.
  final String value;

  const SelectOption({
    required this.label,
    required this.value,
  });

  @override
  List<Object?> get props => [label, value];
}
