import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';

class DesktopHeader extends ConsumerWidget {
  const DesktopHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSection = ref.watch(desktopNavProvider);
    final isCollapsed = ref.watch(sidebarCollapsedProvider);

    return Container(
      height: DesktopTheme.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sidebar Toggle
          IconButton(
            onPressed: () => ref.read(sidebarCollapsedProvider.notifier).state = !isCollapsed,
            icon: Icon(
              isCollapsed ? Icons.menu_open_rounded : Icons.menu_rounded,
              color: DesktopTheme.textSecondary,
              size: 24,
            ),
            tooltip: 'Toggle Sidebar',
          ),
          const SizedBox(width: 16),

          // Section Title
          _buildBreadcrumbs(currentSection),
          const Spacer(),

          // Search Row
          _buildSearchBar(),
          const SizedBox(width: 24),

          // Actions
          _buildHeaderActions(ref),
          const SizedBox(width: 24),

          // Profile
          _buildProfileDropdown(ref),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs(AdminSection section) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Nova Cabs',
              style: TextStyle(
                color: DesktopTheme.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 14, color: DesktopTheme.textMuted),
            Text(
              'Admin',
              style: TextStyle(
                color: DesktopTheme.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          section.label,
          style: const TextStyle(
            color: DesktopTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 320,
      height: 44,
      decoration: BoxDecoration(
        color: DesktopTheme.contentBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, size: 20, color: DesktopTheme.textMuted),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search anything...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.transparent,
              ),
              style: TextStyle(fontSize: 14),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black.withOpacity(0.1)),
            ),
            child: Text(
              '⌘ K',
              style: TextStyle(fontSize: 10, color: DesktopTheme.textMuted, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderActions(WidgetRef ref) {
    return Row(
      children: [
        _HeaderIcon(icon: Icons.notifications_outlined, badgeCount: 5),
        const SizedBox(width: 12),
        _HeaderIcon(icon: Icons.help_outline_rounded),
        const SizedBox(width: 12),
        _HeaderIcon(icon: Icons.settings_outlined),
      ],
    );
  }

  Widget _buildProfileDropdown(WidgetRef ref) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [DesktopTheme.primaryBlue, DesktopTheme.purple]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nova Admin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                Text('Super Admin', style: TextStyle(fontSize: 10, color: DesktopTheme.textMuted)),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: DesktopTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final int? badgeCount;

  const _HeaderIcon({required this.icon, this.badgeCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Icon(icon, color: DesktopTheme.textSecondary, size: 22),
        ),
        if (badgeCount != null)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: DesktopTheme.danger,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$badgeCount',
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
