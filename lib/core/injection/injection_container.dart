import 'package:audiobooks/core/event/library_events.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: false,
)
void configureDependencies({required String environment}) {
  getIt.registerLazySingleton<LibraryEventBus>(() => LibraryEventBus());
  init(getIt, environment: environment);
}
