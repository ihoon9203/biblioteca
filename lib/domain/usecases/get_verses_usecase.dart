import '../entities/verse.dart';
import '../repositories/bible_repository.dart';

class GetVersesUseCase {
  GetVersesUseCase(this.repository);
  final BibleRepository repository;

  Future<List<Verse>> call(String bookKorean, String chapterNum) =>
      repository.getVerses(bookKorean, chapterNum);
}
