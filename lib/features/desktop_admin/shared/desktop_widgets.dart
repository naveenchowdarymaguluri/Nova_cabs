import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/desktop_theme.dart';

// ─── Navigation Sections ──────────────────────────────────────────────────────

enum AdminSection {
  dashboard,
  drivers,
  agencies,
  vehicles,
  bookings,
  payments,
  customers,
  reports,
  notifications,
  settings,
}

extension AdminSectionExt on AdminSection {
  String get label {
    switch (this) {
      case AdminSection.dashboard: return 'Dashboard';
      case AdminSection.drivers: return 'Drivers';
      case AdminSection.agencies: return 'Travel Agencies';
      case AdminSection.vehicles: return 'Vehicles';
      case AdminSection.bookings: return 'Bookings';
      case AdminSection.payments: return 'Payments';
      case AdminSection.customers: return 'Customers';
      case AdminSection.reports: return 'Reports & Analytics';
      case AdminSection.notifications: return 'Notifications';
      case AdminSection.settings: return 'System Settings';
    }
  }

  IconData get icon {
    switch (this) {
      case AdminSection.dashboard: return Icons.dashboard_rounded;
      case AdminSection.drivers: return Icons.person_pin_rounded;
      case AdminSection.agencies: return Icons.business_rounded;
      case AdminSection.vehicles: return Icons.directions_car_rounded;
      case AdminSection.bookings: return Icons.book_online_rounded;
      case AdminSection.payments: return Icons.payments_rounded;
      case AdminSection.customers: return Icons.people_rounded;
      case AdminSection.reports: return Icons.bar_chart_rounded;
      case AdminSection.notifications: return Icons.notifications_rounded;
      case AdminSection.settings: return Icons.settings_rounded;
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final desktopNavProvider = StateProvider<AdminSection>((ref) => AdminSection.dashboard);
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);

// ─── Theme Mode Provider ───────────────────────────────────────────────────────
final desktopThemeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// ─── Admin Login Provider ──────────────────────────────────────────────────────

class AdminLoginState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;
  final String adminName;
  final String adminEmail;

  const AdminLoginState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.error,
    this.adminName = 'Nova Admin',
    this.adminEmail = 'admin@novacabs.com',
  });

  AdminLoginState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
    String? adminName,
    String? adminEmail,
  }) {
    return AdminLoginState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      adminName: adminName ?? this.adminName,
      adminEmail: adminEmail ?? this.adminEmail,
    );
  }
}

class AdminLoginNotifier extends StateNotifier<AdminLoginState> {
  AdminLoginNotifier() : super(const AdminLoginState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(seconds: 1));

    // Demo credentials
    if ((email == 'admin@novacabs.com' && password == 'admin123') ||
        (email.isNotEmpty && password.length >= 6)) {
      state = state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        adminEmail: email,
      );
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      error: 'Invalid credentials. Use admin@novacabs.com / admin123',
    );
    return false;
  }

  void logout() {
    state = const AdminLoginState();
  }
}

final adminLoginProvider = StateNotifierProvider<AdminLoginNotifier, AdminLoginState>(
  (ref) => AdminLoginNotifier(),
);

// ─── Stat Card Widget ─────────────────────────────────────────────────────────

class DesktopStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool trendUp;
  final VoidCallback? onTap;

  const DesktopStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20), // Reduced from 24
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: DesktopTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10), // Reduced from 12
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22), // Reduced from 24
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (trendUp ? DesktopTheme.success : DesktopTheme.danger).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          trendUp ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: trendUp ? DesktopTheme.success : DesktopTheme.danger,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trend!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: trendUp ? DesktopTheme.success : DesktopTheme.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: DesktopTheme.textPrimary,
                  letterSpacing: -1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DesktopTheme.textMuted,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: DesktopTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;

  const StatusBadge(this.status, {super.key, this.fontSize});

  @override
  Widget build(BuildContext context) {
    final color = DesktopTheme.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: fontSize ?? 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: DesktopTheme.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 13, color: DesktopTheme.textSecondary),
              ),
            ],
          ],
        ),
        if (action != null) action!,
      ],
    );
  }
}

// ─── Search Bar ────────────────────────────────────────────────────────────────

class DesktopSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final double width;

  const DesktopSearchBar({
    super.key,
    this.hint = 'Search...',
    this.onChanged,
    this.width = 280,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 38,
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: DesktopTheme.textMuted),
          prefixIcon: const Icon(Icons.search, size: 16, color: DesktopTheme.textMuted),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          filled: true,
          fillColor: DesktopTheme.cardBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: DesktopTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: DesktopTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: DesktopTheme.primaryBlue, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool outlined;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? DesktopTheme.primaryBlue;

    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 16) : const SizedBox.shrink(),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: btnColor,
          side: BorderSide(color: btnColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      );
    }

    return SizedBox(
  width: 160, // set button width
  child: ElevatedButton.icon(
    onPressed: onPressed,
    icon: icon != null
        ? Icon(icon, size: 16, color: Colors.white)
        : const SizedBox.shrink(),
    label: Text(label, style: const TextStyle(color: Colors.white)),
    style: ElevatedButton.styleFrom(
      backgroundColor: btnColor,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
  ),
);
  }
}
