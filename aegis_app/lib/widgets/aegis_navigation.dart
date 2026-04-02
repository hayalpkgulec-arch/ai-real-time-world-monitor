import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/aegis_colors.dart';

/// Top app bar for AEGIS Intelligence.
class AegisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AegisAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 64,
        color: AegisColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.security,
                  color: AegisColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'AEGIS INTELLIGENCE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.0,
                    color: AegisColors.primary,
                  ),
                ),
              ],
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AegisColors.outlineVariant,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person_outline,
                color: AegisColors.onSurfaceVariant,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom navigation bar for AEGIS Intelligence.
class AegisBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AegisBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AegisColors.background,
        border: Border(
          top: BorderSide(
            color: AegisColors.surfaceContainerHigh,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
              label: 'HOME',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.public_outlined,
              activeIcon: Icons.public,
              label: 'MAP',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: Icons.public_outlined,
              activeIcon: Icons.public,
              label: 'RISK MAP',
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _NavItem(
              icon: Icons.rss_feed_outlined,
              activeIcon: Icons.rss_feed,
              label: 'FEED',
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Icons.description_outlined,
              activeIcon: Icons.description,
              label: 'BRIEFS',
              isActive: currentIndex == 4,
              onTap: () => onTap(4),
            ),
            _NavItem(
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications,
              label: 'ALERTS',
              isActive: currentIndex == 5,
              onTap: () => onTap(5),
              showBadge: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool showBadge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AegisColors.surfaceContainerHigh
              : Colors.transparent,
          borderRadius: BorderRadius.circular(0),
          border: isActive
              ? const Border(
                  top: BorderSide(color: AegisColors.primary, width: 2),
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 22,
                  color: isActive
                      ? AegisColors.primary
                      : AegisColors.onSurfaceVariant,
                ),
                if (showBadge)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AegisColors.tertiaryFixed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                letterSpacing: 2.0,
                color: isActive
                    ? AegisColors.primary
                    : AegisColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
