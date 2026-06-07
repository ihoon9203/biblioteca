import '../../domain/entities/chapter.dart';
import 'verse_model.dart';

class ChapterModel extends Chapter {
  const ChapterModel({required super.chapterNum, required super.verses});

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    final verses = (json['verses'] as List)
        .map((v) => VerseModel.fromJson(v as Map<String, dynamic>))
        .toList();
    return ChapterModel(
      chapterNum: json['chapterNum'].toString(),
      verses: verses,
    );
  }
}
