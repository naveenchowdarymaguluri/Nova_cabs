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
  final bool isAvailable;

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

  Cab copyWith({
    String? id,
    String? model,
    String? type,
    String? agencyName,
    String? imageUrl,
    double? rating,
    double? pricePerKm,
    String? estimatedArrival,
    String? vehicleNumber,
    String? fuelType,
    bool? isAvailable,
  }) {
    return Cab(
      id: id ?? this.id,
      model: model ?? this.model,
      type: type ?? this.type,
      agencyName: agencyName ?? this.agencyName,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      pricePerKm: pricePerKm ?? this.pricePerKm,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      fuelType: fuelType ?? this.fuelType,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
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
  final bool isActive;

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

  BookingOffer copyWith({
    String? id,
    String? title,
    String? discount,
    String? validity,
    String? imageUrl,
    String? discountType,
    double? discountValue,
    List<String>? applicableCabTypes,
    bool? isActive,
  }) {
    return BookingOffer(
      id: id ?? this.id,
      title: title ?? this.title,
      discount: discount ?? this.discount,
      validity: validity ?? this.validity,
      imageUrl: imageUrl ?? this.imageUrl,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      applicableCabTypes: applicableCabTypes ?? this.applicableCabTypes,
      isActive: isActive ?? this.isActive,
    );
  }
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
  final bool isActive;

  TravelAgency({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.mobileNumber,
    required this.whatsappNumber,
    required this.email,
    required this.address,
    this.gstNumber = '',
    this.bankDetails = '',
    this.isActive = true,
  });

  TravelAgency copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? mobileNumber,
    String? whatsappNumber,
    String? email,
    String? address,
    String? gstNumber,
    String? bankDetails,
    bool? isActive,
  }) {
    return TravelAgency(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      gstNumber: gstNumber ?? this.gstNumber,
      bankDetails: bankDetails ?? this.bankDetails,
      isActive: isActive ?? this.isActive,
    );
  }
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final int totalBookings;
  final double totalSpent;
  final bool isBlocked;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.totalBookings = 0,
    this.totalSpent = 0.0,
    this.isBlocked = false,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    int? totalBookings,
    double? totalSpent,
    bool? isBlocked,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      totalBookings: totalBookings ?? this.totalBookings,
      totalSpent: totalSpent ?? this.totalSpent,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}

class CustomerFeedback {
  final String id;
  final String customerName;
  final String date;
  final double rating;
  final String comment;
  final String cabModel;
  final String agencyName;
  final bool isFlagged;

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

  CustomerFeedback copyWith({
    String? id,
    String? customerName,
    String? date,
    double? rating,
    String? comment,
    String? cabModel,
    String? agencyName,
    bool? isFlagged,
  }) {
    return CustomerFeedback(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      date: date ?? this.date,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      cabModel: cabModel ?? this.cabModel,
      agencyName: agencyName ?? this.agencyName,
      isFlagged: isFlagged ?? this.isFlagged,
    );
  }
}

class NotificationTemplate {
  final String id;
  String name; // Renamed from title to match mock data uses or vice-versa
  String template; // Renamed from body to match UI uses
  final String type; // SMS, Push, Email
  final bool isEnabled;

  NotificationTemplate({
    required this.id,
    required this.name,
    required this.template,
    required this.type,
    this.isEnabled = true,
  });

  NotificationTemplate copyWith({
    String? id,
    String? name,
    String? template,
    String? type,
    bool? isEnabled,
  }) {
    return NotificationTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      template: template ?? this.template,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
