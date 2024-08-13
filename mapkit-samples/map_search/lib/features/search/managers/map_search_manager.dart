import 'dart:collection';

import 'package:common/common.dart';
import 'package:map_search/features/search/state/map_search_state.dart';
import 'package:map_search/features/search/state/search_state.dart'
    as search_model;
import 'package:map_search/features/search/state/suggest_state.dart'
    as suggest_model;
import 'package:map_search/features/search/widgets/utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/search.dart';

final class MapSearchManager {
  static const suggestNumberLimit = 20;
  static SuggestOptions defaultSuggestOptions = SuggestOptions(
    suggestTypes: SuggestType(
      SuggestType.Geo.value | SuggestType.Biz.value | SuggestType.Transit.value,
    ),
  );

  final _searchManager =
      SearchFactory.instance.createSearchManager(SearchManagerType.Combined);

  final _visibleRegion = BehaviorSubject<VisibleRegion?>()..add(null);
  final _searchQuery = BehaviorSubject<String>()..add("");
  final _searchState = BehaviorSubject<search_model.SearchState>()
    ..add(search_model.SearchOff.instance);
  final _suggestState = BehaviorSubject<suggest_model.SuggestState>()
    ..add(suggest_model.SuggestOff.instance);

  late final _throttledVisibleRegion =
      _visibleRegion.debounceTime(const Duration(seconds: 1));
  late final _suggestSession = _searchManager.createSuggestSession();

  late final _mapSearchState = Rx.combineLatest3(
    _searchQuery,
    _searchState,
    _suggestState,
    (searchQuery, searchState, suggestState) {
      return MapSearchState(searchQuery, searchState, suggestState);
    },
  ).shareValue();

  late final _searchSessionListener = SearchSessionSearchListener(
    onSearchResponse: (response) {
      final items = response.collection.children
          .map((geoObjectItem) {
            final point =
                geoObjectItem.asGeoObject()?.geometry.firstOrNull?.asPoint();

            return point?.let(
              (it) => search_model.SearchResponseItem(
                point,
                geoObjectItem.asGeoObject(),
              ),
            );
          })
          .whereType<search_model.SearchResponseItem>()
          .toList();

      final boundingBox = response.metadata.boundingBox;
      if (boundingBox == null) {
        return;
      }

      _searchState.add(
        search_model.SearchSuccess(
          items,
          {for (final item in items) item.point: item.geoObject},
          _shouldZoomToSearchResult,
          boundingBox,
        ),
      );
    },
    onSearchError: (error) {
      _searchState.add(search_model.SearchError.instance);
    },
  );

  late final _suggestSessionListener = SearchSuggestSessionSuggestListener(
    onResponse: (response) {
      final suggestItems = response.items.take(suggestNumberLimit).map(
        (item) {
          return suggest_model.SuggestItem(
            title: item.title,
            subtitle: item.subtitle,
            onTap: () {
              setQueryText(item.displayText ?? "");

              if (item.action == SuggestItemAction.Search) {
                final uri = item.uri;
                if (uri != null) {
                  // Search by URI if exists
                  _submitUriSearch(uri);
                } else {
                  // Otherwise, search by searchText
                  startSearch(item.searchText);
                }
              }
            },
          );
        },
      ).toList();
      _suggestState.add(suggest_model.SuggestSuccess(suggestItems));
    },
    onError: (error) => _suggestState.add(suggest_model.SuggestOff.instance),
  );

  SearchSession? _searchSession;
  bool _shouldZoomToSearchResult = false;

  ValueStream<MapSearchState> get mapSearchState => _mapSearchState;

  void setQueryText(String value) => _searchQuery.add(value);

  void setVisibleRegion(VisibleRegion region) => _visibleRegion.add(region);

  void startSearch([String? searchText]) {
    final text = searchText ?? _searchQuery.value;
    final region = _visibleRegion.value;

    if (text.isEmpty || region == null) {
      return;
    }

    final polygonRegion = region.let((it) => VisibleRegionUtils.toPolygon(it));

    _submitSearch(text, polygonRegion);
  }

  void reset() {
    _searchSession?.cancel();
    _searchSession = null;
    _searchState.add(search_model.SearchOff.instance);
    _resetSuggest();
    _searchQuery.add("");
  }

  /// Performs the search again when the map position changes
  Stream<void> subscribeForSearch() {
    return _throttledVisibleRegion
        .whereType<VisibleRegion>()
        .where((_) =>
          _searchState.value is search_model.SearchSuccess ||
          _searchState.value is search_model.SearchError
        )
        .map(
          (region) => _searchSession?.let((it) {
            it.setSearchArea(VisibleRegionUtils.toPolygon(region));
            it.resubmit(_searchSessionListener);
            _searchState.add(search_model.SearchLoading.instance);
            _shouldZoomToSearchResult = false;
          }),
        );
  }

  /// Resubmitting suggests when query, region or searchState changes
  Stream<void> subscribeForSuggest() {
    return Rx.combineLatest2(
      _searchQuery,
      _throttledVisibleRegion,
      (searchQuery, region) {
        if (searchQuery.isNotEmpty && region != null) {
          _submitSuggest(searchQuery, region.toBoundingBox());
        } else {
          _resetSuggest();
        }
      },
    );
  }

  void dispose() {
    _visibleRegion.close();
    _searchQuery.close();
    _searchState.close();
    _suggestState.close();
  }

  void _submitUriSearch(String uri) {
    _searchSession?.cancel();
    _searchSession = _searchManager.searchByURI(
      SearchOptions(),
      _searchSessionListener,
      uri: uri,
    );
    _shouldZoomToSearchResult = true;
  }

  void _submitSearch(String query, Geometry geometry) {
    _searchSession?.cancel();
    _searchSession = _searchManager.submit(
      geometry,
      SearchOptions(resultPageSize: 32),
      _searchSessionListener,
      text: query,
    );
    _searchState.add(search_model.SearchLoading.instance);
    _shouldZoomToSearchResult = true;
  }

  void _submitSuggest(
    String query,
    BoundingBox box, [
    SuggestOptions? options,
  ]) {
    _suggestSession.suggest(
      box,
      options ?? defaultSuggestOptions,
      _suggestSessionListener,
      text: query,
    );
    _suggestState.add(suggest_model.SuggestLoading.instance);
  }

  void _resetSuggest() {
    _suggestSession.reset();
    _suggestState.add(suggest_model.SuggestOff.instance);
  }
}
