abstract interface class NavigationSuspenderManager {
  void registerClient(NavigationClient client);
  void removeClient(NavigationClient client);
}

enum NavigationClient { application, backgroundService }
