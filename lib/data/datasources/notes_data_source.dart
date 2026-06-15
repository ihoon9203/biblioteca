import '../models/note_model.dart';

/// Storage-agnostic contract for note persistence.
///
/// Implemented by [NotesLocalDataSource] (SharedPreferences, current default)
/// and, in the future, by a remote datasource backed by an external DB client.
/// Swap the active implementation via the flag in `core/app_config.dart`.
abstract class NotesDataSource {
  Future<List<NoteModel>> getNotes();
  Future<void> saveNote(NoteModel note);
  Future<void> deleteNote(String id);
}
