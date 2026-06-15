import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import 'notes_data_source.dart';

class NotesLocalDataSource implements NotesDataSource {
  static const _key = 'notes';

  @override
  Future<List<NoteModel>> getNotes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    return NoteModel.listFromJson(jsonStr);
  }

  @override
  Future<void> saveNote(NoteModel note) async {
    final List<NoteModel> notes = await getNotes();
    final int index = notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.add(note);
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, NoteModel.listToJson(notes));
  }

  @override
  Future<void> deleteNote(String id) async {
    final List<NoteModel> notes = await getNotes();
    notes.removeWhere((n) => n.id == id);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, NoteModel.listToJson(notes));
  }
}
