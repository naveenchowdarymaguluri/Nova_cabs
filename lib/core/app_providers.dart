// Nova Cabs - App Providers (Riverpod)
// State management for authentication, bookings, drivers, and agencies

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'extended_models.dart';
import 'mock_data.dart';
import 'models.dart';
import 'extended_mock_data.dart';

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
  AuthNotifier() : super(const AuthState());

  void loginAsCustomer({required String name, required String phone}) {
    state = AuthState(
      isLoggedIn: true,
      role: UserRole.customer,
      userId: 'C${DateTime.now().millisecondsSinceEpoch}',
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

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// ─── DRIVER LIST PROVIDER ─────────────────────────────────────────────────────

class DriverListNotifier extends StateNotifier<List<DriverModel>> {
  DriverListNotifier() : super(MockDriverData.drivers);

  void approveDriver(String driverId) {
    state = state.map((d) {
      if (d.id == driverId) return d.copyWith(status: AccountStatus.approved);
      return d;
    }).toList();
  }

  void rejectDriver(String driverId, String remarks) {
    state = state.map((d) {
      if (d.id == driverId) {
        return d.copyWith(status: AccountStatus.rejected, adminRemarks: remarks);
      }
      return d;
    }).toList();
  }

  void suspendDriver(String driverId) {
    state = state.map((d) {
      if (d.id == driverId) return d.copyWith(status: AccountStatus.suspended);
      return d;
    }).toList();
  }

  void toggleOnlineStatus(String driverId) {
    state = state.map((d) {
      if (d.id == driverId) return d.copyWith(isOnline: !d.isOnline);
      return d;
    }).toList();
  }

  void addDriver(DriverModel driver) {
    state = [...state, driver];
  }

  void updatePricing(String driverId, DriverPricing pricing) {
    state = state.map((d) {
      if (d.id == driverId) return d.copyWith(pricing: pricing);
      return d;
    }).toList();
  }

  void activateDriver(String driverId) {
    state = state.map((d) {
      if (d.id == driverId) return d.copyWith(status: AccountStatus.approved);
      return d;
    }).toList();
  }

  void unsuspendDriver(String driverId) {
    state = state.map((d) {
      if (d.id == driverId) return d.copyWith(status: AccountStatus.approved);
      return d;
    }).toList();
  }
}

final driverListProvider = StateNotifierProvider<DriverListNotifier, List<DriverModel>>((ref) {
  return DriverListNotifier();
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

// ─── AGENCY LIST PROVIDER ─────────────────────────────────────────────────────

class AgencyListNotifier extends StateNotifier<List<AgencyModel>> {
  AgencyListNotifier() : super(MockAgencyData.agencies);

  void approveAgency(String agencyId) {
    state = state.map((a) {
      if (a.id == agencyId) return a.copyWith(status: AccountStatus.approved);
      return a;
    }).toList();
  }

  void rejectAgency(String agencyId, String remarks) {
    state = state.map((a) {
      if (a.id == agencyId) {
        return a.copyWith(status: AccountStatus.rejected, adminRemarks: remarks);
      }
      return a;
    }).toList();
  }

  void suspendAgency(String agencyId) {
    state = state.map((a) {
      if (a.id == agencyId) return a.copyWith(status: AccountStatus.suspended);
      return a;
    }).toList();
  }

  void addAgency(AgencyModel agency) {
    state = [...state, agency];
  }
}

final agencyListProvider = StateNotifierProvider<AgencyListNotifier, List<AgencyModel>>((ref) {
  return AgencyListNotifier();
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

class BookingNotifier extends StateNotifier<List<Booking>> {
  BookingNotifier() : super(MockData.bookings);

  void addBooking(Booking booking) {
    state = [booking, ...state];
  }

  void updateStatus(String bookingId, String status) {
    state = state.map((b) {
      if (b.id == bookingId) {
        b.status = status;
        return b;
      }
      return b;
    }).toList();
  }

  void cancelBooking(String bookingId) {
    updateStatus(bookingId, 'Cancelled');
  }
}

final bookingProvider = StateNotifierProvider<BookingNotifier, List<Booking>>((ref) {
  return BookingNotifier();
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
  OtpNotifier() : super(const OtpState());

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isVerifying: true, phone: phone, error: null);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isSent: true, isVerifying: false);
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isVerifying: true, error: null);
    await Future.delayed(const Duration(seconds: 1));
    // For demo: any 6-digit OTP works, or use 123456
    if (otp.length == 6) {
      state = state.copyWith(isVerified: true, isVerifying: false);
      return true;
    } else {
      state = state.copyWith(isVerifying: false, error: 'Invalid OTP. Please try again.');
      return false;
    }
  }

  void reset() {
    state = const OtpState();
  }
}

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>((ref) {
  return OtpNotifier();
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
