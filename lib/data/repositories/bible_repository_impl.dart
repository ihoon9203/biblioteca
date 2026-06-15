import '../../domain/entities/bible_book.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/verse.dart';
import '../../domain/repositories/bible_repository.dart';
import '../datasources/bible_local_datasource.dart';
import '../models/bible_book_model.dart';

class BibleRepositoryImpl implements BibleRepository {

  BibleRepositoryImpl(this.dataSource);
  final BibleLocalDataSource dataSource;
  List<BibleBookModel>? _cache;

  Future<List<BibleBookModel>> _getBooks() async {
    _cache ??= await dataSource.loadBibleBooks();
    return _cache!;
  }

  @override
  Future<List<BibleBook>> getAllBooks() => _getBooks();

  @override
  Future<List<Chapter>> getChapters(String bookKorean) async {
    final List<BibleBookModel> books = await _getBooks();
    return books.firstWhere((b) => b.korean == bookKorean).chapters;
  }

  @override
  Future<List<Verse>> getVerses(String bookKorean, String chapterNum) async {
    final List<BibleBookModel> books = await _getBooks();
    final BibleBookModel book = books.firstWhere((b) => b.korean == bookKorean);
    return book.chapters
        .firstWhere((c) => c.chapterNum == chapterNum)
        .verses;
  }
}
