import 'dart:async';
import 'package:flutter/material.dart';

class ResetPasswordProvider extends ChangeNotifier {
  bool _canResendEmail = true;
  int _secondsRemaining = 0;
  Timer? _timer;

  bool get canResendEmail => _canResendEmail;
  int get secondsRemaining => _secondsRemaining;

  void startTimer() {
    _secondsRemaining = 120;
    _canResendEmail = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        _canResendEmail = true;
        _timer?.cancel();
      } else {
        _secondsRemaining--;
      }
      notifyListeners();
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    _canResendEmail = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
