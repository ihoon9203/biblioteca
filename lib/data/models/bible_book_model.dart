import '../../domain/entities/bible_book.dart';
import 'chapter_model.dart';

class BibleBookModel extends BibleBook {
  const BibleBookModel({
    required super.korean,
    required super.english,
    required super.testament,
    required super.categoryNumber,
    required super.chapters,
  });

  factory BibleBookModel.fromJson(Map<String, dynamic> json) {
    final List<ChapterModel> chapters = (json['chapters'] as List)
        .map((c) => ChapterModel.fromJson(c as Map<String, dynamic>))
        .toList();
    return BibleBookModel(
      korean: json['korean'] as String,
      english: json['english'] as String,
      testament: json['testament'] as String,
      categoryNumber: json['categoryNumber'] as int,
      chapters: chapters,
    );
  }
}
