import 'package:navikit_flutter_demo/domain/location/location_manager.dart'
    as domain;
import 'package:navikit_flutter_demo/domain/route/request_points_manager.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yandex_maps_navikit/mapkit.dart';

final class RequestPointsManagerImpl implements RequestPointsManager {
  final domain.LocationManager _locationManager;
  final _requestPointModel = BehaviorSubject<_RequestPointModel>()
    ..add(_RequestPointModel(null, null, null));

  late final _requestPoints = _requestPointModel
      .map<List<RequestPoint>>(_modelToRequestPoints)
      .distinctUnique();

  RequestPointsManagerImpl(this._locationManager);

  @override
  Stream<List<RequestPoint>> get requestPoints => _requestPoints;

  @override
  void setFromPoint(Point point) {
    _requestPointModel
        .update((previousValue) => previousValue.copyWith(from: point));
  }

  @override
  void setToPoint(Point point) {
    _requestPointModel
        .update((previousValue) => previousValue.copyWith(to: point));
  }

  @override
  void setViaPoint(Point point) {
    _requestPointModel.update((previousValue) {
      return previousValue.copyWith(
        via: (previousValue.via?..add(point)) ?? [point],
      );
    });
  }

  @override
  void resetPoints() {
    _requestPointModel.add(_RequestPointModel(null, null, null));
  }

  @override
  void dispose() {
    _requestPointModel.close();
  }

  List<RequestPoint> _modelToRequestPoints(_RequestPointModel model) {
    final from = model.from ?? _locationManager.location.valueOrNull?.position;
    final to = model.to;

    if (from == null || to == null) {
      return [];
    } else {
      return _createRequestPoints(from, model.via, to);
    }
  }

  List<RequestPoint> _createRequestPoints(
    Point from,
    List<Point>? via,
    Point to,
  ) {
    return [
      from.toRequestPoint(RequestPointType.Waypoint),
      ...?(via?.toRequestPoints(RequestPointType.Viapoint)),
      to.toRequestPoint(RequestPointType.Waypoint)
    ];
  }
}

extension _ToRequestPoint on Point {
  RequestPoint toRequestPoint(RequestPointType type) =>
      RequestPoint(this, type, null, null, null);
}

extension _ToRequestPoints on List<Point> {
  Iterable<RequestPoint>? toRequestPoints(RequestPointType type) {
    return map((it) => it.toRequestPoint(type));
  }
}

extension _UpdateBehaviourSubject<T> on BehaviorSubject<T> {
  void update(T Function(T previousValue) block) {
    final currentValue = value;
    final newValue = block(currentValue);
    add(newValue);
  }
}

final class _RequestPointModel {
  final Point? from;
  final Point? to;
  final List<Point>? via;

  _RequestPointModel(
    this.from,
    this.to,
    this.via,
  );

  _RequestPointModel copyWith({Point? from, Point? to, List<Point>? via}) {
    return _RequestPointModel(
      from ?? this.from,
      to ?? this.to,
      via ?? this.via,
    );
  }
}
