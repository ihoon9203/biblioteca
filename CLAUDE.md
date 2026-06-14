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
├── viewmodels/              # BibleViewModel extends ChangeNotifier (top-level, NOT under presentation/)
├── views/                   # Screens + widgets (top-level)
└── main.dart                # Manual DI: builds repos → usecases → injects into ViewModel via ChangeNotifierProvider
```

Dependency rule: views → viewmodels → usecases → repository interfaces ← repository impls → datasources. ViewModel holds all UI state + `ViewState { idle, loading, error }`.

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Kept Repository/UseCase abstraction despite single impl | User chose to keep it for future DB/API swap + testability |
| `views/` & `viewmodels/` at lib root, not under `presentation/` | User preference — flatter structure |
| Single `BibleViewModel` for all bible screens | Shared selection state (book/chapter/verse) across BookList→Chapter→Verse + nav sheet |
| Bible data cached in-memory in `BibleRepositoryImpl` | JSON parsed once, reused |

## Data & Gotchas

- Bible source: `assets/data/bible.json` (declared in pubspec assets). Array of books → chapters → verses.
- **JSON verse text key is `verse`, NOT `text`** — mapped in `data/models/verse_model.dart`. `verseNum`/`chapterNum` are Strings.
- Last-read position persisted to SharedPreferences; `BookListScreen._init()` restores by pushing Chapter+Verse screens on launch.
- Windows desktop build needs Visual Studio "Desktop development with C++". Use `flutter run -d chrome` / `-d android` to avoid.

## Patterns

- **Scroll reset on chapter change**: give `ListView` a `ValueKey('$book_$chapter')` so Flutter rebuilds it fresh (used in `verse_screen.dart`).
- **Ripple on tappable cells**: `Material(color/borderRadius) > InkWell(borderRadius, onTap) > child` — Material owns the bg color, InkWell draws the splash. Don't use `GestureDetector` for selectable items.
- **Nav bottom sheet** (`bible_navigation_sheet.dart`): accordion — tap book → `AnimatedSize` expands chapter `Wrap` below it; opens with current book pre-expanded + auto-scrolled, current chapter highlighted.
- **AppBar title as `ActionChip`** in `verse_screen.dart` opens the nav sheet.
- Prev/next chapter logic lives in `BibleViewModel` (`goToPreviousChapter`/`goToNextChapter`, `hasPrevious/NextChapter`) and rolls over across book boundaries.
