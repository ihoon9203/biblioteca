import 'package:flutter/material.dart';
import '../domain/entities/bible_book.dart';
import '../domain/entities/chapter.dart';
import '../domain/entities/last_read_position.dart';
import '../domain/entities/verse.dart';
import '../domain/usecases/get_all_books_usecase.dart';
import '../domain/usecases/get_chapters_usecase.dart';
import '../domain/usecases/get_last_read_usecase.dart';
import '../domain/usecases/get_verses_usecase.dart';
import '../domain/usecases/save_last_read_usecase.dart';

enum ViewState { idle, loading, error }

class BibleViewModel extends ChangeNotifier {
  BibleViewModel({
    required this.getAllBooksUseCase,
    required this.getChaptersUseCase,
    required this.getVersesUseCase,
    required this.saveLastReadUseCase,
    required this.getLastReadUseCase,
  });
  final GetAllBooksUseCase getAllBooksUseCase;
  final GetChaptersUseCase getChaptersUseCase;
  final GetVersesUseCase getVersesUseCase;
  final SaveLastReadUseCase saveLastReadUseCase;
  final GetLastReadUseCase getLastReadUseCase;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  List<BibleBook> _books = [];
  List<BibleBook> get books => _books;

  List<Chapter> _chapters = [];
  List<Chapter> get chapters => _chapters;

  List<Verse> _verses = [];
  List<Verse> get verses => _verses;

  BibleBook? _selectedBook;
  BibleBook? get selectedBook => _selectedBook;

  Chapter? _selectedChapter;
  Chapter? get selectedChapter => _selectedChapter;

  String? _error;
  String? get error => _error;

  Future<void> loadBooks() async {
    _setState(ViewState.loading);
    try {
      _books = await getAllBooksUseCase();
      _setState(ViewState.idle);
    } catch (e) {
      _error = e.toString();
      _setState(ViewState.error);
    }
  }

  Future<void> selectBook(BibleBook book) async {
    _selectedBook = book;
    _setState(ViewState.loading);
    try {
      _chapters = await getChaptersUseCase(book.korean);
      _setState(ViewState.idle);
    } catch (e) {
      _error = e.toString();
      _setState(ViewState.error);
    }
  }

  Future<void> selectChapter(Chapter chapter) async {
    _selectedChapter = chapter;
    _setState(ViewState.loading);
    try {
      _verses = await getVersesUseCase(_selectedBook!.korean, chapter.chapterNum);
      await saveLastReadUseCase(_selectedBook!.korean, chapter.chapterNum);
      _setState(ViewState.idle);
    } catch (e) {
      _error = e.toString();
      _setState(ViewState.error);
    }
  }

  bool get hasPreviousChapter {
    if (_selectedBook == null || _selectedChapter == null) return false;
    final int chapterIndex = _selectedBook!.chapters.indexWhere(
      (c) => c.chapterNum == _selectedChapter!.chapterNum,
    );
    final int bookIndex = _books.indexWhere((b) => b.korean == _selectedBook!.korean);
    return chapterIndex > 0 || bookIndex > 0;
  }

  bool get hasNextChapter {
    if (_selectedBook == null || _selectedChapter == null) return false;
    final int chapterIndex = _selectedBook!.chapters.indexWhere(
      (c) => c.chapterNum == _selectedChapter!.chapterNum,
    );
    final int bookIndex = _books.indexWhere((b) => b.korean == _selectedBook!.korean);
    return chapterIndex < _selectedBook!.chapters.length - 1 || bookIndex < _books.length - 1;
  }

  Future<void> goToPreviousChapter() async {
    if (_selectedBook == null || _selectedChapter == null) return;
    final int bookIndex = _books.indexWhere((b) => b.korean == _selectedBook!.korean);
    final int chapterIndex = _selectedBook!.chapters.indexWhere(
      (c) => c.chapterNum == _selectedChapter!.chapterNum,
    );

    if (chapterIndex > 0) {
      await selectChapter(_selectedBook!.chapters[chapterIndex - 1]);
    } else if (bookIndex > 0) {
      await selectBook(_books[bookIndex - 1]);
      await selectChapter(_selectedBook!.chapters.last);
    }
  }

  Future<void> goToNextChapter() async {
    if (_selectedBook == null || _selectedChapter == null) return;
    final int bookIndex = _books.indexWhere((b) => b.korean == _selectedBook!.korean);
    final int chapterIndex = _selectedBook!.chapters.indexWhere(
      (c) => c.chapterNum == _selectedChapter!.chapterNum,
    );

    if (chapterIndex < _selectedBook!.chapters.length - 1) {
      await selectChapter(_selectedBook!.chapters[chapterIndex + 1]);
    } else if (bookIndex < _books.length - 1) {
      await selectBook(_books[bookIndex + 1]);
      await selectChapter(_selectedBook!.chapters.first);
    }
  }

  Future<LastReadPosition?> getLastRead() => getLastReadUseCase();

  void _setState(ViewState newState) {
    _state = newState;
    notifyListeners();
  }
}
