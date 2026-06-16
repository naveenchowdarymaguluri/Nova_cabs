import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_logger.dart';

/// Wraps Firestore operations with error handling for database not found errors
class FirestoreErrorHandler {
  static Future<T?> executeWithErrorHandling<T>(
    Future<T> Function() operation, {
    required String operationName,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } on FirebaseException catch (e) {
      // Handle: NOT_FOUND - Database (default) does not exist
      if (e.code == 'not-found' ||
          e.message?.contains('database') == true ||
          e.message?.contains('does not exist') == true) {
        AppLogger.w(
          'Firestore database not initialized',
          error:
              'Database (default) does not exist for project.\n'
              'Action: Visit Firebase Console > Firestore Database > Create Database'
              '\nProject: nova-cabs-544fc',
        );
        return fallbackValue;
      }

      // Handle: PERMISSION_DENIED - Security rules blocked access
      if (e.code == 'permission-denied') {
        AppLogger.w(
          'Firestore permission denied',
          error:
              'Check Firebase Security Rules in Console > Firestore Database > Rules',
        );
        return fallbackValue;
      }

      // Handle: FAILED_PRECONDITION - Database in maintenance
      if (e.code == 'failed-precondition') {
        AppLogger.w(
          'Firestore temporarily unavailable',
          error:
              'Database is in maintenance or not ready. Try again in a moment.',
        );
        return fallbackValue;
      }

      // Handle: DEADLINE_EXCEEDED - Network timeout
      if (e.code == 'deadline-exceeded') {
        AppLogger.w(
          'Firestore operation timeout',
          error: 'Check your internet connection and try again.',
        );
        return fallbackValue;
      }

      // Generic error
      AppLogger.e(
        '$operationName failed: ${e.code}',
        error: e.message ?? 'Unknown Firestore error',
        stackTrace: StackTrace.current,
      );
      return fallbackValue;
    } catch (e, st) {
      AppLogger.e(
        '$operationName failed with exception',
        error: e,
        stackTrace: st,
      );
      return fallbackValue;
    }
  }

  /// Check if Firestore is available
  static Future<bool> isFirestoreAvailable() async {
    try {
      // Try a simple read operation with a timeout
      await Future.wait([
        FirebaseFirestore.instance
            .collection('_health_check')
            .doc('_ping')
            .get()
            .timeout(const Duration(seconds: 5)),
      ]);
      return true;
    } catch (e) {
      AppLogger.w('Firestore availability check failed', error: e);
      return false;
    }
  }
}
