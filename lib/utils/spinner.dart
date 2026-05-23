import 'dart:async';
import 'dart:io';

/// Lightweight progress spinner. Falls back to a single info line when
/// stdout isn't a terminal (so piped output stays clean).
class Spinner {
  static const _frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

  Timer? _timer;
  int _i = 0;
  final String _message;
  bool _active = false;

  Spinner(this._message);

  void start() {
    if (_active) return;
    _active = true;
    if (!stdout.hasTerminal) {
      stdout.writeln('• $_message');
      return;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      _i = (_i + 1) % _frames.length;
      stdout.write('\r${_frames[_i]} $_message ');
    });
  }

  void stop({String? finalLine}) {
    if (!_active) return;
    _active = false;
    _timer?.cancel();
    _timer = null;
    if (stdout.hasTerminal) {
      // Clear the spinner line.
      stdout.write('\r\x1B[2K');
    }
    if (finalLine != null) stdout.writeln(finalLine);
  }
}
