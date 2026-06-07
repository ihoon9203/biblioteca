import '../entities/last_read_position.dart';
import '../repositories/preferences_repository.dart';

class GetLastReadUseCase {
  final PreferencesRepository repository;

  GetLastReadUseCase(this.repository);

  Future<LastReadPosition?> call() => repository.getLastRead();
}
