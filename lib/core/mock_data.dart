import 'models.dart';

class MockData {
  static List<Cab> cabs = [
    Cab(
      id: '1',
      model: 'Toyota Camry',
      type: '4-Seater',
      agencyName: 'Quick Travels',
      imageUrl: 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?auto=format&fit=crop&q=80&w=400',
      rating: 4.8,
      pricePerKm: 12.0,
      estimatedArrival: '10 mins',
      vehicleNumber: 'KA-01-MJ-1234',
      fuelType: 'Petrol',
    ),
    Cab(
      id: '2',
      model: 'Toyota Innova',
      type: '7-Seater',
      agencyName: 'Elite Cabs',
      imageUrl: 'https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&q=80&w=400',
      rating: 4.5,
      pricePerKm: 18.0,
      estimatedArrival: '15 mins',
      vehicleNumber: 'KA-02-AB-5678',
      fuelType: 'Diesel',
    ),
    Cab(
      id: '3',
      model: 'Force Traveller',
      type: '13-Seater',
      agencyName: 'Global Travels',
      imageUrl: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&q=80&w=400',
      rating: 4.2,
      pricePerKm: 25.0,
      estimatedArrival: '25 mins',
      vehicleNumber: 'KA-03-CD-9012',
      fuelType: 'Diesel',
    ),
    Cab(
      id: '4',
      model: 'Honda City',
      type: '4-Seater',
      agencyName: 'City Riders',
      imageUrl: 'https://images.unsplash.com/photo-1590362891991-f776e747a588?auto=format&fit=crop&q=80&w=400',
      rating: 4.7,
      pricePerKm: 13.0,
      estimatedArrival: '8 mins',
      vehicleNumber: 'KA-04-EF-3456',
      fuelType: 'Petrol',
    ),
    Cab(
      id: '5',
      model: 'Maruti Ertiga',
      type: '7-Seater',
      agencyName: 'Quick Travels',
      imageUrl: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&q=80&w=400',
      rating: 4.3,
      pricePerKm: 16.0,
      estimatedArrival: '12 mins',
      vehicleNumber: 'KA-05-GH-7890',
      fuelType: 'CNG',
    ),
  ];

  static List<BookingOffer> offers = [
    BookingOffer(
      id: '1',
      title: 'First Trip Discount',
      discount: '20% OFF',
      validity: 'Valid till 31st Mar 2025',
      imageUrl: 'https://images.unsplash.com/photo-1621944190310-e3cca1564bd7?auto=format&fit=crop&q=80&w=400',
      discountType: 'Percentage',
      discountValue: 20,
      applicableCabTypes: ['4-Seater', '7-Seater', '13-Seater'],
    ),
    BookingOffer(
      id: '2',
      title: 'Weekend Gateway',
      discount: '₹500 Cashback',
      validity: 'Fri-Sun only',
      imageUrl: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&q=80&w=400',
      discountType: 'Flat',
      discountValue: 500,
      applicableCabTypes: ['7-Seater', '13-Seater'],
    ),
    BookingOffer(
      id: '3',
      title: 'Airport Special',
      discount: 'Flat ₹200 OFF',
      validity: 'Airport rides only',
      imageUrl: 'https://images.unsplash.com/photo-1436491865332-7a61a109c0f?auto=format&fit=crop&q=80&w=400',
      discountType: 'Flat',
      discountValue: 200,
      applicableCabTypes: ['4-Seater'],
    ),
    BookingOffer(
      id: '4',
      title: 'Family Trip Offer',
      discount: '15% OFF',
      validity: 'Valid till 15th Apr 2025',
      imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&q=80&w=400',
      discountType: 'Percentage',
      discountValue: 15,
      applicableCabTypes: ['7-Seater', '13-Seater'],
    ),
    BookingOffer(
      id: '5',
      title: 'Monsoon Special',
      discount: '₹300 Cashback',
      validity: 'June-August only',
      imageUrl: 'https://images.unsplash.com/photo-1504701954957-2010ec3bcec1?auto=format&fit=crop&q=80&w=400',
      discountType: 'Flat',
      discountValue: 300,
      applicableCabTypes: ['4-Seater', '7-Seater'],
    ),
  ];

  static List<String> recentSearches = [
    'Bangalore to Mysore',
    'Indiranagar to Airport',
    'MG Road to Whitefield',
    'Pune to Mumbai',
    'Delhi to Agra',
  ];

  static List<TravelAgency> agencies = [
    TravelAgency(
      id: '1',
      name: 'Quick Travels',
      contactPerson: 'Rajesh Kumar',
      mobileNumber: '+91 98765 43210',
      whatsappNumber: '+91 98765 43210',
      email: 'rajesh@quicktravels.com',
      address: '123, MG Road, Bangalore - 560001',
      gstNumber: 'GST29ABCDE1234F1Z5',
      bankDetails: 'SBI - 1234567890',
      isActive: true,
    ),
    TravelAgency(
      id: '2',
      name: 'Elite Cabs',
      contactPerson: 'Suresh Patel',
      mobileNumber: '+91 87654 32109',
      whatsappNumber: '+91 87654 32109',
      email: 'suresh@elitecabs.com',
      address: '456, Brigade Road, Bangalore - 560025',
      gstNumber: 'GST29FGHIJ5678K2L6',
      bankDetails: 'HDFC - 9876543210',
      isActive: true,
    ),
    TravelAgency(
      id: '3',
      name: 'Global Travels',
      contactPerson: 'Amit Singh',
      mobileNumber: '+91 76543 21098',
      whatsappNumber: '+91 76543 21098',
      email: 'amit@globaltravels.com',
      address: '789, Koramangala, Bangalore - 560034',
      gstNumber: '',
      bankDetails: 'ICICI - 5678901234',
      isActive: false,
    ),
    TravelAgency(
      id: '4',
      name: 'City Riders',
      contactPerson: 'Priya Sharma',
      mobileNumber: '+91 65432 10987',
      whatsappNumber: '+91 65432 10987',
      email: 'priya@cityriders.com',
      address: '321, Indiranagar, Bangalore - 560038',
      gstNumber: 'GST29MNOPQ9012R3S7',
      bankDetails: 'Axis - 2345678901',
      isActive: true,
    ),
    TravelAgency(
      id: '5',
      name: 'Royal Travels',
      contactPerson: 'Vikram Singh',
      mobileNumber: '+91 99001 12233',
      whatsappNumber: '+91 99001 12233',
      email: 'contact@royaltravels.in',
      address: 'Near Airport Road, Devanahalli, Bangalore',
      gstNumber: 'GST29KSRTC1234F1Z1',
      bankDetails: 'SBI - 5566778899',
      isActive: true,
    ),
    TravelAgency(
      id: '6',
      name: 'Sunshine Cabs',
      contactPerson: 'Meera Nair',
      mobileNumber: '+91 88001 22334',
      whatsappNumber: '+91 88001 22334',
      email: 'info@sunshinecabs.com',
      address: 'Sector 4, HSR Layout, Bangalore',
      gstNumber: '',
      bankDetails: 'HDFC - 1122334455',
      isActive: true,
    ),
  ];

  static List<Booking> bookings = [
    Booking(
      id: 'NC827391',
      pickupLocation: 'Marathahalli, Bangalore',
      dropLocation: 'Kempegowda International Airport',
      date: '18 Feb 2025',
      time: '06:00 AM',
      cab: cabs[0],
      totalDistance: 42.0,
      totalFare: 504.0,
      status: 'Completed',
      customerName: 'Arjun Mehta',
      customerPhone: '+91 99887 76655',
      paymentMethod: 'UPI',
      paymentStatus: 'Success',
      driverId: 'D006',
    ),
    Booking(
      id: 'NC827392',
      pickupLocation: 'Koramangala, Bangalore',
      dropLocation: 'Mysore Palace',
      date: '18 Feb 2025',
      time: '08:30 AM',
      cab: cabs[1],
      driverId: 'D007', // Karan Singh
      totalDistance: 148.0,
      totalFare: 2664.0,
      status: 'Ongoing',
      customerName: 'Sneha Reddy',
      customerPhone: '+91 88776 65544',
      paymentMethod: 'Nova Gateway',
      paymentStatus: 'Success',
    ),
    Booking(
      id: 'NC827393',
      pickupLocation: 'MG Road, Bangalore',
      dropLocation: 'Whitefield, Bangalore',
      date: '17 Feb 2025',
      time: '02:00 PM',
      cab: cabs[3],
      driverId: 'D001', // Ramesh Kumar
      totalDistance: 18.0,
      totalFare: 234.0,
      status: 'Confirmed',
      customerName: 'Vikram Nair',
      customerPhone: '+91 77665 54433',
      paymentMethod: 'UPI',
      paymentStatus: 'Success',
    ),
    Booking(
      id: 'NC827394',
      pickupLocation: 'Jayanagar, Bangalore',
      dropLocation: 'HSR Layout, Bangalore',
      date: '17 Feb 2025',
      time: '10:30 AM',
      cab: cabs[0],
      driverId: 'D006', // Manish Pandey
      totalDistance: 12.0,
      totalFare: 156.0,
      status: 'Completed',
      customerName: 'Anjali Sharma',
      customerPhone: '+91 99000 11122',
      paymentMethod: 'UPI',
      paymentStatus: 'Success',
    ),
    Booking(
      id: 'NC827395',
      pickupLocation: 'Electronic City, Bangalore',
      dropLocation: 'Indiranagar, Bangalore',
      date: '16 Feb 2025',
      time: '04:00 PM',
      cab: cabs[1],
      driverId: 'D006', // Manish Pandey
      totalDistance: 25.0,
      totalFare: 480.0,
      status: 'Completed',
      customerName: 'Karan Mehra',
      customerPhone: '+91 98989 89898',
      paymentMethod: 'Nova Wallet',
      paymentStatus: 'Success',
    ),
    Booking(
      id: 'NC827394',
      pickupLocation: 'Electronic City, Bangalore',
      dropLocation: 'Pune',
      date: '16 Feb 2025',
      time: '05:00 AM',
      cab: cabs[2],
      totalDistance: 840.0,
      totalFare: 21000.0,
      status: 'Cancelled',
      customerName: 'Deepa Krishnan',
      customerPhone: '+91 66554 43322',
      paymentMethod: 'UPI',
      paymentStatus: 'Refunded',
    ),
    Booking(
      id: 'NC827395',
      pickupLocation: 'Hebbal, Bangalore',
      dropLocation: 'Mysore',
      date: '19 Feb 2025',
      time: '09:00 AM',
      cab: cabs[4],
      totalDistance: 148.0,
      totalFare: 2368.0,
      status: 'New',
      customerName: 'Ravi Shankar',
      customerPhone: '+91 55443 32211',
      paymentMethod: 'Nova Gateway',
      paymentStatus: 'Pending',
    ),
  ];

  static List<Customer> customers = [
    Customer(
      id: 'C001',
      name: 'Arjun Mehta',
      phone: '+91 99887 76655',
      email: 'arjun.mehta@email.com',
      totalBookings: 12,
      totalSpent: 15420.0,
    ),
    Customer(
      id: 'C002',
      name: 'Sneha Reddy',
      phone: '+91 88776 65544',
      email: 'sneha.reddy@email.com',
      totalBookings: 8,
      totalSpent: 9870.0,
    ),
    Customer(
      id: 'C003',
      name: 'Vikram Nair',
      phone: '+91 77665 54433',
      email: 'vikram.nair@email.com',
      totalBookings: 5,
      totalSpent: 4560.0,
    ),
    Customer(
      id: 'C004',
      name: 'Deepa Krishnan',
      phone: '+91 66554 43322',
      email: 'deepa.k@email.com',
      totalBookings: 3,
      totalSpent: 2100.0,
      isBlocked: true,
    ),
    Customer(
      id: 'C005',
      name: 'Ravi Shankar',
      phone: '+91 55443 32211',
      email: 'ravi.shankar@email.com',
      totalBookings: 20,
      totalSpent: 28900.0,
    ),
    Customer(
      id: 'C006',
      name: 'Anjali Sharma',
      phone: '+91 99000 11122',
      email: 'anjali@demo.com',
      totalBookings: 2,
      totalSpent: 1200.0,
    ),
    Customer(
      id: 'C007',
      name: 'Rahul Verma',
      phone: '+91 88777 66555',
      email: 'rahul.v@test.com',
      totalBookings: 0,
      totalSpent: 0.0,
    ),
  ];

  static List<CustomerFeedback> feedbacks = [
    CustomerFeedback(
      id: 'F001',
      customerName: 'Arjun Mehta',
      agencyName: 'Quick Travels',
      cabModel: 'Toyota Camry',
      rating: 5.0,
      comment: 'Excellent service! Driver was very professional and the cab was clean.',
      date: '18 Feb 2025',
    ),
    CustomerFeedback(
      id: 'F002',
      customerName: 'Sneha Reddy',
      agencyName: 'Elite Cabs',
      cabModel: 'Toyota Innova',
      rating: 4.0,
      comment: 'Good ride, comfortable journey. Reached on time.',
      date: '17 Feb 2025',
    ),
    CustomerFeedback(
      id: 'F003',
      customerName: 'Vikram Nair',
      agencyName: 'City Riders',
      cabModel: 'Honda City',
      rating: 3.5,
      comment: 'Average experience. Driver took a longer route.',
      date: '16 Feb 2025',
    ),
    CustomerFeedback(
      id: 'F004',
      customerName: 'Ravi Shankar',
      agencyName: 'Quick Travels',
      cabModel: 'Maruti Ertiga',
      rating: 4.5,
      comment: 'Very comfortable ride. Will book again!',
      date: '15 Feb 2025',
    ),
    CustomerFeedback(
      id: 'F005',
      customerName: 'Anonymous',
      agencyName: 'Global Travels',
      cabModel: 'Force Traveller',
      rating: 1.0,
      comment: 'Terrible experience! Spam review.',
      date: '14 Feb 2025',
      isFlagged: true,
    ),
  ];

  static List<NotificationTemplate> notificationTemplates = [
    NotificationTemplate(
      id: 'N001',
      name: 'Booking Confirmation - Customer',
      type: 'Customer',
      template: '''✅ *Booking Confirmed - Nova Cabs*

🚖 *Travel Agency:* {agencyName}
📞 *Agency Contact:* {agencyPhone}

🚗 *Car Details:*
• Model: {carModel}
• Number: {carNumber}

📍 *Pickup:* {pickupLocation}
⏰ *Pickup Time:* {pickupTime}
🎫 *Booking ID:* #{bookingId}

📞 *Customer Support:* +91 80000 00000

Thank you for choosing Nova Cabs! 🙏''',
    ),
    NotificationTemplate(
      id: 'N002',
      name: 'Booking Confirmation - Agency',
      type: 'Agency',
      template: '''🔔 *New Booking - Nova Cabs*

👤 *Customer:* {customerName}
📞 *Contact:* {customerPhone}

📍 *Pickup:* {pickupLocation}
🗺️ *Map:* {mapLink}
⏰ *Pickup Time:* {pickupTime}
🎫 *Booking ID:* #{bookingId}

Please confirm the booking. Thank you!''',
    ),
    NotificationTemplate(
      id: 'N003',
      name: 'Trip Update',
      type: 'Customer',
      template: '''🚗 *Trip Update - Nova Cabs*

Your driver is on the way!
📍 *Pickup:* {pickupLocation}
🎫 *Booking ID:* #{bookingId}

Track your driver in real-time.''',
    ),
    NotificationTemplate(
      id: 'N004',
      name: 'Cancellation Alert',
      type: 'Customer',
      template: '''❌ *Booking Cancelled - Nova Cabs*

Your booking #{bookingId} has been cancelled.
💰 Refund will be processed in 3-5 business days.

For support: +91 80000 00000''',
    ),
  ];
}
