// Nova Cabs - App Providers (Riverpod)
// State management for authentication, bookings, drivers, and agencies

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'extended_models.dart';
import 'mock_data.dart';
import 'models.dart';
import 'extended_mock_data.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'msg91_service.dart';

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

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthNotifier(this._authService, this._firestoreService) : super(const AuthState()) {
    // Listen to Firebase Auth changes
    _authService.authStateChanges.listen((user) {
      if (user == null) {
        state = const AuthState();
      } else {
        // Here we could fetch the user role/profile from Firestore
        // For now, we'll keep the current state if already logged in
      }
    });
  }

  Future<void> loginAsCustomer({required String name, required String phone}) async {
    final userId = _authService.currentUser?.uid ?? 'C${DateTime.now().millisecondsSinceEpoch}';
    
    final customer = Customer(
      id: userId,
      name: name,
      phone: phone,
      email: '',
    );

    await _firestoreService.saveCustomer(customer);

    state = AuthState(
      isLoggedIn: true,
      role: UserRole.customer,
      userId: userId,
      userName: name,
      userPhone: phone,
    );
  }

  void loginAsDriver({required String name, required String phone, required String id}) {
    state = AuthState(
      isLoggedIn: true,
      role: UserRole.driver,
      userId: id,
      userName: name,
      userPhone: phone,
    );
  }

  void loginAsAgency({required String name, required String phone, required String id}) {
    state = AuthState(
      isLoggedIn: true,
      role: UserRole.agency,
      userId: id,
      userName: name,
      userPhone: phone,
    );
  }

  void loginAsAdmin({required String email}) {
    state = AuthState(
      isLoggedIn: true,
      role: UserRole.admin,
      userId: 'ADMIN001',
      userName: 'Nova Admin',
      userEmail: email,
    );
  }

  Future<void> logout() async {
    await _authService.signOut();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

// ─── DRIVER LIST PROVIDER ─────────────────────────────────────────────────────

class DriverListNotifier extends StateNotifier<List<DriverModel>> {
  final FirestoreService _firestoreService;

  DriverListNotifier(this._firestoreService) : super([]) {
    _listenToDrivers();
  }

  void _listenToDrivers() {
    _firestoreService.streamAllDrivers().listen((drivers) {
      state = drivers;
    });
  }

  void _updateAndSave(String driverId, DriverModel Function(DriverModel) updateFn) {
    final driver = state.where((d) => d.id == driverId).firstOrNull;
    if (driver != null) {
      final updated = updateFn(driver);
      _firestoreService.saveDriver(updated);
      // State will be updated via the stream listener
    }
  }

  void approveDriver(String driverId) {
    _updateAndSave(driverId, (d) => d.copyWith(status: AccountStatus.approved));
  }

  void rejectDriver(String driverId, String remarks) {
    _updateAndSave(driverId, (d) => d.copyWith(status: AccountStatus.rejected, adminRemarks: remarks));
  }

  void suspendDriver(String driverId) {
    _updateAndSave(driverId, (d) => d.copyWith(status: AccountStatus.suspended));
  }

  void toggleOnlineStatus(String driverId) {
    _updateAndSave(driverId, (d) => d.copyWith(isOnline: !d.isOnline));
  }

  void addDriver(DriverModel driver) {
    _firestoreService.saveDriver(driver);
    state = [...state, driver];
  }

  void updatePricing(String driverId, DriverPricing pricing) {
    _updateAndSave(driverId, (d) => d.copyWith(pricing: pricing));
  }

  void activateDriver(String driverId) {
    _updateAndSave(driverId, (d) => d.copyWith(status: AccountStatus.approved));
  }

  void unsuspendDriver(String driverId) {
    _updateAndSave(driverId, (d) => d.copyWith(status: AccountStatus.approved));
  }
}

final driverListProvider = StateNotifierProvider<DriverListNotifier, List<DriverModel>>((ref) {
  return DriverListNotifier(ref.watch(firestoreServiceProvider));
});

// Pending drivers (for admin approval)
final pendingDriversProvider = Provider<List<DriverModel>>((ref) {
  return ref.watch(driverListProvider).where((d) => d.status == AccountStatus.pendingVerification).toList();
});

// Approved drivers (for booking)
final approvedDriversProvider = Provider<List<DriverModel>>((ref) {
  return ref.watch(driverListProvider).where((d) => d.status == AccountStatus.approved).toList();
});

// Online drivers
final onlineDriversProvider = Provider<List<DriverModel>>((ref) {
  return ref.watch(driverListProvider).where((d) => d.isOnline && d.status == AccountStatus.approved).toList();
});

// ─── FIRESTORE STREAMS ────────────────────────────────────────────────────────

// Listens directly to Firestore for online drivers
final firestoreOnlineDriversProvider = StreamProvider<List<DriverModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamOnlineDrivers();
});

// Listens directly to Firestore for approved drivers
final firestoreApprovedDriversProvider = StreamProvider<List<DriverModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamApprovedDrivers();
});

final firestoreAllDriversProvider = StreamProvider<List<DriverModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamAllDrivers();
});

// Listens to bookings for a specific customer
final firestoreCustomerBookingsProvider = StreamProvider.family<List<TripRequest>, String>((ref, customerId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamCustomerBookings(customerId);
});

// Listens to trips assigned to a specific driver
final firestoreDriverTripsProvider = StreamProvider.family<List<TripRequest>, String>((ref, driverId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamDriverTrips(driverId);
});

final firestoreAgencyDriversProvider = StreamProvider.family<List<DriverModel>, String>((ref, agencyId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamAgencyDrivers(agencyId);
});

final firestoreAllBookingsProvider = StreamProvider<List<TripRequest>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamAllBookings();
});

final firestoreAgenciesProvider = StreamProvider<List<AgencyModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamAgencies();
});

final firestoreOffersProvider = StreamProvider<List<Offer>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamOffers();
});

// ─── AGENCY LIST PROVIDER ─────────────────────────────────────────────────────

class AgencyListNotifier extends StateNotifier<List<AgencyModel>> {
  final FirestoreService _firestoreService;

  AgencyListNotifier(this._firestoreService) : super([]) {
    _listenToAgencies();
  }

  void _listenToAgencies() {
    _firestoreService.streamAgencies().listen((agencies) {
      state = agencies;
    });
  }

  void _updateAndSave(String agencyId, AgencyModel Function(AgencyModel) updateFn) {
    final agency = state.where((a) => a.id == agencyId).firstOrNull;
    if (agency != null) {
      final updated = updateFn(agency);
      _firestoreService.saveAgency(updated);
      // State will be updated via the stream listener
    }
  }

  void approveAgency(String agencyId) {
    _updateAndSave(agencyId, (a) => a.copyWith(status: AccountStatus.approved));
  }

  void rejectAgency(String agencyId, String remarks) {
    _updateAndSave(agencyId, (a) => a.copyWith(status: AccountStatus.rejected, adminRemarks: remarks));
  }

  void suspendAgency(String agencyId) {
    _updateAndSave(agencyId, (a) => a.copyWith(status: AccountStatus.suspended));
  }

  void addAgency(AgencyModel agency) {
    _firestoreService.saveAgency(agency);
    state = [...state, agency];
  }
}

final agencyListProvider = StateNotifierProvider<AgencyListNotifier, List<AgencyModel>>((ref) {
  return AgencyListNotifier(ref.watch(firestoreServiceProvider));
});

final pendingAgenciesProvider = Provider<List<AgencyModel>>((ref) {
  return ref.watch(agencyListProvider)
      .where((a) => a.status == AccountStatus.pendingVerification)
      .toList();
});

final approvedAgenciesProvider = Provider<List<AgencyModel>>((ref) {
  return ref.watch(agencyListProvider)
      .where((a) => a.status == AccountStatus.approved)
      .toList();
});

// ─── BOOKING PROVIDER ─────────────────────────────────────────────────────────

class BookingNotifier extends StateNotifier<List<TripRequest>> {
  final FirestoreService _firestoreService;

  BookingNotifier(this._firestoreService) : super([]) {
    _listenToBookings();
  }

  void _listenToBookings() {
    _firestoreService.streamAllBookings().listen((bookings) {
      state = bookings;
    });
  }

  void addBooking(TripRequest booking) {
    _firestoreService.saveTripRequest(booking);
  }

  void updateStatus(String bookingId, BookingStatus status) {
    _firestoreService.updateTripStatus(bookingId, status);
  }

  void cancelBooking(String bookingId) {
    updateStatus(bookingId, BookingStatus.cancelled);
  }
}

final bookingProvider = StateNotifierProvider<BookingNotifier, List<TripRequest>>((ref) {
  return BookingNotifier(ref.watch(firestoreServiceProvider));
});

// Driver-specific current trip
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

  const OtpState({
    this.isSent = false,
    this.isVerifying = false,
    this.isVerified = false,
    this.error,
    this.phone = '',
  });

  OtpState copyWith({
    bool? isSent,
    bool? isVerifying,
    bool? isVerified,
    String? error,
    String? phone,
  }) {
    return OtpState(
      isSent: isSent ?? this.isSent,
      isVerifying: isVerifying ?? this.isVerifying,
      isVerified: isVerified ?? this.isVerified,
      error: error,
      phone: phone ?? this.phone,
    );
  }
}

class OtpNotifier extends StateNotifier<OtpState> {
  final Msg91Service _msg91Service;

  OtpNotifier(this._msg91Service) : super(const OtpState());

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isVerifying: true, phone: phone, error: null);
    
    // Using real Msg91 service
    final success = await _msg91Service.sendOtp(phone);
    
    if (success) {
      state = state.copyWith(isSent: true, isVerifying: false);
    } else {
      state = state.copyWith(
        isVerifying: false, 
        error: 'Failed to send OTP. Please check your phone number or try again later.'
      );
    }
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isVerifying: true, error: null);
    
    // Using real Msg91 service for verification
    final success = await _msg91Service.verifyOtp(state.phone, otp);
    
    if (success) {
      state = state.copyWith(isVerified: true, isVerifying: false);
      return true;
    } else {
      state = state.copyWith(
        isVerifying: false, 
        error: 'Invalid OTP. Please try again.'
      );
      return false;
    }
  }

  void reset() {
    state = const OtpState();
  }
}

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>((ref) {
  return OtpNotifier(ref.watch(msg91ServiceProvider));
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

final searchParamsProvider = StateProvider<SearchParams>((ref) => const SearchParams());
