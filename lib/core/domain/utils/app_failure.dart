import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_failure.freezed.dart';

@freezed
sealed class AppFailure with _$AppFailure {
  const factory AppFailure.network({required String message, int? statusCode}) = NetworkFailure;

  const factory AppFailure.authentication({required String message}) = AuthenticationFailure;

  const factory AppFailure.validation({required String message, Map<String, String>? fieldErrors}) =
      ValidationFailure;

  const factory AppFailure.server({required String message, int? statusCode}) = ServerFailure;

  const factory AppFailure.unknown({required String message}) = UnknownFailure;
}
