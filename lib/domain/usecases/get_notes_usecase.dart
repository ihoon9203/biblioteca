import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNotesUseCase {
  GetNotesUseCase(this.repository);
  final NoteRepository repository;
  Future<List<Note>> call() => repository.getNotes();
}
