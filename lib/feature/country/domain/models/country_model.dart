import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_model.freezed.dart';

@freezed
abstract class Country with _$Country {
  const factory Country({
    required String commonName,
    required String officialName,
  }) = _Country;
}
