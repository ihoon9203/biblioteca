import '../entities/bible_book.dart';
import '../repositories/bible_repository.dart';

class GetAllBooksUseCase {

  GetAllBooksUseCase(this.repository);
  final BibleRepository repository;

  Future<List<BibleBook>> call() => repository.getAllBooks();
}
