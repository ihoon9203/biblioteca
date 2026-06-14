import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NotesLocalDataSource dataSource;
  NoteRepositoryImpl(this.dataSource);

  @override
  Future<List<Note>> getNotes() => dataSource.getNotes();

  @override
  Future<void> saveNote(Note note) => dataSource.saveNote(NoteModel.fromNote(note));

  @override
  Future<void> deleteNote(String id) => dataSource.deleteNote(id);
}
