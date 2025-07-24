import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sqflite_practice_project/feature/country/domain/models/country_model.dart';

part 'country_entity.freezed.dart';

part 'country_entity.g.dart';

@freezed
abstract class CountryEntity with _$CountryEntity {
  const factory CountryEntity({
    int? id,
    required String commonName,
    required String officialName,
    required int createdAt,
    required int updatedAt,
  }) = _CountryEntity;

  factory CountryEntity.fromJson(Map<String, dynamic> json) =>
      _$CountryEntityFromJson(json);
}

extension CountryEntityExtension on CountryEntity {
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'common_name': commonName,
      'official_name': officialName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static CountryEntity fromDatabase(Map<String, dynamic> map) {
    return CountryEntity(
      id: map['id'] as int?,
      commonName: map['common_name'] as String,
      officialName: map['official_name'] as String,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Country toDomain() {
    return Country(commonName: commonName, officialName: officialName);
  }
}
