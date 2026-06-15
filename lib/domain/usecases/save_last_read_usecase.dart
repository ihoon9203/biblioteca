import '../entities/last_read_position.dart';
import '../repositories/preferences_repository.dart';

class SaveLastReadUseCase {
  SaveLastReadUseCase(this.repository);
  final PreferencesRepository repository;

  Future<void> call(String bookKorean, String chapterNum) =>
      repository.saveLastRead(LastReadPosition(bookKorean: bookKorean, chapterNum: chapterNum));
}
