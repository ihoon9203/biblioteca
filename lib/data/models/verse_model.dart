import '../../domain/entities/verse.dart';

class VerseModel extends Verse {
  const VerseModel({required super.verseNum, required super.text});

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    return VerseModel(
      verseNum: json['verseNum'].toString(),
      text: json['verse'] as String,
    );
  }
}
