import 'package:go_router/go_router.dart';
import '../views/bible/bible_screen.dart';
import '../views/me_screen.dart';
import '../views/notes_screen.dart';
import '../views/main_screen.dart';
import '../views/new_note_screen.dart';
import '../views/note_screen.dart';

final class AppRoute {
  static const String newNote = '/new-note';
  static const String note = '/note';
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (context, state) => const BibleScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/notes', builder: (context, state) => const NotesScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/me', builder: (context, state) => const MeScreen())],
        ),
      ],
    ),
    GoRoute(
      path: AppRoute.newNote,
      builder: (context, state) {
        var data = state.extra;
        if (data is Map<String, String>) {
          String book = data['book'] ?? '';
          String chapter = data['chapter'] ?? '';
          String verse = data['verse'] ?? '';
          return NewNoteScreen(book: book, chapter: chapter, verse: verse);
        } else {
          return NewNoteScreen(book: '', chapter: '', verse: '');
        }
      },
    ),
    GoRoute(
      path: '${AppRoute.note}/:id',
      builder: (context, state) => NoteScreen(noteId: state.pathParameters['id']!),
    ),
  ],
);
