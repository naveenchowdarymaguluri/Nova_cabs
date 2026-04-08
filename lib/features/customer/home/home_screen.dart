import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/mock_data.dart';
import '../../../core/models.dart';
import '../../../core/app_providers.dart';
import '../../../core/extended_models.dart';
import '../search/cab_listing_screen.dart';
import '../../admin/dashboard/admin_dashboard.dart';
import '../auth/login_screen.dart';
import '../offers/all_offers_screen.dart';
import '../bookings/my_bookings_screen.dart';
import '../support/support_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/offer_card.dart';
import 'widgets/search_section.dart';
import '../../role_selection/role_selection_screen.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  String _selectedTab = 'Rental Cabs';
  String _pickupLocation = '';
  String _dropLocation = '';
  String _selectedCabType = '4-Seater';
  DateTime _selectedDate = DateTime.now();
  String _selectedRentalPackage = '4 Hrs | 40 KM';
  
  final List<Map<String, dynamic>> _recentSearches = [
    {'pickup': 'Indiranagar', 'drop': 'Airport', 'date': 'Today'},
    {'pickup': 'Koramangala', 'drop': 'MG Road', 'date': 'Yesterday'},
  ];

  int _currentIndex = 0;

  final List<Widget> _screens = [
    // We'll define these in build or as separate methods
  ];

  Widget _buildDrawer() {
    final authState = ref.watch(authProvider);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              authState.isLoggedIn ? (authState.userName ?? 'User') : 'Nova Cabs',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              authState.isLoggedIn ? (authState.userPhone ?? '') : 'Ride with us',
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppTheme.accentColor,
              child: Text(
                authState.isLoggedIn ? (authState.userName?[0] ?? 'N') : 'N',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: AppTheme.primaryColor),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.history, color: AppTheme.primaryColor),
            title: const Text('My Bookings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyBookingsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_offer, color: AppTheme.primaryColor),
            title: const Text('Offers'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => AllOffersScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppTheme.primaryColor),
            title: const Text('Support'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => SupportScreen()));
            },
          ),
          if (authState.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                ref.read(authProvider.notifier).logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => RoleSelectionScreen()),
                  (route) => false,
                );
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login, color: AppTheme.primaryColor),
              title: const Text('Login / Sign Up'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerLoginScreen()));
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 ? AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_taxi, color: AppTheme.accentColor, size: 24),
            ),
            const SizedBox(width: 10),
            const Text('NOVA CABS'),
          ],
        ),
      ) : null,
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return MyBookingsScreen();
      case 2:
        return CustomerProfileScreen();
      case 3:
        return SupportScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return _selectedTab == 'Hotels'
        ? _buildHotelsComingSoon()
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNavigationToggle(),
                 SearchSection(
                  pickupLocation: _pickupLocation,
                  dropLocation: _dropLocation,
                  selectedRentalPackage: _selectedRentalPackage,
                  onPickupChanged: (val) => setState(() => _pickupLocation = val),
                  onDropChanged: (val) => setState(() => _dropLocation = val),
                  onCabTypeChanged: (val) => setState(() => _selectedCabType = val),
                  onDateChanged: (val) => setState(() => _selectedDate = val),
                  onRentalPackageChanged: (val) => setState(() => _selectedRentalPackage = val),
                  selectedCabType: _selectedCabType,
                  selectedDate: _selectedDate,
                  onSearch: _handleSearch,
                  selectedTab: _selectedTab,
                ),
                _buildQuickActions(),
                _buildRecentSearchesSection(),
                _buildOffersSection(),
                const SizedBox(height: 40),
              ],
            ),
          );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book_online_outlined), activeIcon: Icon(Icons.book_online), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.help_outline), activeIcon: Icon(Icons.help), label: 'Support'),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'title': 'Book Cab', 'icon': Icons.local_taxi, 'color': Colors.blue},
      {'title': 'Outstation', 'icon': Icons.map, 'color': Colors.green},
      {'title': 'Airport', 'icon': Icons.flight_takeoff, 'color': Colors.orange},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.map((action) => _buildActionCard(
              title: action['title'] as String,
              icon: action['icon'] as IconData,
              color: action['color'] as Color,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({required String title, required IconData icon, required Color color}) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRecentSearchesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Searches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('Clear')),
            ],
          ),
          ..._recentSearches.map((search) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              child: const Icon(Icons.history, color: Colors.grey, size: 20),
            ),
            title: Text('${search['pickup']} → ${search['drop']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: Text(search['date'] as String, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () {
              setState(() {
                _pickupLocation = search['pickup'] as String;
                _dropLocation = search['drop'] as String;
              });
            },
          )),
        ],
      ),
    );
  }

  Widget _buildHotelsComingSoon() {
    final _emailController = TextEditingController();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavigationToggle(),

          // Compact header strip
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.hotel, color: Colors.white70, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hotels Booking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Book hotels along with your cab ride.',
                        style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🚀 Soon',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── NOTIFY ME card ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  // Icon + badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active, color: AppTheme.primaryColor, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Get Notified When We Launch',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Be the first to know when hotel bookings go live on Nova Cabs.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Email field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email address',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Notify Me button — full width
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ You\'ll be notified when Hotels launches!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        _emailController.clear();
                      },
                      icon: const Icon(Icons.notifications_none, size: 18),
                      label: const Text('Notify Me', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // What to Expect
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What to Expect', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildFeatureCard(Icons.search, Colors.blue, 'Smart Hotel Search',
                    'Search hotels by city, check-in/out dates, and number of guests with real-time availability.'),
                _buildFeatureCard(Icons.local_taxi, Colors.orange, 'Cab + Hotel Bundle',
                    'Book your cab and hotel together in one go and save more with combo deals.'),
                _buildFeatureCard(Icons.star_rate, Colors.amber, 'Verified Reviews',
                    'Read genuine reviews from Nova Cabs travellers who have stayed at these hotels.'),
                _buildFeatureCard(Icons.payments, Colors.green, 'Flexible Payments',
                    'Pay now or pay at hotel. UPI, cards, and Nova Gateway all supported.'),
                _buildFeatureCard(Icons.cancel_schedule_send, Colors.red, 'Free Cancellation',
                    'Cancel up to 24 hours before check-in with zero charges on select hotels.'),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Launch Timeline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📅  Launch Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _buildTimelineItem('Q2 2026', 'Beta launch for select cities', true),
                  _buildTimelineItem('Q3 2026', 'Pan-India hotel coverage', false),
                  _buildTimelineItem('Q4 2026', 'Cab + Hotel bundle deals', false),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, Color color, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(desc,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String period, String label, bool isNext) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isNext ? AppTheme.primaryColor : Colors.grey.shade300,
                  border: isNext
                      ? Border.all(color: AppTheme.primaryColor, width: 2)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isNext ? AppTheme.primaryColor : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              period,
              style: TextStyle(
                color: isNext ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isNext ? Colors.black87 : Colors.grey.shade500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationToggle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildToggleItem('Rental Cabs', Icons.timer_outlined),
          _buildToggleItem('Outstation', Icons.map_outlined),
          _buildToggleItem('Hotels', Icons.hotel_outlined),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String title, IconData icon) {
    bool isSelected = _selectedTab == title;
    bool isHotels = title == 'Hotels';
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedTab != title) {
            setState(() => _selectedTab = title);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade500,
                size: 22,
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    if (isHotels) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Soon',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Recent Searches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: MockData.recentSearches.length,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        MockData.recentSearches[index],
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOffersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Best Offers For You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: MockData.offers.length,
            itemBuilder: (context, index) {
              return OfferCard(offer: MockData.offers[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWhyChooseSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Choose Nova Cabs?',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Choosing the right cab service is not just about getting from one place to another — it’s about comfort, reliability, safety, and peace of mind. At Nova Cabs, we understand the importance of every journey.',
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Our Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildServiceItem(
            'Rentals & Outstation',
            'Reliable and convenient online cab booking for all your travel needs.',
            Icons.map,
          ),
          _buildServiceItem(
            'Multiple Fleet Options',
            'Choose from 4-seater, 7-seater, and 13-seater vehicles for your comfort.',
            Icons.directions_car,
          ),
          _buildServiceItem(
            'Transparent Pricing',
            'View estimated fares upfront and plan your trips with confidence.',
            Icons.payments,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.accentColor.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToBookSection() {
    final steps = [
      'Enter pickup and drop locations',
      'Select cab type',
      'View available cabs',
      'Choose a cab and confirm trip details',
      'Make payment',
      'Receive booking confirmation',
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How to Book a Cab', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(entry.value, style: const TextStyle(fontSize: 14)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _handleSearch() {
    final isRental = _selectedTab == 'Rental Cabs';
    if (_pickupLocation.isEmpty || (!isRental && _dropLocation.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter pickup ${isRental ? '' : 'and drop '}location${isRental ? '' : 's'}')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CabListingScreen(
          pickup: _pickupLocation,
          drop: _dropLocation,
          cabType: _selectedCabType,
          date: _selectedDate,
          rentalPackage: isRental ? _selectedRentalPackage : null,
        ),
      ),
    );
  }
}
