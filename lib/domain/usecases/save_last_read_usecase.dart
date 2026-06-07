import '../entities/last_read_position.dart';
import '../repositories/preferences_repository.dart';

class SaveLastReadUseCase {
  final PreferencesRepository repository;

  SaveLastReadUseCase(this.repository);

  Future<void> call(String bookKorean, String chapterNum) =>
      repository.saveLastRead(LastReadPosition(bookKorean: bookKorean, chapterNum: chapterNum));
}
