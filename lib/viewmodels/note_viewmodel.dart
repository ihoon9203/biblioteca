import 'package:flutter/material.dart';
import '../domain/entities/note.dart';
import '../domain/usecases/delete_note_usecase.dart';
import '../domain/usecases/get_notes_usecase.dart';
import '../domain/usecases/save_note_usecase.dart';

class NoteViewModel extends ChangeNotifier {

  NoteViewModel({required this.saveNoteUseCase, required this.getNotesUseCase, required this.deleteNoteUseCase});
  final SaveNoteUseCase saveNoteUseCase;
  final GetNotesUseCase getNotesUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;

  List<Note> _notes = [];
  List<Note> get notes => List.unmodifiable(_notes);

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Future<void> loadNotes() async {
    _notes = await getNotesUseCase();
    notifyListeners();
  }

  Future<void> saveNote(Note note) async {
    _isSaving = true;
    notifyListeners();
    try {
      await saveNoteUseCase(note);
      await loadNotes();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    await deleteNoteUseCase(id);
    await loadNotes();
  }

  bool hasNoteForVerse(String bookKorean, String chapterNum, String verseNum) {
    final int v = int.tryParse(verseNum) ?? 0;
    return _notes.any(
      (note) =>
          note.bookKorean == bookKorean &&
          note.chapterNum == chapterNum &&
          note.verseRanges.any((r) {
            final int start = int.tryParse(r.startVerseNum) ?? 0;
            final int end = int.tryParse(r.endVerseNum) ?? 0;
            return v >= start && v <= end;
          }),
    );
  }

  void createNoteForVerse(String korean, String chapterNum, String verseNum, String text) {}

  void openNoteForVerse(BuildContext context, String korean, String chapterNum, String verseNum) {}
}
