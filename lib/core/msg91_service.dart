import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Msg91Service {
  final String _baseUrl = 'https://api.msg91.com/api/v5/otp';
  final String _authKey = AppConfig.msg91AuthKey;
  final String _templateId = AppConfig.msg91TemplateId;

  /// Normalizes phone to format without +.
  /// Removes +, and keeps only digits.
  String _normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 10) return '91$digits'; // Add India code
    if (digits.length == 12 && digits.startsWith('91')) return digits;
    return digits;
  }

  Future<bool> sendOtp(String mobile) async {
    if (_authKey.isEmpty || _authKey.startsWith('YOUR_') || _templateId.isEmpty) {
      AppLogger.w('MSG91: Auth Key/Template ID not set. Simulated OTP mode (demo only, use 123456)');
      return true; // Simulate success in dev mode
    }

    final normalizedMobile = _normalizePhone(mobile);
    final url = Uri.parse(
      '$_baseUrl?template_id=$_templateId&mobile=$normalizedMobile&authkey=$_authKey',
    );

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['type'] == 'success') {
          AppLogger.i('MSG91: OTP sent to $normalizedMobile');
          return true;
        } else {
          AppLogger.w('MSG91 send failed: ${data['message'] ?? 'Unknown error'}');
          return false;
        }
      } else {
        AppLogger.w('MSG91 HTTP error ${response.statusCode}');
        return false;
      }
    } catch (e, st) {
      AppLogger.e('MSG91 sendOtp exception', error: e, stackTrace: st);
      return false;
    }
  }

  Future<bool> verifyOtp(String mobile, String otp) async {
    if (_authKey.isEmpty || _authKey.startsWith('YOUR_')) {
      AppLogger.w('MSG91: Demo mode — OTP verification (use 123456)');
      return otp == '123456'; // Demo: accept hardcoded OTP
    }

    final normalizedMobile = _normalizePhone(mobile);
    final url = Uri.parse(
      '$_baseUrl/verify?otp=$otp&mobile=$normalizedMobile&authkey=$_authKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['type'] == 'success') {
          AppLogger.i('MSG91: OTP verified for $normalizedMobile');
          return true;
        } else {
          AppLogger.w('MSG91 verify failed: ${data['message'] ?? 'Invalid OTP'}');
          return false;
        }
      } else {
        AppLogger.w('MSG91 HTTP error ${response.statusCode}');
        return false;
      }
    } catch (e, st) {
      AppLogger.e('MSG91 verifyOtp exception', error: e, stackTrace: st);
      return false;
    }
  }
}

final msg91ServiceProvider = Provider<Msg91Service>((ref) {
  return Msg91Service();
});
