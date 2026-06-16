// Nova Cabs - App Providers (Riverpod)
// State management for authentication, bookings, drivers, and agencies

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'extended_models.dart';
import 'models.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'app_logger.dart';

// ─── AUTH STATE ───────────────────────────────────────────────────────────────

class AuthState {
  final bool isLoggedIn;
  final UserRole? role;
  final String? userId;
  final String? userName;
  final String? userPhone;
  final String? userEmail;

  const AuthState({
    this.isLoggedIn = false,
    this.role,
    this.userId,
    this.userName,
    this.userPhone,
    this.userEmail,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    UserRole? role,
    String? userId,
    String? userName,
    String? userPhone,
    String? userEmail,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}

// Issue #12: AuthNotifier restores role+profile from Firestore when Firebase
// already has an active session (app restart scenario).
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  // Issue #5: store subscription so it can be cancelled on dispose
  StreamSubscription<User?>? _authSub;

  AuthNotifier(this._authService, this._firestoreService)
    : super(const AuthState()) {
    _authSub = _authService.authStateChanges.listen((user) async {
      if (user == null) {
        state = const AuthState();
        return;
      }
      // Issue #12: user is already signed in — restore full auth state
      await _restoreSession(user);
    });
  }

  /// Checks Firestore collections in order to determine the user's role
  /// and repopulate AuthState after an app restart.
  Future<void> _restoreSession(User user) async {
    try {
      // 1. Check admin custom claim first (fastest, no Firestore read)
      final idTokenResult = await user.getIdTokenResult();
      if (idTokenResult.claims?['admin'] == true) {
        state = AuthState(
          isLoggedIn: true,
          role: UserRole.admin,
          userId: user.uid,
          userName: 'Nova Admin',
          userEmail: user.email,
        );
        return;
      }

      // 2. Check drivers collection
      final driver = await _firestoreService.getDriverById(user.uid);
      if (driver != null) {
        state = AuthState(
          isLoggedIn: true,
          role: UserRole.driver,
          userId: user.uid,
          userName: driver.fullName,
          userPhone: driver.mobileNumber,
        );
        return;
      }

      // 3. Check agencies collection
      final agency = await _firestoreService.getAgencyById(user.uid);
      if (agency != null) {
        state = AuthState(
          isLoggedIn: true,
          role: UserRole.agency,
          userId: user.uid,
          userName: agency.agencyName,
          userPhone: agency.phoneNumber,
        );
        return;
      }

      // 4. Fall back to customer
      final customer = await _firestoreService.getCustomerById(user.uid);
      if (customer != null) {
        state = AuthState(
          isLoggedIn: true,
          role: UserRole.customer,
          userId: user.uid,
          userName: customer.name,
          userPhone: customer.phone,
        );
        return;
      }

      // 5. NEW USER — Don't sign out; keep them logged in as temporary customer
      // They'll create their full profile on next screen (registration/booking)
      AppLogger.w(
        'AuthNotifier: new user ${user.uid} not found in collections. Allowing to proceed.',
      );
      state = AuthState(
        isLoggedIn: true,
        role: UserRole.customer,
        userId: user.uid,
        userName: 'New User',
        userPhone: user.phoneNumber ?? '',
      );
    } catch (e, st) {
      AppLogger.e(
        'AuthNotifier._restoreSession failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Logs in (or registers) a customer.
  ///
  /// [existingId] — pass the document ID already stored in Firestore when
  /// the caller found an existing customer record by phone. This preserves
  /// the original document ID across sessions.
  ///
  /// If neither Firebase Auth nor [existingId] is available (e.g. MSG91 OTP
  /// without a Firebase session), a deterministic phone-based ID is generated
  /// so the user is always saved to Firestore.
  Future<void> loginAsCustomer({
    required String name,
    required String phone,
    String? existingId,
  }) async {
    final firebaseUser = _authService.currentUser;

    // ID priority: existing Firestore ID → Firebase UID → phone-based fallback
    final String userId = existingId ??
        firebaseUser?.uid ??
        'cust_${phone.replaceAll(RegExp(r'[^0-9]'), '')}';

    final customer = Customer(
      id: userId,
      name: name,
      phone: phone,
      email: firebaseUser?.email ?? '',
    );

    try {
      await _firestoreService.saveCustomer(customer);
      AppLogger.i('Customer login/register successful: $name ($phone) [id=$userId]');
    } catch (e, st) {
      AppLogger.e(
        'loginAsCustomer: Failed to save customer profile',
        error: e,
        stackTrace: st,
      );
      // Auth state is still set — user can continue browsing
    }

    state = AuthState(
      isLoggedIn: true,
      role: UserRole.customer,
      userId: userId,
      userName: name,
      userPhone: phone,
    );
  }

  void loginAsDriver({
    required String name,
    required String phone,
    required String id,
  }) {
    state = AuthState(
      isLoggedIn: true,
      role: UserRole.driver,
      userId: id,
      userName: name,
      userPhone: phone,
    );
  }

  void loginAsAgency({
    required String name,
    required String phone,
    required String id,
  }) {
    state = AuthState(
      isLoggedIn: true,
      role: UserRole.agency,
      userId: id,
      userName: name,
      userPhone: phone,
    );
  }

  void loginAsAdmin({required String email}) {
    final user = _authService.currentUser;
    if (user == null) {
      throw StateError(
        'Firebase admin user is not signed in. Ensure email/password sign-in completed successfully.',
      );
    }

    state = AuthState(
      isLoggedIn: true,
      role: UserRole.admin,
      userId: user.uid,
      userName: 'Nova Admin',
      userEmail: email,
    );
  }

  /// Updates the display name shown in the UI without re-fetching from Firestore.
  void updateDisplayName(String name) {
    state = state.copyWith(userName: name);
  }

  // Dev-only bypass — skips Firebase auth entirely for local testing
  void devBypassAdmin() {
    state = const AuthState(
      isLoggedIn: true,
      role: UserRole.admin,
      userId: 'dev-bypass-uid',
      userName: 'Dev Admin',
      userEmail: 'dev@novacabs.com',
    );
  }

  Future<void> logout() async {
    await _authService.signOut();
    state = const AuthState();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

// ─── DRIVER LIST PROVIDER ─────────────────────────────────────────────────────
// Issue #7: DriverListNotifier no longer opens its own Firestore stream.
// It is seeded from firestoreAllDriversProvider to avoid duplicate reads.

class DriverListNotifier extends StateNotifier<List<DriverModel>> {
  final FirestoreService _firestoreService;
  // Issue #5: stored subscription for proper cancellation
  StreamSubscription<List<DriverModel>>? _sub;

  DriverListNotifier(this._firestoreService) : super([]) {
    // Single stream — shared with firestoreAllDriversProvider via the same
    // FirestoreService instance (Firestore SDK de-duplicates identical queries).
    _sub = _firestoreService.streamAllDrivers().listen(
      (drivers) => state = drivers,
      onError: (Object e, StackTrace st) => AppLogger.e(
        'DriverListNotifier stream error',
        error: e,
        stackTrace: st,
      ),
    );
  }

  void _updateAndSave(
    String driverId,
    DriverModel Function(DriverModel) updateFn,
  ) {
    final driver = state.where((d) => d.id == driverId).firstOrNull;
    if (driver != null) {
      final updated = updateFn(driver);
      _firestoreService.saveDriver(updated);
      // State will be updated via the stream listener
    }
  }

  void approveDriver(String driverId) => _updateAndSave(
    driverId,
    (d) => d.copyWith(status: AccountStatus.approved),
  );

  void rejectDriver(String driverId, String remarks) => _updateAndSave(
    driverId,
    (d) => d.copyWith(status: AccountStatus.rejected, adminRemarks: remarks),
  );

  void suspendDriver(String driverId) => _updateAndSave(
    driverId,
    (d) => d.copyWith(status: AccountStatus.suspended),
  );

  void toggleOnlineStatus(String driverId) =>
      _updateAndSave(driverId, (d) => d.copyWith(isOnline: !d.isOnline));

  void addDriver(DriverModel driver) {
    _firestoreService.saveDriver(driver);
    // Stream will update state automatically
  }

  void updatePricing(String driverId, DriverPricing pricing) =>
      _updateAndSave(driverId, (d) => d.copyWith(pricing: pricing));

  void activateDriver(String driverId) => _updateAndSave(
    driverId,
    (d) => d.copyWith(status: AccountStatus.approved),
  );

  void unsuspendDriver(String driverId) => _updateAndSave(
    driverId,
    (d) => d.copyWith(status: AccountStatus.approved),
  );

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final driverListProvider =
    StateNotifierProvider<DriverListNotifier, List<DriverModel>>((ref) {
      return DriverListNotifier(ref.watch(firestoreServiceProvider));
    });

final pendingDriversProvider = Provider<List<DriverModel>>((ref) {
  return ref
      .watch(driverListProvider)
      .where((d) => d.status == AccountStatus.pendingVerification)
      .toList();
});

final approvedDriversProvider = Provider<List<DriverModel>>((ref) {
  return ref
      .watch(driverListProvider)
      .where((d) => d.status == AccountStatus.approved)
      .toList();
});

final onlineDriversProvider = Provider<List<DriverModel>>((ref) {
  return ref
      .watch(driverListProvider)
      .where((d) => d.isOnline && d.status == AccountStatus.approved)
      .toList();
});

class CustomerListNotifier extends StateNotifier<List<Customer>> {
  final FirestoreService _firestoreService;
  StreamSubscription<List<Customer>>? _sub;

  CustomerListNotifier(this._firestoreService) : super([]) {
    _sub = _firestoreService.streamAllCustomers().listen(
      (customers) => state = customers,
      onError: (Object e, StackTrace st) => AppLogger.e(
        'CustomerListNotifier stream error',
        error: e,
        stackTrace: st,
      ),
    );
  }

  Future<void> updateCustomerBlockStatus(
    String customerId,
    bool isBlocked,
  ) async {
    await _firestoreService.updateCustomerBlockStatus(customerId, isBlocked);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final customerListProvider =
    StateNotifierProvider<CustomerListNotifier, List<Customer>>((ref) {
      return CustomerListNotifier(ref.watch(firestoreServiceProvider));
    });

// ─── FIRESTORE STREAMS ────────────────────────────────────────────────────────

final firestoreOnlineDriversProvider = StreamProvider<List<DriverModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamOnlineDrivers();
});

final firestoreApprovedDriversProvider = StreamProvider<List<DriverModel>>((
  ref,
) {
  return ref.watch(firestoreServiceProvider).streamApprovedDrivers();
});

final firestoreAllDriversProvider = StreamProvider<List<DriverModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamAllDrivers();
});

final firestoreAllCustomersProvider = StreamProvider<List<Customer>>((ref) {
  return ref.watch(firestoreServiceProvider).streamAllCustomers();
});

final firestoreCustomerBookingsProvider =
    StreamProvider.family<List<TripRequest>, String>((ref, customerId) {
      return ref
          .watch(firestoreServiceProvider)
          .streamCustomerBookings(customerId);
    });

final firestoreDriverTripsProvider =
    StreamProvider.family<List<TripRequest>, String>((ref, driverId) {
      return ref.watch(firestoreServiceProvider).streamDriverTrips(driverId);
    });

final firestoreAgencyDriversProvider =
    StreamProvider.family<List<DriverModel>, String>((ref, agencyId) {
      return ref.watch(firestoreServiceProvider).streamAgencyDrivers(agencyId);
    });

final firestoreAllBookingsProvider = StreamProvider<List<TripRequest>>((ref) {
  return ref.watch(firestoreServiceProvider).streamAllBookings();
});

final firestoreAgenciesProvider = StreamProvider<List<AgencyModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamAgencies();
});

final firestoreOffersProvider = StreamProvider<List<BookingOffer>>((ref) {
  return ref.watch(firestoreServiceProvider).streamOffers();
});

final firestoreFeedbacksProvider = StreamProvider<List<CustomerFeedback>>((ref) {
  return ref.watch(firestoreServiceProvider).streamFeedbacks();
});

final firestoreNotificationTemplatesProvider = StreamProvider<List<NotificationTemplate>>((ref) {
  return ref.watch(firestoreServiceProvider).streamNotificationTemplates();
});

// ─── AGENCY LIST PROVIDER ─────────────────────────────────────────────────────
// Issue #7: AgencyListNotifier derives from firestoreAgenciesProvider

class AgencyListNotifier extends StateNotifier<List<AgencyModel>> {
  final FirestoreService _firestoreService;
  StreamSubscription<List<AgencyModel>>? _sub;

  AgencyListNotifier(this._firestoreService) : super([]) {
    _sub = _firestoreService.streamAgencies().listen(
      (agencies) => state = agencies,
      onError: (Object e, StackTrace st) => AppLogger.e(
        'AgencyListNotifier stream error',
        error: e,
        stackTrace: st,
      ),
    );
  }

  void _updateAndSave(
    String agencyId,
    AgencyModel Function(AgencyModel) updateFn,
  ) {
    final agency = state.where((a) => a.id == agencyId).firstOrNull;
    if (agency != null) {
      final updated = updateFn(agency);
      _firestoreService.saveAgency(updated);
    }
  }

  void approveAgency(String agencyId) => _updateAndSave(
    agencyId,
    (a) => a.copyWith(status: AccountStatus.approved),
  );

  void rejectAgency(String agencyId, String remarks) => _updateAndSave(
    agencyId,
    (a) => a.copyWith(status: AccountStatus.rejected, adminRemarks: remarks),
  );

  void suspendAgency(String agencyId) => _updateAndSave(
    agencyId,
    (a) => a.copyWith(status: AccountStatus.suspended),
  );

  void addAgency(AgencyModel agency) {
    _firestoreService.saveAgency(agency);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final agencyListProvider =
    StateNotifierProvider<AgencyListNotifier, List<AgencyModel>>((ref) {
      return AgencyListNotifier(ref.watch(firestoreServiceProvider));
    });

final pendingAgenciesProvider = Provider<List<AgencyModel>>((ref) {
  return ref
      .watch(agencyListProvider)
      .where((a) => a.status == AccountStatus.pendingVerification)
      .toList();
});

final approvedAgenciesProvider = Provider<List<AgencyModel>>((ref) {
  return ref
      .watch(agencyListProvider)
      .where((a) => a.status == AccountStatus.approved)
      .toList();
});

// ─── BOOKING PROVIDER ─────────────────────────────────────────────────────────
// Issue #7: BookingNotifier derives from firestoreAllBookingsProvider

class BookingNotifier extends StateNotifier<List<TripRequest>> {
  final FirestoreService _firestoreService;
  StreamSubscription<List<TripRequest>>? _sub;

  BookingNotifier(this._firestoreService) : super([]) {
    _sub = _firestoreService.streamAllBookings().listen(
      (bookings) => state = bookings,
      onError: (Object e, StackTrace st) =>
          AppLogger.e('BookingNotifier stream error', error: e, stackTrace: st),
    );
  }

  void addBooking(TripRequest booking) {
    _firestoreService.saveTripRequest(booking);
    // Stream will update state automatically
  }

  void updateStatus(String bookingId, BookingStatus status) {
    _firestoreService.updateTripStatus(bookingId, status);
  }

  void cancelBooking(String bookingId) {
    updateStatus(bookingId, BookingStatus.cancelled);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final bookingProvider =
    StateNotifierProvider<BookingNotifier, List<TripRequest>>((ref) {
      return BookingNotifier(ref.watch(firestoreServiceProvider));
    });

final currentDriverTripProvider = StateProvider<TripRequest?>((ref) => null);

// ─── SELECTED CAB TYPE PROVIDER ───────────────────────────────────────────────

final selectedCabTypeProvider = StateProvider<String>((ref) => '4-Seater');

// ─── OTP PROVIDER ─────────────────────────────────────────────────────────────

class OtpState {
  final bool isSent;
  final bool isVerifying;
  final bool isVerified;
  final String? error;
  final String phone;
  final String? verificationId;

  const OtpState({
    this.isSent = false,
    this.isVerifying = false,
    this.isVerified = false,
    this.error,
    this.phone = '',
    this.verificationId,
  });

  OtpState copyWith({
    bool? isSent,
    bool? isVerifying,
    bool? isVerified,
    String? error,
    String? phone,
    String? verificationId,
  }) {
    return OtpState(
      isSent: isSent ?? this.isSent,
      isVerifying: isVerifying ?? this.isVerifying,
      isVerified: isVerified ?? this.isVerified,
      error: error,
      phone: phone ?? this.phone,
      verificationId: verificationId ?? this.verificationId,
    );
  }
}

class OtpNotifier extends StateNotifier<OtpState> {
  final AuthService _authService;

  OtpNotifier(this._authService) : super(const OtpState());

  /// Sends OTP via MSG91. Returns [true] on success, [false] on failure.
  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isVerifying: true, phone: phone, error: null);
    final completer = Completer<bool>();

    try {
      await _authService.sendOtp(
        phoneNumber: phone,
        codeSent: (verificationId, resendToken) {
          // MSG91 uses phone number as the verification identifier
          state = state.copyWith(
            isSent: true,
            isVerifying: false,
            verificationId: verificationId,
          );
          if (!completer.isCompleted) completer.complete(true);
        },
        verificationFailed: (e) {
          AppLogger.e('OTP send failed', error: e);
          state = state.copyWith(
            isVerifying: false,
            error: 'Failed to send OTP. Please check your number.',
          );
          if (!completer.isCompleted) completer.complete(false);
        },
        onAutoVerified: () {
          state = state.copyWith(isVerified: true, isVerifying: false);
          if (!completer.isCompleted) completer.complete(true);
        },
      );
    } catch (e, st) {
      AppLogger.e('sendOtp threw', error: e, stackTrace: st);
      state = state.copyWith(
        isVerifying: false,
        error: 'Failed to send OTP. Please try again.',
      );
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future;
  }

  /// Verifies OTP via MSG91. Returns [true] on success, [false] on failure.
  Future<bool> verifyOtp(String otp) async {
    if (state.verificationId == null || state.phone.isEmpty) {
      state = state.copyWith(
        error: 'Phone number missing. Try sending OTP again.',
      );
      return false;
    }

    state = state.copyWith(isVerifying: true, error: null);

    try {
      final verified = await _authService.verifyOtp(state.phone, otp);
      if (verified) {
        state = state.copyWith(isVerified: true, isVerifying: false);
        return true;
      } else {
        state = state.copyWith(
          isVerifying: false,
          error: 'Incorrect OTP. Please check and try again.',
        );
        return false;
      }
    } catch (e) {
      AppLogger.e('OTP verification error', error: e);
      String msg = 'Invalid OTP. Please try again.';
      if (e is FirebaseAuthException) {
        if (e.message != null) msg = e.message!;
      }
      state = state.copyWith(isVerifying: false, error: msg);
      return false;
    }
  }

  void reset() {
    state = const OtpState();
  }
}

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>((ref) {
  return OtpNotifier(ref.watch(authServiceProvider));
});

// ─── DRIVER ONLINE STATUS ─────────────────────────────────────────────────────

final driverOnlineStatusProvider = StateProvider<bool>((ref) => false);

// ─── SEARCH PARAMS ────────────────────────────────────────────────────────────

class SearchParams {
  final String pickup;
  final String drop;
  final String cabType;
  final DateTime? tripDate;
  final String serviceType;

  const SearchParams({
    this.pickup = '',
    this.drop = '',
    this.cabType = '4-Seater',
    this.tripDate,
    this.serviceType = 'Rental Cabs',
  });

  SearchParams copyWith({
    String? pickup,
    String? drop,
    String? cabType,
    DateTime? tripDate,
    String? serviceType,
  }) {
    return SearchParams(
      pickup: pickup ?? this.pickup,
      drop: drop ?? this.drop,
      cabType: cabType ?? this.cabType,
      tripDate: tripDate ?? this.tripDate,
      serviceType: serviceType ?? this.serviceType,
    );
  }
}

final searchParamsProvider = StateProvider<SearchParams>(
  (ref) => const SearchParams(),
);
