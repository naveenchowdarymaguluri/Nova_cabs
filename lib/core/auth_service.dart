import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'msg91_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Msg91Service _msg91Service = Msg91Service();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Phone Authentication (using MSG91)
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(Exception e) verificationFailed,
    void Function()? onAutoVerified,
  }) async {
    try {
      // Normalize phone number to E.164 format if needed
      String normalizedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        if (phoneNumber.length == 10) {
          normalizedPhone = '+91$phoneNumber';
        } else if (phoneNumber.length == 12 && phoneNumber.startsWith('91')) {
          normalizedPhone = '+$phoneNumber';
        }
      }

      // Send OTP via MSG91
      final success = await _msg91Service.sendOtp(normalizedPhone);

      if (success) {
        // Use phone number as a pseudo-verification ID for MSG91 flow
        codeSent(normalizedPhone, null);
      } else {
        verificationFailed(Exception('Failed to send OTP via MSG91'));
      }
    } catch (e) {
      verificationFailed(Exception(e.toString()));
    }
  }

  Future<bool> verifyOtp(String phoneNumber, String smsCode) async {
    try {
      return await _msg91Service.verifyOtp(phoneNumber, smsCode);
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  // Email/Password (Admin)
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Google Sign In (Desktop)
  Future<UserCredential> signInWithGoogleDesktop() async {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile')
      ..setCustomParameters({'prompt': 'select_account'});

    return await _auth.signInWithProvider(provider);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
