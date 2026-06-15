import '../entities/last_read_position.dart';
import '../repositories/preferences_repository.dart';

class GetLastReadUseCase {

  GetLastReadUseCase(this.repository);
  final PreferencesRepository repository;

  Future<LastReadPosition?> call() => repository.getLastRead();
}
