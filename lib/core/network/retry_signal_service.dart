import 'package:flutter/foundation.dart';

class RetrySignalService {
  final ValueNotifier<bool> isRetrying = ValueNotifier<bool>(false);

  void show() => isRetrying.value = true;
  void hide() => isRetrying.value = false;
}
