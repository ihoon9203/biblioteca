import 'chapter.dart';

class BibleBook {
  final String korean;
  final String english;
  final String testament;
  final int categoryNumber;
  final List<Chapter> chapters;

  const BibleBook({
    required this.korean,
    required this.english,
    required this.testament,
    required this.categoryNumber,
    required this.chapters,
  });
}
