import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_book_model.dart';

class BibleLocalDataSource {
  Future<List<BibleBookModel>> loadBibleBooks() async {
    final jsonString = await rootBundle.loadString('assets/data/bible.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List;
    return jsonList
        .map((e) => BibleBookModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
