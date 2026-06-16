import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'extended_models.dart';
import 'models.dart';
import 'app_logger.dart';
import 'firestore_error_handler.dart';

/// Normalises any phone input to E.164 format (+91XXXXXXXXXX).
/// Strips spaces, dashes, parentheses, then prepends +91 for 10-digit numbers.
String normalizePhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.length == 10) return '+91$digits';
  if (digits.length == 12 && digits.startsWith('91')) return '+$digits';
  if (digits.length == 13 && digits.startsWith('091'))
    return '+${digits.substring(1)}';
  return '+$digits'; // best-effort
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── CUSTOMERS ─────────────────────────────────────────────────────────────

  Future<void> saveCustomer(Customer customer) async {
    try {
      await _db.collection('customers').doc(customer.id).set({
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'totalBookings': customer.totalBookings,
        'totalSpent': customer.totalSpent,
        'isBlocked': customer.isBlocked,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      AppLogger.i('Customer profile saved: ${customer.id}');
    } on FirebaseException catch (e) {
      if (e.code == 'not-found' || e.message?.contains('database') == true) {
        AppLogger.e(
          'saveCustomer failed: Firestore database not initialized',
          error:
              'Database (default) does not exist.\n'
              'Fix: Visit Firebase Console > Firestore Database > Create Database',
          stackTrace: StackTrace.current,
        );
      } else {
        AppLogger.e(
          'saveCustomer failed',
          error: e,
          stackTrace: StackTrace.current,
        );
      }
      rethrow;
    } catch (e, st) {
      AppLogger.e(
        'saveCustomer failed with exception',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<DocumentSnapshot> getCustomer(String id) {
    return _db.collection('customers').doc(id).get();
  }

  Future<Customer?> getCustomerById(String uid) async {
    try {
      final doc = await _db.collection('customers').doc(uid).get();
      if (!doc.exists) return null;
      return _mapDocToCustomer(doc);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found' || e.message?.contains('database') == true) {
        AppLogger.w(
          'Firestore database not initialized',
          error:
              'Database (default) does not exist.\n'
              'Fix: Visit Firebase Console > Firestore Database > Create Database',
        );
      } else {
        AppLogger.e(
          'getCustomerById failed',
          error: e,
          stackTrace: StackTrace.current,
        );
      }
      return null;
    } catch (e, st) {
      AppLogger.e('getCustomerById failed', error: e, stackTrace: st);
      return null;
    }
  }

  Stream<List<Customer>> streamAllCustomers() {
    return _db
        .collection('customers')
        .snapshots()
        .map((s) => s.docs.map(_mapDocToCustomer).toList());
  }

  Future<void> updateCustomerBlockStatus(
    String customerId,
    bool isBlocked,
  ) async {
    try {
      await _db.collection('customers').doc(customerId).update({
        'isBlocked': isBlocked,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      AppLogger.e('updateCustomerBlockStatus failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ─── DRIVERS ───────────────────────────────────────────────────────────────

  Future<void> saveDriver(DriverModel driver) async {
    try {
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
      AppLogger.i('Driver profile saved: ${driver.id}');
    } on FirebaseException catch (e) {
      if (e.code == 'not-found' || e.message?.contains('database') == true) {
        AppLogger.e(
          'saveDriver failed: Firestore database not initialized',
          error:
              'Database (default) does not exist.\n'
              'Fix: Visit Firebase Console > Firestore Database > Create Database',
          stackTrace: StackTrace.current,
        );
      } else {
        AppLogger.e(
          'saveDriver failed',
          error: e,
          stackTrace: StackTrace.current,
        );
      }
      rethrow;
    } catch (e, st) {
      AppLogger.e('saveDriver failed with exception', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> updateDriverStatus(
    String driverId,
    AccountStatus status, {
    String? adminRemarks,
  }) async {
    try {
      await _db.collection('drivers').doc(driverId).update({
        'status': status.name,
        if (adminRemarks != null) 'adminRemarks': adminRemarks,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      AppLogger.e('updateDriverStatus failed', error: e, stackTrace: st);
    }
  }

  Future<DriverModel?> getDriverById(String uid) async {
    try {
      final doc = await _db.collection('drivers').doc(uid).get();
      if (!doc.exists) return null;
      return _mapDocToDriver(doc);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found' || e.message?.contains('database') == true) {
        AppLogger.w(
          'Firestore database not initialized',
          error:
              'Database (default) does not exist.\n'
              'Fix: Visit Firebase Console > Firestore Database > Create Database',
        );
      } else {
        AppLogger.e(
          'getDriverById failed',
          error: e,
          stackTrace: StackTrace.current,
        );
      }
      return null;
    } catch (e, st) {
      AppLogger.e('getDriverById failed', error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> updateAgencyStatus(String agencyId, AccountStatus status) async {
    try {
      await _db.collection('agencies').doc(agencyId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      AppLogger.e('updateAgencyStatus failed', error: e, stackTrace: st);
    }
  }

  Stream<List<DriverModel>> streamOnlineDrivers() {
    return _db
        .collection('drivers')
        .where('isOnline', isEqualTo: true)
        .where('status', isEqualTo: AccountStatus.approved.name)
        .snapshots()
        .map((s) => s.docs.map(_mapDocToDriver).toList());
  }

  Stream<List<DriverModel>> streamApprovedDrivers() {
    return _db
        .collection('drivers')
        .where('status', isEqualTo: AccountStatus.approved.name)
        .snapshots()
        .map((s) => s.docs.map(_mapDocToDriver).toList());
  }

  Stream<List<DriverModel>> streamAllDrivers() {
    return _db
        .collection('drivers')
        .snapshots()
        .map((s) => s.docs.map(_mapDocToDriver).toList());
  }

  // ─── AGENCIES ──────────────────────────────────────────────────────────────

  Future<void> saveAgency(AgencyModel agency) async {
    try {
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
    } catch (e, st) {
      AppLogger.e('saveAgency failed', error: e, stackTrace: st);
    }
  }

  Stream<List<AgencyModel>> streamAgencies() {
    return _db
        .collection('agencies')
        .snapshots()
        .map((s) => s.docs.map(_mapDocToAgency).toList());
  }

  Future<AgencyModel?> getAgencyById(String uid) async {
    try {
      final doc = await _db.collection('agencies').doc(uid).get();
      if (!doc.exists) return null;
      return _mapDocToAgency(doc);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found' || e.message?.contains('database') == true) {
        AppLogger.w(
          'Firestore database not initialized',
          error:
              'Database (default) does not exist.\n'
              'Fix: Visit Firebase Console > Firestore Database > Create Database',
        );
      } else {
        AppLogger.e(
          'getAgencyById failed',
          error: e,
          stackTrace: StackTrace.current,
        );
      }
      return null;
    } catch (e, st) {
      AppLogger.e('getAgencyById failed', error: e, stackTrace: st);
      return null;
    }
  }

  // ─── QUERY HELPERS ─────────────────────────────────────────────────────────

  Future<Customer?> getCustomerByPhone(String phone) async {
    final normalized = normalizePhone(phone);
    try {
      final snap = await _db
          .collection('customers')
          .where('phone', isEqualTo: normalized)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return _mapDocToCustomer(snap.docs.first);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found' || e.message?.contains('database') == true) {
        AppLogger.w(
          'Firestore database not initialized',
          error:
              'Database (default) does not exist.\n'
              'Fix: Visit Firebase Console > Firestore Database > Create Database',
        );
      } else {
        AppLogger.e(
          'getCustomerByPhone failed',
          error: e,
          stackTrace: StackTrace.current,
        );
      }
      return null;
    } catch (e, st) {
      AppLogger.e('getCustomerByPhone failed', error: e, stackTrace: st);
      return null;
    }
  }

  Future<DriverModel?> getDriverByPhone(String phone) async {
    final normalized = normalizePhone(phone);
    try {
      final snap = await _db
          .collection('drivers')
          .where('mobileNumber', isEqualTo: normalized)
          .where('status', whereIn: ['approved', 'active'])
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return _mapDocToDriver(snap.docs.first);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found' || e.message?.contains('database') == true) {
        AppLogger.w(
          'Firestore database not initialized',
          error:
              'Database (default) does not exist.\n'
              'Fix: Visit Firebase Console > Firestore Database > Create Database',
        );
      } else {
        AppLogger.e(
          'getDriverByPhone failed',
          error: e,
          stackTrace: StackTrace.current,
        );
      }
      return null;
    } catch (e, st) {
      AppLogger.e('getDriverByPhone failed', error: e, stackTrace: st);
      return null;
    }
  }

  Future<AgencyModel?> getAgencyByPhone(String phone) async {
    final normalized = normalizePhone(phone);
    try {
      final snap = await _db
          .collection('agencies')
          .where('phoneNumber', isEqualTo: normalized)
          .where('status', whereIn: ['approved', 'active'])
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return _mapDocToAgency(snap.docs.first);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found' || e.message?.contains('database') == true) {
        AppLogger.w(
          'Firestore database not initialized',
          error:
              'Database (default) does not exist.\n'
              'Fix: Visit Firebase Console > Firestore Database > Create Database',
        );
      } else {
        AppLogger.e(
          'getAgencyByPhone failed',
          error: e,
          stackTrace: StackTrace.current,
        );
      }
      return null;
    } catch (e, st) {
      AppLogger.e('getAgencyByPhone failed', error: e, stackTrace: st);
      return null;
    }
  }

  // ─── BOOKINGS ─────────────────────────────────────────────────────────────
  // Single canonical method — createBooking and saveBooking removed (Issue #11)

  Future<void> saveTripRequest(TripRequest trip) async {
    await _db.collection('bookings').doc(trip.id).set({
      'bookingId': trip.bookingId,
      'customerId': trip.customerId,
      'customerName': trip.customerName,
      'customerPhone': trip.customerPhone,
      'pickupLocation': trip.pickupLocation,
      'dropLocation': trip.dropLocation,
      'estimatedDistance': trip.estimatedDistance,
      'estimatedFare': trip.estimatedFare,
      'cabType': trip.cabType,
      'tripDate': trip.tripDate.toIso8601String(),
      'tripTime': trip.tripTime,
      'status': trip.status.name,
      'driverId': trip.driverId,
      'advancePaid': trip.advancePaid,
      'paymentMethod': trip.paymentMethod.name,
      'paymentStatus': trip.paymentStatus.name,
      'rentalPackage': trip.rentalPackage,
      'createdAt': FieldValue.serverTimestamp(),
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

  Future<void> completeTripFromDriver(
    String tripId,
    double actualDistance,
    double finalFare,
  ) async {
    await _db.collection('bookings').doc(tripId).update({
      'status': BookingStatus.tripCompleted.name,
      'actualDistance': actualDistance,
      'finalFare': finalFare,
    });
  }

  Future<void> updateTripStatus(String tripId, BookingStatus status) async {
    await _db.collection('bookings').doc(tripId).update({
      'status': status.name,
    });
  }

  /// Creates a withdrawal request for a driver.
  Future<void> requestWithdrawal({
    required String driverId,
    required double amount,
  }) async {
    try {
      final docRef = _db.collection('withdrawal_requests').doc();
      await docRef.set({
        'driverId': driverId,
        'amount': amount,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.i('Withdrawal request created for driver $driverId: ₹${amount.toStringAsFixed(0)}');
    } catch (e, st) {
      AppLogger.e('requestWithdrawal failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Saves the customer's star rating and comment against a trip.
  Future<void> saveCustomerRating(
    String tripId,
    double rating,
    String comment,
  ) async {
    try {
      await _db.collection('bookings').doc(tripId).update({
        'customerRating': rating,
        'customerFeedback': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.i('Customer rating saved for trip $tripId: $rating ⭐');
    } catch (e, st) {
      AppLogger.e('saveCustomerRating failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ─── OFFERS ───────────────────────────────────────────────────────────────

  Future<void> saveOffer(BookingOffer offer) async {
    await _db.collection('offers').doc(offer.id).set({
      'title': offer.title,
      'discount': offer.discount,
      'validity': offer.validity,
      'imageUrl': offer.imageUrl,
      'discountType': offer.discountType,
      'discountValue': offer.discountValue,
      'applicableCabTypes': offer.applicableCabTypes,
      'isActive': offer.isActive,
    });
  }

  Stream<List<BookingOffer>> streamOffers() {
    return _db
        .collection('offers')
        .snapshots()
        .map((s) => s.docs.map(_mapDocToOffer).toList());
  }

  Stream<List<TripRequest>> streamCustomerBookings(String customerId) {
    // NOTE: Combining .where() on one field with .orderBy() on a different field
    // requires a Firestore composite index. To avoid that hard requirement we
    // filter by customerId only and sort client-side.
    return _db
        .collection('bookings')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((s) {
          final trips = s.docs.map(_mapDocToTrip).toList();
          trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return trips;
        });
  }

  Stream<List<TripRequest>> streamDriverTrips(String driverId) {
    // Same fix — avoid composite index requirement, sort client-side.
    return _db
        .collection('bookings')
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((s) {
          final trips = s.docs.map(_mapDocToTrip).toList();
          trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return trips;
        });
  }

  Stream<List<DriverModel>> streamAgencyDrivers(String agencyId) {
    return _db
        .collection('drivers')
        .where('agencyId', isEqualTo: agencyId)
        .snapshots()
        .map((s) => s.docs.map(_mapDocToDriver).toList());
  }

  Stream<List<TripRequest>> streamAllBookings() {
    return _db
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_mapDocToTrip).toList());
  }

  // ─── FEEDBACKS ────────────────────────────────────────────────────────────

  Stream<List<CustomerFeedback>> streamFeedbacks() {
    return _db
        .collection('feedbacks')
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_mapDocToFeedback).toList());
  }

  Future<void> saveFeedback(CustomerFeedback feedback) async {
    await _db.collection('feedbacks').doc(feedback.id).set({
      'customerName': feedback.customerName,
      'date': feedback.date,
      'rating': feedback.rating,
      'comment': feedback.comment,
      'cabModel': feedback.cabModel,
      'agencyName': feedback.agencyName,
      'isFlagged': feedback.isFlagged,
    });
  }

  Future<void> updateFeedbackFlag(String feedbackId, bool isFlagged) async {
    await _db.collection('feedbacks').doc(feedbackId).update({'isFlagged': isFlagged});
  }

  Future<void> deleteFeedback(String feedbackId) async {
    await _db.collection('feedbacks').doc(feedbackId).delete();
  }

  // ─── NOTIFICATION TEMPLATES ───────────────────────────────────────────────

  Stream<List<NotificationTemplate>> streamNotificationTemplates() {
    return _db
        .collection('notification_templates')
        .snapshots()
        .map((s) => s.docs.map(_mapDocToNotificationTemplate).toList());
  }

  Future<void> saveNotificationTemplate(NotificationTemplate t) async {
    await _db.collection('notification_templates').doc(t.id).set({
      'name': t.name,
      'template': t.template,
      'type': t.type,
      'isEnabled': t.isEnabled,
    });
  }

  Future<void> deleteOffer(String offerId) async {
    await _db.collection('offers').doc(offerId).delete();
  }

  // ─── MAPPERS ─────────────────────────────────────────────────────────────
  // All Timestamp casts are nullable (Issue #3 fix)

  DriverModel _mapDocToDriver(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DriverModel(
      id: doc.id,
      fullName: data['fullName'] as String? ?? '',
      mobileNumber: data['mobileNumber'] as String? ?? '',
      aadhaarNumber: data['aadhaarNumber'] as String? ?? '',
      drivingLicense: data['drivingLicense'] as String? ?? '',
      vehicleNumber: data['vehicleNumber'] as String? ?? '',
      vehicleRc: data['vehicleRc'] as String? ?? '',
      insuranceNumber: data['insuranceNumber'] as String? ?? '',
      vehicleType: data['vehicleType'] as String? ?? '4-Seater',
      vehicleModel: data['vehicleModel'] as String? ?? '',
      driverType: DriverType.individual,
      agencyId: data['agencyId'] as String?,
      agencyName: data['agencyName'] as String?,
      status: AccountStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? ''),
        orElse: () => AccountStatus.pendingVerification,
      ),
      isOnline: data['isOnline'] as bool? ?? false,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: data['totalTrips'] as int? ?? 0,
      totalEarnings: (data['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      adminRemarks: data['adminRemarks'] as String?,
      // Issue #3: nullable Timestamp cast with fallback
      registeredAt:
          (data['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  TripRequest _mapDocToTrip(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TripRequest(
      id: doc.id,
      bookingId: data['bookingId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      pickupLocation: data['pickupLocation'] as String? ?? '',
      dropLocation: data['dropLocation'] as String? ?? '',
      estimatedDistance: (data['estimatedDistance'] as num?)?.toDouble() ?? 0.0,
      estimatedFare: (data['estimatedFare'] as num?)?.toDouble() ?? 0.0,
      cabType: data['cabType'] as String? ?? '',
      tripDate: data['tripDate'] != null
          ? DateTime.tryParse(data['tripDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      tripTime: data['tripTime'] as String? ?? '',
      status: BookingStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? ''),
        orElse: () => BookingStatus.booked,
      ),
      driverId: data['driverId'] as String?,
      advancePaid: (data['advancePaid'] as num?)?.toDouble() ?? 0.0,
      finalFare: (data['finalFare'] as num?)?.toDouble(),
      actualDistance: (data['actualDistance'] as num?)?.toDouble(),
      rentalPackage: data['rentalPackage'] as String?,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == (data['paymentMethod'] as String? ?? ''),
        orElse: () => PaymentMethod.upi,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == (data['paymentStatus'] as String? ?? ''),
        orElse: () => PaymentStatus.pending,
      ),
      customerRating: (data['customerRating'] as num?)?.toDouble(),
      customerFeedback: data['customerFeedback'] as String?,
      // Issue #3: nullable Timestamp cast with fallback
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Customer _mapDocToCustomer(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Customer(
      id: doc.id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      totalBookings: data['totalBookings'] as int? ?? 0,
      totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0.0,
      isBlocked: data['isBlocked'] as bool? ?? false,
    );
  }

  AgencyModel _mapDocToAgency(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AgencyModel(
      id: doc.id,
      agencyName: data['agencyName'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      businessAddress: data['businessAddress'] as String? ?? '',
      status: AccountStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? ''),
        orElse: () => AccountStatus.pendingVerification,
      ),
      totalDrivers: data['totalDrivers'] as int? ?? 0,
      totalVehicles: data['totalVehicles'] as int? ?? 0,
      totalEarnings: (data['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalBookings: data['totalBookings'] as int? ?? 0,
      registeredAt:
          (data['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  BookingOffer _mapDocToOffer(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingOffer(
      id: doc.id,
      title: data['title'] as String? ?? '',
      discount: data['discount'] as String? ?? '',
      validity: data['validity'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      discountType: data['discountType'] as String? ?? 'Percentage',
      discountValue: (data['discountValue'] as num?)?.toDouble() ?? 0.0,
      applicableCabTypes: List<String>.from(
        data['applicableCabTypes'] as List? ?? [],
      ),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  CustomerFeedback _mapDocToFeedback(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerFeedback(
      id: doc.id,
      customerName: data['customerName'] as String? ?? '',
      date: data['date'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] as String? ?? '',
      cabModel: data['cabModel'] as String? ?? '',
      agencyName: data['agencyName'] as String? ?? '',
      isFlagged: data['isFlagged'] as bool? ?? false,
    );
  }

  NotificationTemplate _mapDocToNotificationTemplate(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationTemplate(
      id: doc.id,
      name: data['name'] as String? ?? '',
      template: data['template'] as String? ?? '',
      type: data['type'] as String? ?? 'Customer',
      isEnabled: data['isEnabled'] as bool? ?? true,
    );
  }

  // ─── SUPER ADMIN CREDENTIALS ───────────────────────────────────────────────

  Future<bool> checkSuperAdminExists() async {
    final doc = await _db.collection('super_admins').doc('config').get();
    return doc.exists;
  }

  Future<void> createSuperAdmin(String email, String password) async {
    await _db.collection('super_admins').doc('config').set({
      'email': email,
      'password': password,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> verifySuperAdmin(String email, String password) async {
    final doc = await _db.collection('super_admins').doc('config').get();
    if (!doc.exists) return false;
    final data = doc.data()!;
    return data['email'] == email && data['password'] == password;
  }

  Future<Map<String, String?>> getSuperAdminCredentials() async {
    final doc = await _db.collection('super_admins').doc('config').get();
    if (!doc.exists) return {'email': null, 'password': null};
    final data = doc.data()!;
    return {
      'email': data['email'] as String?,
      'password': data['password'] as String?,
    };
  }

  Future<bool> updateSuperAdminEmail(String currentPassword, String newEmail) async {
    final doc = await _db.collection('super_admins').doc('config').get();
    if (!doc.exists) return false;
    if (doc.data()?['password'] != currentPassword) return false;
    await _db.collection('super_admins').doc('config').update({'email': newEmail});
    return true;
  }

  Future<bool> updateSuperAdminPassword(String currentPassword, String newPassword) async {
    final doc = await _db.collection('super_admins').doc('config').get();
    if (!doc.exists) return false;
    if (doc.data()?['password'] != currentPassword) return false;
    await _db.collection('super_admins').doc('config').update({'password': newPassword});
    return true;
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
