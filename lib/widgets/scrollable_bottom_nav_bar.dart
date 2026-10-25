// lib/widgets/scrollable_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';

class ScrollableBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ScrollableBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final Color brandColor = store.primaryColor;

    final List<_NavItem> items = [
      const _NavItem(
        icon: Icons.home_rounded,
        label: 'Home',
      ),
      const _NavItem(
        icon: Icons.notifications_rounded,
        label: 'Notification',
      ),
      _NavItem(
        icon: Icons.shopping_bag_rounded,
        label: 'Cart',
        badgeCount: store.cartCount,
      ),
      const _NavItem(
        icon: Icons.dashboard_customize_rounded,
        label: 'Dashboard',
      ),
      const _NavItem(
        icon: Icons.search_rounded,
        label: 'Search',
      ),
    ];

    return SafeArea(
      child: Container(
        height: 68,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: brandColor.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: brandColor.withOpacity(0.15),
            width: 1.2,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final bool isSelected = currentIndex == index;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    // 🌟 Home button (index == 0) click korle active category filter clear kore main Home-e niye jabe
                    if (index == 0 && store.selectedCategorySlug != null) {
                      store.filterByCategory(null);
                    }
                    onTap(index);
                  },
                  borderRadius: BorderRadius.circular(26),
                  splashColor: brandColor.withOpacity(0.15),
                  highlightColor: Colors.transparent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 16 : 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? brandColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: brandColor.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              item.icon,
                              size: 22,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.blueGrey.shade600,
                            ),
                            if ((item.badgeCount ?? 0) > 0)
                              Positioned(
                                right: -7,
                                top: -6,
                                child: Container(
                                  padding: const EdgeInsets.all(3.5),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.amber.shade800,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? brandColor
                                          : Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${item.badgeCount}',
                                      style: TextStyle(
                                        color: isSelected
                                            ? brandColor
                                            : Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: isSelected
                              ? Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    Text(
                                      item.label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int? badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    this.badgeCount,
  });
}
