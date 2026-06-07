import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/datasources/bible_local_datasource.dart';
import 'data/datasources/preferences_local_datasource.dart';
import 'data/repositories/bible_repository_impl.dart';
import 'data/repositories/preferences_repository_impl.dart';
import 'domain/usecases/get_all_books_usecase.dart';
import 'domain/usecases/get_chapters_usecase.dart';
import 'domain/usecases/get_last_read_usecase.dart';
import 'domain/usecases/get_verses_usecase.dart';
import 'domain/usecases/save_last_read_usecase.dart';
import 'viewmodels/bible_viewmodel.dart';
import 'views/main_screen.dart';

void main() {
  runApp(const BibliotecaApp());
}

class BibliotecaApp extends StatelessWidget {
  const BibliotecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bibleRepository = BibleRepositoryImpl(BibleLocalDataSource());
    final prefsRepository = PreferencesRepositoryImpl(PreferencesLocalDataSource());

    return ChangeNotifierProvider(
      create: (_) => BibleViewModel(
        getAllBooksUseCase: GetAllBooksUseCase(bibleRepository),
        getChaptersUseCase: GetChaptersUseCase(bibleRepository),
        getVersesUseCase: GetVersesUseCase(bibleRepository),
        saveLastReadUseCase: SaveLastReadUseCase(prefsRepository),
        getLastReadUseCase: GetLastReadUseCase(prefsRepository),
      ),
      child: MaterialApp(
        title: 'Biblioteca',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
