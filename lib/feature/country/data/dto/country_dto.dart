import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_dto.freezed.dart';
part 'country_dto.g.dart';

@freezed
abstract class CountryDto with _$CountryDto {
  const factory CountryDto({required NameDto name}) = _CountryDto;

  factory CountryDto.fromJson(Map<String, dynamic> json) => _$CountryDtoFromJson(json);
}

@freezed
abstract class NameDto with _$NameDto {
  const factory NameDto({
    required String common,
    required String official,
  }) = _NameDto;

  factory NameDto.fromJson(Map<String, dynamic> json) => _$NameDtoFromJson(json);
}
