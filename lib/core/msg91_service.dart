import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Msg91Service {
  final String _baseUrl = 'https://api.msg91.com/api/v5/otp';
  final String? _authKey = dotenv.env['MSG91_AUTH_KEY'];
  final String? _templateId = dotenv.env['MSG91_TEMPLATE_ID'];

  Future<bool> sendOtp(String mobile) async {
    if (_authKey == null || _templateId == null) {
      print('MSG91: Auth Key or Template ID not found in .env');
      return false;
    }

    // Ensure mobile includes country code but some APIs expect it without +
    // MSG91 usually expects country code without + or as separate param.
    // For simplicity, we assume mobile is passed correctly (e.g., 919876543210)
    
    final url = Uri.parse('$_baseUrl?template_id=$_templateId&mobile=$mobile&authkey=$_authKey');

    try {
      final response = await http.post(url);
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['type'] == 'success') {
        print('MSG91: OTP sent successfully');
        return true;
      } else {
        print('MSG91 Error: ${data['message']}');
        return false;
      }
    } catch (e) {
      print('MSG91 Exception: $e');
      return false;
    }
  }

  Future<bool> verifyOtp(String mobile, String otp) async {
    if (_authKey == null) return false;

    final url = Uri.parse('$_baseUrl/verify?otp=$otp&mobile=$mobile&authkey=$_authKey');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['type'] == 'success') {
        print('MSG91: OTP verified successfully');
        return true;
      } else {
        print('MSG91 Error: ${data['message']}');
        return false;
      }
    } catch (e) {
      print('MSG91 Exception: $e');
      return false;
    }
  }
}

final msg91ServiceProvider = Provider<Msg91Service>((ref) {
  return Msg91Service();
});
