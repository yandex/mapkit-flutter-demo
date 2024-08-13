import 'package:yandex_maps_mapkit/mapkit.dart';

final class ClusterListenerImpl implements ClusterListener {
  final void Function(Cluster) onClusterAddedCallback;

  const ClusterListenerImpl({required this.onClusterAddedCallback});

  @override
  void onClusterAdded(Cluster cluster) => onClusterAddedCallback(cluster);
}
