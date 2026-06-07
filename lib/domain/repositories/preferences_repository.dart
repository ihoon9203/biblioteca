import '../entities/last_read_position.dart';

abstract class PreferencesRepository {
  Future<void> saveLastRead(LastReadPosition position);
  Future<LastReadPosition?> getLastRead();
}
