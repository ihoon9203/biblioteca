import '../entities/bible_book.dart';
import '../entities/chapter.dart';
import '../entities/verse.dart';

abstract class BibleRepository {
  Future<List<BibleBook>> getAllBooks();
  Future<List<Chapter>> getChapters(String bookKorean);
  Future<List<Verse>> getVerses(String bookKorean, String chapterNum);
}
