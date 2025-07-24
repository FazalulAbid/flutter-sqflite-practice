import 'package:sqflite_practice_project/feature/country/data/dto/country_dto.dart';
import 'package:sqflite_practice_project/feature/country/data/entity/country_entity.dart';
import 'package:sqflite_practice_project/feature/country/domain/models/country_model.dart';

extension CountryDtoMapper on CountryDto {
  Country toDomain() {
    return Country(commonName: name.common, officialName: name.official);
  }

  CountryEntity toEntity() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return CountryEntity(
      commonName: name.common,
      officialName: name.official,
      createdAt: now,
      updatedAt: now,
    );
  }
}
