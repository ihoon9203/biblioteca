import '../entities/chapter.dart';
import '../repositories/bible_repository.dart';

class GetChaptersUseCase {
  final BibleRepository repository;

  GetChaptersUseCase(this.repository);

  Future<List<Chapter>> call(String bookKorean) => repository.getChapters(bookKorean);
}
