import '../entities/note.dart';
import '../repositories/note_repository.dart';

class SaveNoteUseCase {
  final NoteRepository repository;
  SaveNoteUseCase(this.repository);
  Future<void> call(Note note) => repository.saveNote(note);
}
