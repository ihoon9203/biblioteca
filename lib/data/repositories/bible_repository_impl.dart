import '../../domain/entities/bible_book.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/verse.dart';
import '../../domain/repositories/bible_repository.dart';
import '../datasources/bible_local_datasource.dart';
import '../models/bible_book_model.dart';

class BibleRepositoryImpl implements BibleRepository {
  final BibleLocalDataSource dataSource;
  List<BibleBookModel>? _cache;

  BibleRepositoryImpl(this.dataSource);

  Future<List<BibleBookModel>> _getBooks() async {
    _cache ??= await dataSource.loadBibleBooks();
    return _cache!;
  }

  @override
  Future<List<BibleBook>> getAllBooks() => _getBooks();

  @override
  Future<List<Chapter>> getChapters(String bookKorean) async {
    final books = await _getBooks();
    return books.firstWhere((b) => b.korean == bookKorean).chapters;
  }

  @override
  Future<List<Verse>> getVerses(String bookKorean, String chapterNum) async {
    final books = await _getBooks();
    final book = books.firstWhere((b) => b.korean == bookKorean);
    return book.chapters
        .firstWhere((c) => c.chapterNum == chapterNum)
        .verses;
  }
}
