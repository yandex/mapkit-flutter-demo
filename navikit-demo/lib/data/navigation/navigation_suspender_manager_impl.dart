import 'package:navikit_flutter_demo/domain/navigation/navigation_manager.dart';
import 'package:navikit_flutter_demo/domain/navigation/navigation_suspender_manager.dart';

final class NavigationSuspenderManagerImpl
    implements NavigationSuspenderManager {
  final NavigationManager _navigationManager;
  final clients = <NavigationClient>{};

  NavigationSuspenderManagerImpl(this._navigationManager);

  @override
  void registerClient(NavigationClient client) {
    clients.add(client);
    _navigationManager.resume();
  }

  @override
  void removeClient(NavigationClient client) {
    clients.remove(client);
    if (clients.isEmpty) {
      _navigationManager.suspend();
    }
  }
}
