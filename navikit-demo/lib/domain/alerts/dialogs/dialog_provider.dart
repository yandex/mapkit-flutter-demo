import 'package:flutter/foundation.dart';

typedef ButtonTextsWithActions = List<(String, VoidCallback)>;

abstract interface class DialogProvider {
  bool showCommonDialog(String description, ButtonTextsWithActions buttons);
}
