typedef ButtonTextsWithActions = List<(String, void Function())>;

abstract interface class DialogProvider {
  bool showCommonDialog(String description, ButtonTextsWithActions buttons);
}
