import 'dart:convert';
import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.bookKorean,
    required super.chapterNum,
    required super.verseRanges,
    super.memoType,
    super.content,
    super.audioPath,
    required super.createdAt,
  });

  factory NoteModel.fromNote(Note note) => NoteModel(
    id: note.id,
    title: note.title,
    bookKorean: note.bookKorean,
    chapterNum: note.chapterNum,
    verseRanges: note.verseRanges,
    memoType: note.memoType,
    content: note.content,
    audioPath: note.audioPath,
    createdAt: note.createdAt,
  );

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final List<VerseRange> ranges = (json['verseRanges'] as List).map((r) {
      final m = r as Map<String, dynamic>;
      return VerseRange(
        bookKorean: m['book'] as String,
        startChapterNum: m['startChapter'] as String,
        startVerseNum: m['startVerse'] as String,
        endChapterNum: m['endChapter'] as String,
        endVerseNum: m['endVerse'] as String,
      );
    }).toList();
    final memoTypeStr = json['memoType'] as String?;
    final MemoType? memoType = memoTypeStr == null
        ? null
        : MemoType.values.firstWhere(
            (e) => e.name == memoTypeStr,
            orElse: () => MemoType.qt,
          );
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      bookKorean: json['bookKorean'] as String,
      chapterNum: json['chapterNum'] as String,
      verseRanges: ranges,
      memoType: memoType,
      content: json['content'] as String?,
      audioPath: json['audioPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'bookKorean': bookKorean,
    'chapterNum': chapterNum,
    'verseRanges': verseRanges
        .map((r) => {
              'book': r.bookKorean,
              'startChapter': r.startChapterNum,
              'startVerse': r.startVerseNum,
              'endChapter': r.endChapterNum,
              'endVerse': r.endVerseNum,
            })
        .toList(),
    'memoType': memoType?.name,
    'content': content,
    'audioPath': audioPath,
    'createdAt': createdAt.toIso8601String(),
  };

  static List<NoteModel> listFromJson(String jsonStr) {
    final list = json.decode(jsonStr) as List;
    return list.map((e) => NoteModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<NoteModel> notes) =>
      json.encode(notes.map((n) => n.toJson()).toList());
}
