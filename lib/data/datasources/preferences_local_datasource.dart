import 'package:shared_preferences/shared_preferences.dart';

class PreferencesLocalDataSource {
  static const _keyBookKorean = 'last_read_book_korean';
  static const _keyChapterNum = 'last_read_chapter_num';

  Future<void> saveLastRead(String bookKorean, String chapterNum) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBookKorean, bookKorean);
    await prefs.setString(_keyChapterNum, chapterNum);
  }

  Future<Map<String, String>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final bookKorean = prefs.getString(_keyBookKorean);
    final chapterNum = prefs.getString(_keyChapterNum);
    if (bookKorean == null || chapterNum == null) return null;
    return {'bookKorean': bookKorean, 'chapterNum': chapterNum};
  }
}
