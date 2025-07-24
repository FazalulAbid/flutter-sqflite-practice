import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_practice_project/core/domain/utils/result.dart';
import 'package:sqflite_practice_project/feature/country/data/datasource/country_remote_data_source.dart';
import 'package:sqflite_practice_project/feature/country/data/datasource/country_remote_data_source_impl.dart';
import 'package:sqflite_practice_project/feature/country/data/dto/country_dto.dart';
import 'package:sqflite_practice_project/feature/country/data/mapper/country_mapper.dart';
import 'package:sqflite_practice_project/feature/country/domain/models/country_model.dart';
import 'package:sqflite_practice_project/feature/country/domain/repository/country_repository.dart';

part 'country_repository_impl.g.dart';

@riverpod
CountryRepository countryRepository(Ref ref) {
  final dataSource = ref.watch(countryRemoteDataSourceProvider);
  return CountryRepositoryImpl(dataSource);
}

class CountryRepositoryImpl implements CountryRepository {
  final CountryRemoteDataSource _dataSource;

  CountryRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<Country>>> getCountries() async {
    final Result<List<CountryDto>> result = await _dataSource.getCountries();

    return result.when(
      success: (dtoList) {
        final countries = dtoList.map((dto) => dto.toDomain()).toList();
        print("Hello = Countries: $countries");
        return Result.success(countries);
      },
      failure: (error) {
        print("Hello = Error: $error");
        return Result.failure(error);
      },
    );
  }
}
