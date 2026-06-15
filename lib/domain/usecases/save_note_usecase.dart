import '../entities/note.dart';
import '../repositories/note_repository.dart';

class SaveNoteUseCase {
  SaveNoteUseCase(this.repository);
  final NoteRepository repository;
  Future<void> call(Note note) => repository.saveNote(note);
}
