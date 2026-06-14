enum MemoType { sermon, qt, worship, personal }

extension MemoTypeLabel on MemoType {
  String get label => switch (this) {
    MemoType.sermon => '설교',
    MemoType.qt => 'QT',
    MemoType.worship => '예배',
    MemoType.personal => '개인',
  };
}

class VerseRange {
  final String bookKorean;
  final String startChapterNum;
  final String startVerseNum;
  final String endChapterNum;
  final String endVerseNum;

  const VerseRange({
    required this.bookKorean,
    required this.startChapterNum,
    required this.startVerseNum,
    required this.endChapterNum,
    required this.endVerseNum,
  });
}

class Note {
  final String id;
  final String title;
  final String bookKorean;
  final String chapterNum;
  final List<VerseRange> verseRanges;
  final MemoType? memoType;
  final String? content;
  final String? audioPath;
  final DateTime createdAt;

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
}
