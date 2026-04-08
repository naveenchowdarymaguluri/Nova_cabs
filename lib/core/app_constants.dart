// Nova Cabs - App Constants
// Production-ready constants for the entire platform

class AppConstants {
  // App Info
  static const String appName = 'Nova Cabs';
  static const String appVersion = '1.0.0';
  static const String supportPhone = '+91 80000 00000';
  static const String supportEmail = 'support@novacabs.com';
  static const String adminEmail = 'admin@novacabs.com';

  // Booking
  static const double advanceAmount = 500.0;
  static const double defaultBaseFare = 100.0;
  static const double defaultPricePerKm = 12.0;
  static const double defaultPricePerHour = 200.0;
  static const double defaultNightCharge = 150.0;
  static const double defaultWaitingCharge = 2.0; // per minute
  static const double defaultDriverAllowance = 300.0;

  // Booking lifecycle statuses
  static const String statusSearched = 'SEARCHED';
  static const String statusBooked = 'BOOKED';
  static const String statusDriverAccepted = 'DRIVER_ACCEPTED';
  static const String statusDriverArriving = 'DRIVER_ARRIVING';
  static const String statusTripStarted = 'TRIP_STARTED';
  static const String statusTripCompleted = 'TRIP_COMPLETED';
  static const String statusPaymentCompleted = 'PAYMENT_COMPLETED';

  // Driver statuses
  static const String driverPendingVerification = 'PENDING_VERIFICATION';
  static const String driverApproved = 'APPROVED';
  static const String driverRejected = 'REJECTED';
  static const String driverSuspended = 'SUSPENDED';

  // Agency statuses
  static const String agencyPendingApproval = 'PENDING_APPROVAL';
  static const String agencyApproved = 'APPROVED';
  static const String agencyRejected = 'REJECTED';
  static const String agencySuspended = 'SUSPENDED';

  // Vehicle types
  static const List<String> vehicleTypes = ['4-Seater', '7-Seater', '13-Seater'];

  // Driver types
  static const String driverTypeIndividual = 'Individual Driver';
  static const String driverTypeAgency = 'Agency Driver';

  // Payment methods
  static const List<String> paymentMethods = ['UPI', 'Cash', 'Online'];

  // Colors (Hex)
  static const int primaryColorHex = 0xFF1A237E;
  static const int accentColorHex = 0xFFFFC107;
}
