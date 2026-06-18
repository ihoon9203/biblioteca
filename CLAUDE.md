# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Biblioteca — a Flutter Bible-reading app (Korean). State: `provider`. Local data only.

## Architecture (MVVM + Clean Architecture)

```
lib/
├── domain/                  # Pure Dart, no Flutter deps (except ChangeNotifier-free)
│   ├── entities/            # BibleBook, Chapter, Verse, LastReadPosition
│   ├── repositories/        # Abstract interfaces (BibleRepository, PreferencesRepository)
│   └── usecases/            # One class per action, callable via .call()
├── data/
│   ├── models/              # *Model extends entity, adds fromJson
│   ├── datasources/         # BibleLocalDataSource (asset JSON), PreferencesLocalDataSource (SharedPreferences)
│   └── repositories/        # *RepositoryImpl implements domain interface
├── core/                    # stylesheet.dart (design tokens), router.dart (go_router)
├── viewmodels/              # BibleViewModel, NoteViewModel extend ChangeNotifier (top-level, NOT under presentation/)
├── views/                   # Screens + widgets (top-level)
└── main.dart                # Manual DI: builds repos → usecases → injects into ViewModel via ChangeNotifierProvider; MaterialApp.router(routerConfig: appRouter)
```

Dependency rule: views → viewmodels → usecases → repository interfaces ← repository impls → datasources. ViewModel holds all UI state + `ViewState { idle, loading, error }`.

**Imports: use `package:biblioteca/...` absolute paths, NOT relative `../../`.** (Bible screens live in nested `views/bible/`, so relative imports get noisy.)

**One widget class per file: every Dart file must contain at most one widget class.** Split additional widgets into their own files (private helper widgets included).

## Navigation (go_router + 3 tabs)

- 3 screens: **성경** (`BibleScreen` `/`), **말씀노트** (`NotesScreen` `/notes`), **나** (`MeScreen` `/me`).
- Routing in `lib/core/router.dart` via `StatefulShellRoute.indexedStack` (3 branches). `MainScreen` receives the `StatefulNavigationShell` and renders the `BottomNavigationBar`.
- `BibleScreen` `_init()`: first launch → 창세기 1장; afterward → restores last-read book/chapter from SharedPreferences. AppBar chip taps open the nav sheet (`bible_navigation_sheet.dart`); tapping a verse opens `verse_memo_sheet.dart`.

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Kept Repository/UseCase abstraction despite single impl | User chose to keep it for future DB/API swap + testability |
| `views/` & `viewmodels/` at lib root, not under `presentation/` | User preference — flatter structure |
| Single `BibleViewModel` for all bible screens | Shared selection state (book/chapter/verse) across BookList→Chapter→Verse + nav sheet |
| Bible data cached in-memory in `BibleRepositoryImpl` | JSON parsed once, reused |
| All colors/decorations as static tokens in `Stylesheet` | No inline `Color(0xFF..)` / `BoxDecoration` in widgets — must reference `Stylesheet.*` |
| go_router `StatefulShellRoute` over manual `Navigator` push | Tab state preserved per branch; replaced old `BibleNavigator`/`BookListScreen`/`ChapterScreen`/`VerseScreen` push flow |

## Data & Gotchas

- Bible source: `assets/data/bible.json` (declared in pubspec assets). Array of books → chapters → verses.
- **JSON verse text key is `verse`, NOT `text`** — mapped in `data/models/verse_model.dart`. `verseNum`/`chapterNum` are Strings.
- Last-read position persisted to SharedPreferences; restored in `BibleScreen._init()` on launch.
- Windows desktop build needs Visual Studio "Desktop development with C++". Use `flutter run -d chrome` / `-d android` to avoid.

## Design System

- **`lib/core/stylesheet.dart`** (`abstract final class Stylesheet`): all colors, `LinearGradient`s, `BoxShadow` lists, `BoxDecoration`s, padding tokens. Never hardcode `0xFF..` colors or inline decorations in widgets — add/reference a `Stylesheet.*` token. Shadows are separate `List<BoxShadow>`; combine via `decoration.copyWith(boxShadow: Stylesheet.xxxShadow)`.
- **Font**: `Pretendard` (`assets/fonts/PretendardVariable.ttf`), set as `ThemeData.fontFamily` in main.dart.
- **Icons**: SVG in `assets/icons/` (declared as dir in pubspec), rendered via `flutter_svg` `SvgPicture.asset(...)`. Tab icons use `_fill` (selected) vs `_light` (unselected) variants, tinted with `color:`.

## Patterns

- **Scroll reset on chapter change**: give `ListView` a `ValueKey('$book_$chapter')` so Flutter rebuilds it fresh (used in `bible_screen.dart`).
- **Ripple on tappable cells**: `Material(color/borderRadius) > InkWell(borderRadius, onTap) > child` — Material owns the bg color, InkWell draws the splash. Don't use `GestureDetector` for selectable items.
- **Nav bottom sheet** (`bible_navigation_sheet.dart`): accordion — tap book → `AnimatedSize` expands chapter `Wrap` below it; opens with current book pre-expanded + auto-scrolled, current chapter highlighted.
- **AppBar title chip** in `bible_screen.dart` opens the nav sheet.
- Prev/next chapter logic lives in `BibleViewModel` (`goToPreviousChapter`/`goToNextChapter`, `hasPrevious/NextChapter`) and rolls over across book boundaries.
