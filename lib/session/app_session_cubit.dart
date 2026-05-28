import 'package:finance/session/app_session_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSessionCubit extends Cubit<AppSessionState> {
  final _storage = const FlutterSecureStorage();
  DateTime? _backgroundTimestamp;

  AppSessionCubit()
      : super(AppSessionState(isUnlocked: false, isFirstRun: true)) {
    _checkStatus();
  }
  Future<void> _checkStatus() async {
    final pin = await _storage.read(key: 'user_pin');
    // Если PIN найден в памяти телефона, значит это НЕ первый запуск
    if (pin != null) {
      emit(state.copyWith(isFirstRun: false, isUnlocked: false));
    } else {
      emit(state.copyWith(isFirstRun: true, isUnlocked: false));
    }
  }
  void unlock() {
    emit(state.copyWith(isUnlocked: true));
  }
  void lock() {
    emit(state.copyWith(isUnlocked: false));
  }

  void setFirstRun(bool value) {
    emit(state.copyWith(isFirstRun: value));
  }

  void markRegistrationComplete() {
    emit(state.copyWith(isFirstRun: false, isUnlocked: true));
  }

  void recordBackgroundTime() {
    _backgroundTimestamp = DateTime.now();
  }

  void checkLockTimeout() {
    if (_backgroundTimestamp == null) return;

    final now = DateTime.now();
    final difference = now.difference(_backgroundTimestamp!);

    // Если прошло больше минуты, блокируем приложение
    if (difference.inSeconds > 60) {
      lock();
    }
    _backgroundTimestamp = null; // Сбрасываем метку
  }

  /// Re-emit current state to trigger GoRouter refresh
  void refreshState() {
    emit(state.copyWith());
  }
}
