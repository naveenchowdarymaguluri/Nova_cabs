class Cab {
  final String id;
  final String model;
  final String type; // 4-Seater, 7-Seater, 13-Seater
  final String agencyName;
  final String imageUrl;
  final double rating;
  final double pricePerKm;
  final String estimatedArrival;
  final String vehicleNumber;
  final String fuelType;
  bool isAvailable;

  Cab({
    required this.id,
    required this.model,
    required this.type,
    required this.agencyName,
    required this.imageUrl,
    required this.rating,
    required this.pricePerKm,
    required this.estimatedArrival,
    this.vehicleNumber = 'KA-01-MJ-1234',
    this.fuelType = 'Petrol',
    this.isAvailable = true,
  });
}

class BookingOffer {
  final String id;
  final String title;
  final String discount;
  final String validity;
  final String imageUrl;
  final String discountType; // Flat or Percentage
  final double discountValue;
  final List<String> applicableCabTypes;
  bool isActive;

  BookingOffer({
    required this.id,
    required this.title,
    required this.discount,
    required this.validity,
    required this.imageUrl,
    this.discountType = 'Percentage',
    this.discountValue = 20,
    this.applicableCabTypes = const ['4-Seater', '7-Seater', '13-Seater'],
    this.isActive = true,
  });
}

class Booking {
  final String id;
  final String pickupLocation;
  final String dropLocation;
  final String date;
  final String time;
  final Cab cab;
  final double totalDistance;
  final double totalFare;
  String status; // New, Confirmed, Ongoing, Completed, Cancelled
  final String? driverId;
  final String customerName;
  final String customerPhone;
  final String paymentMethod;
  final String paymentStatus;
  final String? rentalPackage;

  Booking({
    required this.id,
    required this.pickupLocation,
    required this.dropLocation,
    required this.date,
    required this.time,
    required this.cab,
    required this.totalDistance,
    required this.totalFare,
    required this.status,
    this.driverId,
    this.customerName = 'Customer',
    this.customerPhone = '+91 9876543210',
    this.paymentMethod = 'UPI',
    this.paymentStatus = 'Success',
    this.rentalPackage,
  });
}

class TravelAgency {
  final String id;
  final String name;
  final String contactPerson;
  final String mobileNumber;
  final String whatsappNumber;
  final String email;
  final String address;
  final String gstNumber;
  final String bankDetails;
  bool isActive;

  TravelAgency({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.mobileNumber,
    required this.whatsappNumber,
    required this.email,
    required this.address,
    required this.gstNumber,
    required this.bankDetails,
    this.isActive = true,
  });
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final int totalBookings;
  final double totalSpent;
  bool isBlocked; // Changed to non-final to allow UI updates

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.totalBookings = 0,
    this.totalSpent = 0.0,
    this.isBlocked = false,
  });
}

class CustomerFeedback {
  final String id;
  final String customerName;
  final String date;
  final double rating;
  final String comment;
  final String cabModel;
  final String agencyName;
  bool isFlagged;

  CustomerFeedback({
    required this.id,
    required this.customerName,
    required this.date,
    required this.rating,
    required this.comment,
    this.cabModel = 'Toyota Camry',
    this.agencyName = 'Quick Travels',
    this.isFlagged = false,
  });
}

class NotificationTemplate {
  final String id;
  String name; // Renamed from title to match mock data uses or vice-versa
  String template; // Renamed from body to match UI uses
  final String type; // SMS, Push, Email
  bool isEnabled;

  NotificationTemplate({
    required this.id,
    required this.name,
    required this.template,
    required this.type,
    this.isEnabled = true,
  });
}
