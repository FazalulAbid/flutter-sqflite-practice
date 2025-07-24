import 'package:freezed_annotation/freezed_annotation.dart';

part 'loader_state.freezed.dart';

@freezed
class LoaderState with _$LoaderState {
  // Initial state before any loading begins
  const factory LoaderState.initial() = Initial;

  // Loading is in progress
  const factory LoaderState.loading() = Loading;

  // Data has been successfully loaded
  const factory LoaderState.success({dynamic data}) = Success;

  // An error occurred during loading
  const factory LoaderState.error(dynamic failure) = StError;
}
