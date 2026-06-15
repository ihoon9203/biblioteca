import 'chapter.dart';

class BibleBook {

  const BibleBook({
    required this.korean,
    required this.english,
    required this.testament,
    required this.categoryNumber,
    required this.chapters,
  });
  final String korean;
  final String english;
  final String testament;
  final int categoryNumber;
  final List<Chapter> chapters;
}
