import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';

class DesktopSidebar extends ConsumerWidget {
  const DesktopSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSection = ref.watch(desktopNavProvider);
    final isCollapsed = ref.watch(sidebarCollapsedProvider);

    return Container(
      decoration: const BoxDecoration(
        color: DesktopTheme.sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLogo(isCollapsed),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 12 : 16, vertical: 8),
              children: [
                if (!isCollapsed) _buildSectionLabel('OVERVIEW'),
                _buildNavItem(ref, AdminSection.dashboard, currentSection, isCollapsed),
                const SizedBox(height: 16),

                if (!isCollapsed) _buildSectionLabel('MANAGEMENT'),
                _buildNavItem(ref, AdminSection.drivers, currentSection, isCollapsed),
                _buildNavItem(ref, AdminSection.agencies, currentSection, isCollapsed),
                _buildNavItem(ref, AdminSection.vehicles, currentSection, isCollapsed),
                _buildNavItem(ref, AdminSection.bookings, currentSection, isCollapsed),
                _buildNavItem(ref, AdminSection.payments, currentSection, isCollapsed),
                _buildNavItem(ref, AdminSection.customers, currentSection, isCollapsed),
                const SizedBox(height: 16),

                if (!isCollapsed) _buildSectionLabel('ANALYTICS'),
                _buildNavItem(ref, AdminSection.reports, currentSection, isCollapsed),
                const SizedBox(height: 16),

                if (!isCollapsed) _buildSectionLabel('SYSTEM'),
                _buildNavItem(ref, AdminSection.notifications, currentSection, isCollapsed),
                _buildNavItem(ref, AdminSection.settings, currentSection, isCollapsed),
              ],
            ),
          ),
          _buildAdminProfile(context, ref, isCollapsed),
        ],
      ),
    );
  }

  Widget _buildLogo(bool isCollapsed) {
    return Container(
      height: DesktopTheme.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 20),
      alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DesktopTheme.primaryBlue, DesktopTheme.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: DesktopTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.local_taxi_rounded, color: Colors.white, size: 24),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 14),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NOVA CABS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'ADMIN PORTAL',
                  style: TextStyle(
                    color: DesktopTheme.primaryBlue.withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.2),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildNavItem(WidgetRef ref, AdminSection section, AdminSection current, bool isCollapsed) {
    final isActive = section == current;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => ref.read(desktopNavProvider.notifier).state = section,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 16, 
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isActive ? DesktopTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? [
              BoxShadow(
                color: DesktopTheme.primaryBlue.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                section.icon,
                size: 22,
                color: isActive ? Colors.white : DesktopTheme.sidebarText,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    section.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? Colors.white : DesktopTheme.sidebarText,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminProfile(BuildContext context, WidgetRef ref, bool isCollapsed) {
    return Container(
      padding: EdgeInsets.all(isCollapsed ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: DesktopTheme.primaryBlue.withOpacity(0.2),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nova Admin',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Super Admin',
                    style: TextStyle(color: DesktopTheme.sidebarText, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white54, size: 20),
              onPressed: () => ref.read(adminLoginProvider.notifier).logout(),
            ),
          ],
        ],
      ),
    );
  }
}
