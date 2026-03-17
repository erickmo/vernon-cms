import 'package:equatable/equatable.dart';

/// Entity jumlah konten per hari untuk chart.
class DailyContent extends Equatable {
  /// Tanggal.
  final DateTime date;

  /// Jumlah konten yang dibuat pada tanggal ini.
  final int count;

  const DailyContent({
    required this.date,
    required this.count,
  });

  @override
  List<Object> get props => [date, count];
}
