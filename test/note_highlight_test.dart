import 'package:biblioteca/domain/entities/note.dart';
import 'package:biblioteca/domain/repositories/note_repository.dart';
import 'package:biblioteca/domain/usecases/delete_note_usecase.dart';
import 'package:biblioteca/domain/usecases/get_notes_usecase.dart';
import 'package:biblioteca/domain/usecases/save_note_usecase.dart';
import 'package:biblioteca/viewmodels/note_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNoteRepository implements NoteRepository {
  _FakeNoteRepository(this._notes);
  final List<Note> _notes;

  @override
  Future<List<Note>> getNotes() async => _notes;
  @override
  Future<void> saveNote(Note note) async => _notes.add(note);
  @override
  Future<void> deleteNote(String id) async => _notes.removeWhere((n) => n.id == id);
}

Note _note({
  required String id,
  required String book,
  required String chapter,
  required int startVerse,
  required int endVerse,
  required DateTime createdAt,
}) {
  return Note(
    id: id,
    title: id,
    bookKorean: book,
    chapterNum: chapter,
    verseRanges: [
      VerseRange(
        bookKorean: book,
        startChapterNum: chapter,
        startVerseNum: '$startVerse',
        endChapterNum: chapter,
        endVerseNum: '$endVerse',
      ),
    ],
    createdAt: createdAt,
  );
}

NoteViewModel _vmWith(List<Note> notes) {
  final repo = _FakeNoteRepository(notes);
  return NoteViewModel(
    saveNoteUseCase: SaveNoteUseCase(repo),
    getNotesUseCase: GetNotesUseCase(repo),
    deleteNoteUseCase: DeleteNoteUseCase(repo),
  );
}

void main() {
  test('two non-overlapping notes get distinct highlight levels', () async {
    final vm = _vmWith([
      _note(id: 'A', book: '창세기', chapter: '10', startVerse: 1, endVerse: 3, createdAt: DateTime(2026, 1, 1)),
      _note(id: 'B', book: '창세기', chapter: '10', startVerse: 5, endVerse: 7, createdAt: DateTime(2026, 1, 2)),
    ]);
    await vm.loadNotes();

    expect(vm.highlightLevelForVerse('창세기', '10', '2'), 0, reason: 'first note → highlight');
    expect(vm.highlightLevelForVerse('창세기', '10', '6'), 1, reason: 'second note → secondary');
    expect(vm.highlightLevelForVerse('창세기', '10', '9'), null, reason: 'uncovered verse');
  });

  test('overlapping verse: latest note wins', () async {
    final vm = _vmWith([
      _note(id: 'A', book: '창세기', chapter: '10', startVerse: 1, endVerse: 5, createdAt: DateTime(2026, 1, 1)),
      _note(id: 'B', book: '창세기', chapter: '10', startVerse: 3, endVerse: 8, createdAt: DateTime(2026, 1, 2)),
    ]);
    await vm.loadNotes();

    expect(vm.highlightLevelForVerse('창세기', '10', '2'), 0, reason: 'only first');
    expect(vm.highlightLevelForVerse('창세기', '10', '4'), 1, reason: 'overlap → latest (second)');
    expect(vm.highlightLevelForVerse('창세기', '10', '7'), 1, reason: 'only second');
  });

  test('third note cycles back to highlight level', () async {
    final vm = _vmWith([
      _note(id: 'A', book: '창세기', chapter: '10', startVerse: 1, endVerse: 1, createdAt: DateTime(2026, 1, 1)),
      _note(id: 'B', book: '창세기', chapter: '10', startVerse: 2, endVerse: 2, createdAt: DateTime(2026, 1, 2)),
      _note(id: 'C', book: '창세기', chapter: '10', startVerse: 3, endVerse: 3, createdAt: DateTime(2026, 1, 3)),
      _note(id: 'D', book: '창세기', chapter: '10', startVerse: 4, endVerse: 4, createdAt: DateTime(2026, 1, 4)),
    ]);
    await vm.loadNotes();

    expect(vm.highlightLevelForVerse('창세기', '10', '1'), 0);
    expect(vm.highlightLevelForVerse('창세기', '10', '2'), 1);
    expect(vm.highlightLevelForVerse('창세기', '10', '3'), 2);
    expect(vm.highlightLevelForVerse('창세기', '10', '4'), 0, reason: 'cycles back');
  });
}
