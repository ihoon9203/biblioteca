import 'package:flutter/material.dart';
import '../domain/entities/note.dart';
import '../domain/usecases/delete_note_usecase.dart';
import '../domain/usecases/get_notes_usecase.dart';
import '../domain/usecases/save_note_usecase.dart';

class NoteViewModel extends ChangeNotifier {
  final SaveNoteUseCase saveNoteUseCase;
  final GetNotesUseCase getNotesUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;

  NoteViewModel({
    required this.saveNoteUseCase,
    required this.getNotesUseCase,
    required this.deleteNoteUseCase,
  });

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
}
