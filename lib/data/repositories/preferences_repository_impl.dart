import '../../domain/entities/last_read_position.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../datasources/preferences_local_datasource.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesLocalDataSource dataSource;

  PreferencesRepositoryImpl(this.dataSource);

  @override
  Future<void> saveLastRead(LastReadPosition position) =>
      dataSource.saveLastRead(position.bookKorean, position.chapterNum);

  @override
  Future<LastReadPosition?> getLastRead() async {
    final data = await dataSource.getLastRead();
    if (data == null) return null;
    return LastReadPosition(
      bookKorean: data['bookKorean']!,
      chapterNum: data['chapterNum']!,
    );
  }
}
