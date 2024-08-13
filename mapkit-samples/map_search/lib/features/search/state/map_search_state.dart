import 'package:map_search/features/search/state/search_state.dart';
import 'package:map_search/features/search/state/suggest_state.dart';

final class MapSearchState {
  final String searchQuery;
  final SearchState searchState;
  final SuggestState suggestState;

  MapSearchState([
    String? searchQuery,
    SearchState? searchState,
    SuggestState? suggestState,
  ])  : searchQuery = searchQuery ?? "",
        searchState = searchState ?? SearchOff.instance,
        suggestState = suggestState ?? SuggestOff.instance;
}
