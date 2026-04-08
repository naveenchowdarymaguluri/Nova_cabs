// Nova Cabs - Extended Models
// Complete data models for all platform entities

// ─── ENUMS ────────────────────────────────────────────────────────────────────

enum UserRole { customer, driver, agency, admin }

enum DriverType { individual, agency }

enum AccountStatus {
  pendingVerification,
  approved,
  rejected,
  suspended,
  active,
  inactive
}

enum BookingStatus {
  searched,
  booked,
  driverAccepted,
  driverArriving,
  tripStarted,
  tripCompleted,
  paymentCompleted,
  cancelled,
  // Legacy statuses for backward compat
  confirmed,
  ongoing,
  completed,
  newBooking,
}

enum PaymentMethod { upi, cash, online }

enum PaymentStatus { pending, success, failed, refunded }

// ─── DRIVER MODEL ─────────────────────────────────────────────────────────────

class DriverModel {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String aadhaarNumber;
  final String drivingLicense;
  final String vehicleNumber;
  final String vehicleRc;
  final String insuranceNumber;
  final List<String> vehicleImages;
  final String vehicleType; // 4-Seater, 7-Seater, 13-Seater
  final String vehicleModel;
  final DriverType driverType;
  final String? agencyId; // Only for agency drivers
  final String? agencyName;
  final AccountStatus status;
  final DriverPricing? pricing;
  final bool isOnline;
  final double rating;
  final int totalTrips;
  final double totalEarnings;
  final String? profileImage;
  final DateTime registeredAt;
  final String? adminRemarks;

  const DriverModel({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.aadhaarNumber,
    required this.drivingLicense,
    required this.vehicleNumber,
    required this.vehicleRc,
    required this.insuranceNumber,
    this.vehicleImages = const [],
    required this.vehicleType,
    this.vehicleModel = '',
    required this.driverType,
    this.agencyId,
    this.agencyName,
    this.status = AccountStatus.pendingVerification,
    this.pricing,
    this.isOnline = false,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.totalEarnings = 0.0,
    this.profileImage,
    required this.registeredAt,
    this.adminRemarks,
  });

  DriverModel copyWith({
    AccountStatus? status,
    DriverPricing? pricing,
    bool? isOnline,
    double? rating,
    int? totalTrips,
    double? totalEarnings,
    String? adminRemarks,
  }) {
    return DriverModel(
      id: id,
      fullName: fullName,
      mobileNumber: mobileNumber,
      aadhaarNumber: aadhaarNumber,
      drivingLicense: drivingLicense,
      vehicleNumber: vehicleNumber,
      vehicleRc: vehicleRc,
      insuranceNumber: insuranceNumber,
      vehicleImages: vehicleImages,
      vehicleType: vehicleType,
      vehicleModel: vehicleModel,
      driverType: driverType,
      agencyId: agencyId,
      agencyName: agencyName,
      status: status ?? this.status,
      pricing: pricing ?? this.pricing,
      isOnline: isOnline ?? this.isOnline,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      profileImage: profileImage,
      registeredAt: registeredAt,
      adminRemarks: adminRemarks ?? this.adminRemarks,
    );
  }

  String get statusLabel {
    switch (status) {
      case AccountStatus.pendingVerification:
        return 'Pending Verification';
      case AccountStatus.approved:
      case AccountStatus.active:
        return 'Approved';
      case AccountStatus.rejected:
        return 'Rejected';
      case AccountStatus.suspended:
        return 'Suspended';
      case AccountStatus.inactive:
        return 'Inactive';
    }
  }
}

// ─── DRIVER PRICING MODEL ─────────────────────────────────────────────────────

class DriverPricing {
  final double baseFare;
  final double pricePerKm;
  final double pricePerHour;
  final double waitingCharges; // per minute
  final double nightCharges;
  final double minimumTripDistance;
  final double driverAllowance;
  final String tollPolicy; // Included / Extra / Not Applicable

  const DriverPricing({
    this.baseFare = 100.0,
    this.pricePerKm = 12.0,
    this.pricePerHour = 200.0,
    this.waitingCharges = 2.0,
    this.nightCharges = 150.0,
    this.minimumTripDistance = 10.0,
    this.driverAllowance = 300.0,
    this.tollPolicy = 'Extra',
  });

  double estimateFare(double distanceKm) {
    return baseFare + (distanceKm * pricePerKm);
  }

  double calculateFinalFare({
    required double actualDistanceKm,
    int waitingMinutes = 0,
    bool isNightTrip = false,
    double tollCharges = 0,
  }) {
    double fare = baseFare + (actualDistanceKm * pricePerKm);
    fare += waitingMinutes * waitingCharges;
    if (isNightTrip) fare += nightCharges;
    if (tollPolicy == 'Extra') fare += tollCharges;
    fare += driverAllowance;
    return fare;
  }
}

// ─── TRAVEL AGENCY MODEL (Extended) ───────────────────────────────────────────

class AgencyModel {
  final String id;
  final String agencyName;
  final String ownerName;
  final String phoneNumber;
  final String businessAddress;
  final String? gstNumber;
  final String bankDetails;
  final String? documentsPath;
  final AccountStatus status;
  final int totalDrivers;
  final int totalVehicles;
  final double totalEarnings;
  final int totalBookings;
  final DateTime registeredAt;
  final String? adminRemarks;
  final String email;

  const AgencyModel({
    required this.id,
    required this.agencyName,
    required this.ownerName,
    required this.phoneNumber,
    required this.businessAddress,
    this.gstNumber,
    required this.bankDetails,
    this.documentsPath,
    this.status = AccountStatus.pendingVerification,
    this.totalDrivers = 0,
    this.totalVehicles = 0,
    this.totalEarnings = 0.0,
    this.totalBookings = 0,
    required this.registeredAt,
    this.adminRemarks,
    this.email = '',
  });

  String get statusLabel {
    switch (status) {
      case AccountStatus.pendingVerification:
        return 'Pending Approval';
      case AccountStatus.approved:
      case AccountStatus.active:
        return 'Approved';
      case AccountStatus.rejected:
        return 'Rejected';
      case AccountStatus.suspended:
        return 'Suspended';
      case AccountStatus.inactive:
        return 'Inactive';
    }
  }

  AgencyModel copyWith({
    AccountStatus? status,
    int? totalDrivers,
    int? totalVehicles,
    double? totalEarnings,
    int? totalBookings,
    String? adminRemarks,
  }) {
    return AgencyModel(
      id: id,
      agencyName: agencyName,
      ownerName: ownerName,
      phoneNumber: phoneNumber,
      businessAddress: businessAddress,
      gstNumber: gstNumber,
      bankDetails: bankDetails,
      documentsPath: documentsPath,
      status: status ?? this.status,
      totalDrivers: totalDrivers ?? this.totalDrivers,
      totalVehicles: totalVehicles ?? this.totalVehicles,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalBookings: totalBookings ?? this.totalBookings,
      registeredAt: registeredAt,
      adminRemarks: adminRemarks ?? this.adminRemarks,
      email: email,
    );
  }
}

// ─── TRIP REQUEST MODEL ───────────────────────────────────────────────────────

class TripRequest {
  final String id;
  final String bookingId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String pickupLocation;
  final String dropLocation;
  final double estimatedDistance;
  final double estimatedFare;
  final String cabType;
  final DateTime tripDate;
  final String tripTime;
  final BookingStatus status;
  final String? driverId;
  final double advancePaid;
  final double? finalFare;
  final double? actualDistance;
  final String? rentalPackage;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final double? customerRating;
  final String? customerFeedback;
  final DateTime createdAt;

  const TripRequest({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.pickupLocation,
    required this.dropLocation,
    required this.estimatedDistance,
    required this.estimatedFare,
    required this.cabType,
    required this.tripDate,
    required this.tripTime,
    this.status = BookingStatus.booked,
    this.driverId,
    this.advancePaid = 500.0,
    this.finalFare,
    this.actualDistance,
    this.rentalPackage,
    this.paymentMethod = PaymentMethod.upi,
    this.paymentStatus = PaymentStatus.pending,
    this.customerRating,
    this.customerFeedback,
    required this.createdAt,
  });
}

// ─── VEHICLE MODEL ────────────────────────────────────────────────────────────

class VehicleModel {
  final String id;
  final String vehicleNumber;
  final String model;
  final String type; // 4-Seater, 7-Seater, 13-Seater
  final String fuelType;
  final String rcNumber;
  final String insuranceNumber;
  final String? agencyId;
  final String? driverId;
  final bool isActive;
  final List<String> images;
  final int year;

  const VehicleModel({
    required this.id,
    required this.vehicleNumber,
    required this.model,
    required this.type,
    required this.fuelType,
    required this.rcNumber,
    required this.insuranceNumber,
    this.agencyId,
    this.driverId,
    this.isActive = true,
    this.images = const [],
    required this.year,
  });
}

// ─── EARNING RECORD ───────────────────────────────────────────────────────────

class EarningRecord {
  final String id;
  final String tripId;
  final String driverId;
  final DateTime date;
  final double amount;
  final double platformFee;
  final double netEarning;
  final String status; // Pending, Settled

  const EarningRecord({
    required this.id,
    required this.tripId,
    required this.driverId,
    required this.date,
    required this.amount,
    required this.platformFee,
    required this.netEarning,
    this.status = 'Pending',
  });
}
