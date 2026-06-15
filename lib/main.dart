import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_config.dart';
import 'core/router.dart';
import 'core/stylesheet.dart';
import 'data/datasources/bible_local_datasource.dart';
import 'data/datasources/notes_data_source.dart';
import 'data/datasources/notes_local_datasource.dart';
import 'data/datasources/notes_remote_datasource.dart';
import 'data/datasources/preferences_local_datasource.dart';
import 'data/repositories/bible_repository_impl.dart';
import 'data/repositories/note_repository_impl.dart';
import 'data/repositories/preferences_repository_impl.dart';
import 'domain/usecases/delete_note_usecase.dart';
import 'domain/usecases/get_all_books_usecase.dart';
import 'domain/usecases/get_chapters_usecase.dart';
import 'domain/usecases/get_last_read_usecase.dart';
import 'domain/usecases/get_notes_usecase.dart';
import 'domain/usecases/get_verses_usecase.dart';
import 'domain/usecases/save_last_read_usecase.dart';
import 'domain/usecases/save_note_usecase.dart';
import 'viewmodels/bible_viewmodel.dart';
import 'viewmodels/note_viewmodel.dart';

void main() {
  runApp(const BibliotecaApp());
}

class BibliotecaApp extends StatelessWidget {
  const BibliotecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bibleRepository = BibleRepositoryImpl(BibleLocalDataSource());
    final prefsRepository =
        PreferencesRepositoryImpl(PreferencesLocalDataSource());
    // Swap note storage by flipping AppConfig.noteStorage — the rest of the
    // app depends only on the NotesDataSource interface.
    final NotesDataSource notesDataSource = switch (AppConfig.noteStorage) {
      NoteStorageMode.local => NotesLocalDataSource(),
      NoteStorageMode.remote => NotesRemoteDataSource(),
    };
    final noteRepository = NoteRepositoryImpl(notesDataSource);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BibleViewModel(
            getAllBooksUseCase: GetAllBooksUseCase(bibleRepository),
            getChaptersUseCase: GetChaptersUseCase(bibleRepository),
            getVersesUseCase: GetVersesUseCase(bibleRepository),
            saveLastReadUseCase: SaveLastReadUseCase(prefsRepository),
            getLastReadUseCase: GetLastReadUseCase(prefsRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => NoteViewModel(
            saveNoteUseCase: SaveNoteUseCase(noteRepository),
            getNotesUseCase: GetNotesUseCase(noteRepository),
            deleteNoteUseCase: DeleteNoteUseCase(noteRepository),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Biblioteca',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Stylesheet.theme,
          ),
          fontFamily: 'Pretendard',
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
