import '../entities/verse.dart';
import '../repositories/bible_repository.dart';

class GetVersesUseCase {
  final BibleRepository repository;

  GetVersesUseCase(this.repository);

  Future<List<Verse>> call(String bookKorean, String chapterNum) =>
      repository.getVerses(bookKorean, chapterNum);
}
