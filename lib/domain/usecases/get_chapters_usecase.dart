import '../entities/chapter.dart';
import '../repositories/bible_repository.dart';

class GetChaptersUseCase {

  GetChaptersUseCase(this.repository);
  final BibleRepository repository;

  Future<List<Chapter>> call(String bookKorean) => repository.getChapters(bookKorean);
}
