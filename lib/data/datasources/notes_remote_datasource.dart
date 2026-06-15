import '../models/note_model.dart';
import 'notes_data_source.dart';

/// Placeholder for the future external-DB-backed datasource.
///
/// When the backend is ready, inject an API/DB client here and implement these
/// methods, then set `AppConfig.noteStorage = NoteStorageMode.remote`. Until
/// then every call throws so an accidental switch fails loudly instead of
/// silently losing data.
class NotesRemoteDataSource implements NotesDataSource {
  // TODO: inject the external DB / API client once available.
  // final SomeClient client;
  // NotesRemoteDataSource(this.client);

  @override
  Future<List<NoteModel>> getNotes() async {
    throw UnimplementedError('Remote note storage is not wired up yet.');
  }

  @override
  Future<void> saveNote(NoteModel note) async {
    throw UnimplementedError('Remote note storage is not wired up yet.');
  }

  @override
  Future<void> deleteNote(String id) async {
    throw UnimplementedError('Remote note storage is not wired up yet.');
  }
}
