import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthPrefs {
  AuthPrefs._internal();

  static final AuthPrefs instance = AuthPrefs._internal();

  static const _pinKey = 'user_pin';
  static const _biometricEnabledKey = 'biometric_enabled';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> setPin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);
  }

  Future<String> getPin() async {
    return await _secureStorage.read(key: _pinKey) ?? '';
  }

  Future<bool> hasPin() async {
    final value = await _secureStorage.read(key: _pinKey);
    return value != null && value.isNotEmpty;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: enabled ? '1' : '0',
    );
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _biometricEnabledKey);
    return value == '1';
  }

  /// Whether the device supports biometrics and has at least one enrolled
  /// (face or fingerprint on Android, Face ID / Touch ID on iOS).
  Future<bool> isBiometricAvailable() async {
    try {
      if (!await _localAuth.isDeviceSupported()) return false;
      if (!await _localAuth.canCheckBiometrics) return false;
      final types = await _localAuth.getAvailableBiometrics();
      return types.isNotEmpty;
    } on PlatformException catch (e) {
      debugPrint('isBiometricAvailable: $e');
      return false;
    }
  }

  /// Human-readable name of the enrolled biometric, for UI labels.
  Future<String> biometricLabel() async {
    try {
      final types = await _localAuth.getAvailableBiometrics();
      final hasFace = types.contains(BiometricType.face);
      final hasFingerprint = types.contains(BiometricType.fingerprint);
      if (hasFace && hasFingerprint) return 'Face or Fingerprint';
      if (hasFace) return 'Face';
      if (hasFingerprint) return 'Fingerprint';
      return 'Biometric';
    } on PlatformException catch (e) {
      debugPrint('biometricLabel: $e');
      return 'Biometric';
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isSupported) {
        return false;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (didAuthenticate) {
        await setBiometricEnabled(true);
      }
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
