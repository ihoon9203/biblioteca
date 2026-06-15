import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/bible/bible_screen.dart';
import '../views/main_screen.dart';
import '../views/me_screen.dart';
import '../views/new_note_screen.dart';
import '../views/note_screen.dart';
import '../views/notes_screen.dart';

final class AppRoute {
  static const String newNote = '/new-note';
  static const String note = '/note';
}

CustomTransitionPage<void> _slideFromRight({required LocalKey key, required Widget child}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final Animatable<Offset> slideTween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut));
      final Animatable<double> fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: const Interval(0.0, 0.5)));
      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(opacity: animation.drive(fadeTween), child: child),
      );
    },
  );
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
      name: AppRoute.newNote,
      pageBuilder: (context, state) {
        final Object? data = state.extra;
        final NewNoteScreen screen;
        if (data is Map<String, String>) {
          screen = NewNoteScreen(book: data['book'] ?? '', chapter: data['chapter'] ?? '', verse: data['verse'] ?? '');
        } else {
          screen = const NewNoteScreen(book: '', chapter: '', verse: '');
        }
        return _slideFromRight(key: state.pageKey, child: screen);
      },
    ),
    GoRoute(
      path: '${AppRoute.note}/:id',
      name: AppRoute.note,
      pageBuilder: (context, state) => _slideFromRight(
        key: state.pageKey,
        child: NoteScreen(noteId: state.pathParameters['id']!),
      ),
    ),
  ],
);
