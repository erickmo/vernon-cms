import 'package:dartz/dartz.dart';

/// Extension untuk Either agar lebih mudah digunakan di BLoC/Cubit.
extension EitherX<L, R> on Either<L, R> {
  /// Mengambil Right value, throw jika Left.
  R getRight() => (this as Right<L, R>).value;

  /// Mengambil Left value, throw jika Right.
  L getLeft() => (this as Left<L, R>).value;

  /// True jika Right.
  bool get isRight => fold((_) => false, (_) => true);

  /// True jika Left.
  bool get isLeft => fold((_) => true, (_) => false);
}
