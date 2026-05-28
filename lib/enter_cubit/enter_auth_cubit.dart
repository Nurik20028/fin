import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:finance/enter_state/enter_auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class EnterAuthCubit extends Cubit<EnterAuthState> {
  EnterAuthCubit() : super(EnterAuthState()) {
    checkInitialStatus();
  }
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

  void checkInitialStatus() async {
    String? savedPin = await _storage.read(key: 'user_pin');
    if (savedPin == null) {
      // Если PIN не найден, значит это первый запуск(регистрация):
      emit(state.copyWith(isFirstRun: true));
    } else {
      emit(state.copyWith(isFirstRun: false));
    }
  }

  void addDigit(String digit) async {
    if (state.code.length < 4) {
      final newCode = state.code + digit;
      emit(state.copyWith(code: newCode));
      if (newCode.length == 4) {
        await Future.delayed(const Duration(milliseconds: 300));
        _verifyCode(newCode);
      }
    }
  }

  void deleteDigit() {
    if (state.code.isNotEmpty) {
      emit(
        state.copyWith(code: state.code.substring(0, state.code.length - 1)),
      );
    }
  }

  void _verifyCode(String inputCode) async {
    String? savedPin = await _storage.read(key: 'user_pin');
    if (inputCode == savedPin) {
      emit(state.copyWith(isSuccess: true, isError: false));
    } else {
      emit(state.copyWith(isError: true, code: ''));
    }
  }

  void resetState() {
    emit(
      EnterAuthState(
        code: '',
        isSuccess: false,
        isError: false,
        isFirstRun: state.isFirstRun,
      ),
    );
  }
  // Вход по отпечатку
  void authenticateBiometrically() async {
    if (kIsWeb) {
      emit(state.copyWith(isError: true, message: 'Биометрия не поддерживается в браузере'));
      return;
    }
    try {
      //поддерживает ли телефон биометрию:
      bool isDeviceSupported = await _auth.isDeviceSupported();
      //включил ли юзер отпечаток в настройках  своего телефоне:
      bool canCheckBiometrics = await _auth.canCheckBiometrics;

      if (!canCheckBiometrics || !isDeviceSupported) {
        emit(
          state.copyWith(
            isError: true,
            message:
            'Биометрия не поддерживается на этом устройстве'
                'или пользователь не ввел отпечаток в устройство',
          ),
        );
        return;
      }

      // аутентифицирование:
      bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Приложите палец для входа в кошелек',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true, // Помогает при случайных сворачиваниях
        ),
      );

      if (didAuthenticate) {
        emit(state.copyWith(isSuccess: true));
      }
    } on PlatformException catch (e) {
      print("Ошибка биометрии: ${e.code}");
      if (e.code == 'NotAvailable') {
        emit(
          state.copyWith(
            isError: true,
            message:
            'В настройках телефона не найден отпечаток пальца. Пожалуйста, настройте его в системе.',
          ),
        );
      } else {
        emit(
          state.copyWith(isError: true, message: 'Ошибка доступа к биометрии'),
        );
      }
    }
  }
}

