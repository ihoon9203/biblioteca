/// Runtime data-layer configuration.
///
/// Right now everything is persisted locally (SharedPreferences) so we can build
/// the UI frame. When the external DB / API client is ready, flip
/// [noteStorage] to [NoteStorageMode.remote] — nothing else in the app needs to
/// change because both datasources implement the same `NotesDataSource`.
enum NoteStorageMode { local, remote }

abstract final class AppConfig {
  /// Where notes are read from / written to.
  static const NoteStorageMode noteStorage = NoteStorageMode.local;
}
