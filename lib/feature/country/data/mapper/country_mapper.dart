import 'package:sqflite_practice_project/feature/country/data/dto/country_dto.dart';
import 'package:sqflite_practice_project/feature/country/domain/models/country_model.dart';

extension CountryDtoMapper on CountryDto {
  Country toDomain() {
    return Country(commonName: name.common, officialName: name.official);
  }
}
