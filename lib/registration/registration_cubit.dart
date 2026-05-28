import 'package:finance/registration/registr_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegistrationCubit extends Cubit<RegistrState> {
  RegistrationCubit() : super(RegistrState());
  final _storage = const FlutterSecureStorage();
  void updateEmail(String email) => emit(state.copyWith(email: email));
  void addDigit(String digit) {
    if (state.pin.length < 4) {
      emit(state.copyWith(pin: state.pin + digit));
    }
  }
  void deleteDigit() {
    if (state.pin.isNotEmpty) {
      emit(state.copyWith(pin: state.pin.substring(0, state.pin.length - 1)));
    }
  }
  Future<bool> saveRegistration() async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await _storage.write(key: 'user_pin', value: state.pin);
      await _storage.write(key: 'user_email', value: state.email);
      return true;
    } catch (e) {
      return false;
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }
}
