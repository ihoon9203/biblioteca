enum MemoType { sermon, qt, study }

extension MemoTypeLabel on MemoType {
  String get label => switch (this) {
    MemoType.sermon => '설교',
    MemoType.qt => 'QT',
    MemoType.study => '공부',
  };
}

class VerseRange {

  const VerseRange({
    required this.bookKorean,
    required this.startChapterNum,
    required this.startVerseNum,
    required this.endChapterNum,
    required this.endVerseNum,
  });
  final String bookKorean;
  final String startChapterNum;
  final String startVerseNum;
  final String endChapterNum;
  final String endVerseNum;
}

class Note {

  const Note({
    required this.id,
    required this.title,
    required this.bookKorean,
    required this.chapterNum,
    required this.verseRanges,
    this.memoType,
    this.content,
    this.audioPath,
    required this.createdAt,
  });
  final String id;
  final String title;
  final String bookKorean;
  final String chapterNum;
  final List<VerseRange> verseRanges;
  final MemoType? memoType;
  final String? content;
  final String? audioPath;
  final DateTime createdAt;
}
