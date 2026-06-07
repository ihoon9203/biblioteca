import '../entities/bible_book.dart';
import '../repositories/bible_repository.dart';

class GetAllBooksUseCase {
  final BibleRepository repository;

  GetAllBooksUseCase(this.repository);

  Future<List<BibleBook>> call() => repository.getAllBooks();
}
