import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'extended_models.dart';
import 'models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── CUSTOMERS ─────────────────────────────────────────────────────────────
  
  Future<void> saveCustomer(Customer customer) async {
    await _db.collection('customers').doc(customer.id).set({
      'name': customer.name,
      'phone': customer.phone,
      'email': customer.email,
      'totalBookings': customer.totalBookings,
      'totalSpent': customer.totalSpent,
      'isBlocked': customer.isBlocked,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getCustomer(String id) {
    return _db.collection('customers').doc(id).get();
  }

  // ─── DRIVERS ───────────────────────────────────────────────────────────────

  Future<void> saveDriver(DriverModel driver) async {
    await _db.collection('drivers').doc(driver.id).set({
      'fullName': driver.fullName,
      'mobileNumber': driver.mobileNumber,
      'vehicleNumber': driver.vehicleNumber,
      'vehicleType': driver.vehicleType,
      'status': driver.status.name,
      'isOnline': driver.isOnline,
      'rating': driver.rating,
      'totalTrips': driver.totalTrips,
      'totalEarnings': driver.totalEarnings,
      'registeredAt': driver.registeredAt,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateDriverStatus(String driverId, AccountStatus status, {String? adminRemarks}) async {
    await _db.collection('drivers').doc(driverId).update({
      'status': status.name,
      if (adminRemarks != null) 'adminRemarks': adminRemarks,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAgencyStatus(String agencyId, AccountStatus status) async {
    await _db.collection('agencies').doc(agencyId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<DriverModel>> streamOnlineDrivers() {
    return _db.collection('drivers')
        .where('isOnline', isEqualTo: true)
        .where('status', isEqualTo: AccountStatus.approved.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          // You would typically have a fromFirestore factory method here
          // For now, this represents the stream logic
          return _mapDocToDriver(doc);
        }).toList());
  }

  Stream<List<DriverModel>> streamApprovedDrivers() {
    return _db.collection('drivers')
        .where('status', isEqualTo: AccountStatus.approved.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _mapDocToDriver(doc)).toList());
  }

  Stream<List<DriverModel>> streamAllDrivers() {
    return _db.collection('drivers')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _mapDocToDriver(doc)).toList());
  }

  // ─── AGENCIES ──────────────────────────────────────────────────────────────

  Future<void> saveAgency(AgencyModel agency) async {
    await _db.collection('agencies').doc(agency.id).set({
      'agencyName': agency.agencyName,
      'ownerName': agency.ownerName,
      'phoneNumber': agency.phoneNumber,
      'businessAddress': agency.businessAddress,
      'status': agency.status.name,
      'totalDrivers': agency.totalDrivers,
      'totalVehicles': agency.totalVehicles,
      'totalEarnings': agency.totalEarnings,
      'totalBookings': agency.totalBookings,
      'registeredAt': agency.registeredAt,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<AgencyModel>> streamAgencies() {
    return _db.collection('agencies')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _mapDocToAgency(doc)).toList());
  }

  // ─── QUERY HELPERS ─────────────────────────────────────────────────────────

  Future<Customer?> getCustomerByPhone(String phone) async {
    final snap = await _db.collection('customers').where('phone', isEqualTo: phone).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return _mapDocToCustomer(snap.docs.first);
  }

  Future<DriverModel?> getDriverByPhone(String phone) async {
    final snap = await _db.collection('drivers').where('mobileNumber', isEqualTo: phone).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return _mapDocToDriver(snap.docs.first);
  }

  Future<AgencyModel?> getAgencyByPhone(String phone) async {
    final snap = await _db.collection('agencies').where('phoneNumber', isEqualTo: phone).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return _mapDocToAgency(snap.docs.first);
  }

  // ─── BOOKINGS ─────────────────────────────────────────────────────────────

  Future<void> createBooking(TripRequest trip) async {
    await _db.collection('bookings').doc(trip.id).set({
      'bookingId': trip.bookingId,
      'customerId': trip.customerId,
      'customerName': trip.customerName,
      'pickupLocation': trip.pickupLocation,
      'dropLocation': trip.dropLocation,
      'estimatedFare': trip.estimatedFare,
      'status': trip.status.name,
      'createdAt': trip.createdAt,
    });
  }

  Future<void> updateTrip(TripRequest trip) async {
    await _db.collection('bookings').doc(trip.id).update({
      'status': trip.status.name,
      'actualDistance': trip.actualDistance,
      'finalFare': trip.finalFare,
      'paymentStatus': trip.paymentStatus.name,
    });
  }

  Future<void> completeTripFromDriver(String tripId, double actualDistance, double finalFare) async {
    await _db.collection('bookings').doc(tripId).update({
      'status': BookingStatus.tripCompleted.name,
      'actualDistance': actualDistance,
      'finalFare': finalFare,
    });
  }

  // Legacy/Mock Booking Model support
  Future<void> saveBooking(Booking booking) async {
    await _db.collection('legacy_bookings').doc(booking.id).set({
      'pickupLocation': booking.pickupLocation,
      'dropLocation': booking.dropLocation,
      'date': booking.date,
      'time': booking.time,
      'totalDistance': booking.totalDistance,
      'totalFare': booking.totalFare,
      'status': booking.status,
      'driverId': booking.driverId,
      'customerName': booking.customerName,
      'customerPhone': booking.customerPhone,
      'paymentMethod': booking.paymentMethod,
      'paymentStatus': booking.paymentStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ─── OFFERS ───────────────────────────────────────────────────────────────

  Future<void> saveOffer(Offer offer) async {
    await _db.collection('offers').doc(offer.id).set({
      'title': offer.title,
      'description': offer.description,
      'promoCode': offer.promoCode,
      'discountAmount': offer.discountAmount,
      'expiryDate': offer.expiryDate,
      'imageUrl': offer.imageUrl,
    });
  }

  Stream<List<Offer>> streamOffers() {
    return _db.collection('offers')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _mapDocToOffer(doc)).toList());
  }

  Future<void> updateBookingStatus(String id, String status) async {
    await _db.collection('legacy_bookings').doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<TripRequest>> streamCustomerBookings(String customerId) {
    return _db.collection('bookings')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _mapDocToTrip(doc)).toList());
  }

  Stream<List<TripRequest>> streamDriverTrips(String driverId) {
    return _db.collection('bookings')
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _mapDocToTrip(doc)).toList());
  }

  Stream<List<DriverModel>> streamAgencyDrivers(String agencyId) {
    return _db.collection('drivers')
        .where('agencyId', isEqualTo: agencyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _mapDocToDriver(doc)).toList());
  }

  Stream<List<TripRequest>> streamAllBookings() {
    return _db.collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _mapDocToTrip(doc)).toList());
  }

  // Helpers (Logic placeholders)
  DriverModel _mapDocToDriver(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DriverModel(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      aadhaarNumber: '',
      drivingLicense: '',
      vehicleNumber: data['vehicleNumber'] ?? '',
      vehicleRc: '',
      insuranceNumber: '',
      vehicleType: data['vehicleType'] ?? '4-Seater',
      driverType: DriverType.individual,
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
    );
  }

  TripRequest _mapDocToTrip(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TripRequest(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: '',
      pickupLocation: data['pickupLocation'] ?? '',
      dropLocation: data['dropLocation'] ?? '',
      estimatedDistance: 0,
      estimatedFare: (data['estimatedFare'] ?? 0).toDouble(),
      cabType: '',
      tripDate: DateTime.now(),
      tripTime: '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Customer _mapDocToCustomer(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Customer(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      totalBookings: data['totalBookings'] ?? 0,
      totalSpent: (data['totalSpent'] ?? 0).toDouble(),
      isBlocked: data['isBlocked'] ?? false,
    );
  }

  AgencyModel _mapDocToAgency(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AgencyModel(
      id: doc.id,
      agencyName: data['agencyName'] ?? '',
      ownerName: data['ownerName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      businessAddress: data['businessAddress'] ?? '',
      status: AccountStatus.values.firstWhere((e) => e.name == data['status'], orElse: () => AccountStatus.pendingVerification),
      totalDrivers: data['totalDrivers'] ?? 0,
      totalVehicles: data['totalVehicles'] ?? 0,
      totalEarnings: (data['totalEarnings'] ?? 0).toDouble(),
      totalBookings: data['totalBookings'] ?? 0,
    );
  }

  Offer _mapDocToOffer(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Offer(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      promoCode: data['promoCode'] ?? '',
      discountAmount: (data['discountAmount'] ?? 0).toDouble(),
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 30)),
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
