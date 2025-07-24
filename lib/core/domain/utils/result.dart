import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sqflite_practice_project/core/domain/utils/app_failure.dart';

part 'result.freezed.dart';

@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;

  const factory Result.failure(AppFailure error) = Failure<T>;
}
