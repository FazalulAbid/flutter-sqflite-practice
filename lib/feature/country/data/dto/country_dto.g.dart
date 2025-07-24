// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CountryDto _$CountryDtoFromJson(Map<String, dynamic> json) =>
    _CountryDto(name: NameDto.fromJson(json['name'] as Map<String, dynamic>));

Map<String, dynamic> _$CountryDtoToJson(_CountryDto instance) =>
    <String, dynamic>{'name': instance.name};

_NameDto _$NameDtoFromJson(Map<String, dynamic> json) => _NameDto(
  common: json['common'] as String,
  official: json['official'] as String,
);

Map<String, dynamic> _$NameDtoToJson(_NameDto instance) => <String, dynamic>{
  'common': instance.common,
  'official': instance.official,
};
