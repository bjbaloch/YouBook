/// Simple debouncer for "while typing" checks
import 'dart:async';

class Debouncer {
  Debouncer(this.ms);
  final int ms;
  Timer? _timer;
  
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: ms), action);
  }

  void dispose() => _timer?.cancel();
}

