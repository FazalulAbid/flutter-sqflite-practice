import 'package:sqflite_practice_project/core/domain/utils/result.dart';
import 'package:sqflite_practice_project/feature/country/data/dto/country_dto.dart';

abstract class CountryRemoteDataSource {
  Future<Result<List<CountryDto>>> getCountries();
}
