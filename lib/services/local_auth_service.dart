import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final _auth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _auth.authenticate(
          localizedReason: 'Scan your fingerprint to authenticate',
          options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {return false;}
  }
  Future<void> saveUserData(String pin, String email) async {
    await _storage.write(key: 'user_pin', value: pin);
    await _storage.write(key: 'user_email', value: email);
  }
}
