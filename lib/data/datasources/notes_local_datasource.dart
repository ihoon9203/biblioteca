import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class NotesLocalDataSource {
  static const _key = 'notes';

  Future<List<NoteModel>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    return NoteModel.listFromJson(jsonStr);
  }

  Future<void> saveNote(NoteModel note) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.add(note);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, NoteModel.listToJson(notes));
  }

  Future<void> deleteNote(String id) async {
    final notes = await getNotes();
    notes.removeWhere((n) => n.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, NoteModel.listToJson(notes));
  }
}
