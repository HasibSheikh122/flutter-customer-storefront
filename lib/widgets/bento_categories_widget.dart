// lib/widgets/bento_categories_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/store_models.dart';

class BentoCategoriesWidget extends StatefulWidget {
  const BentoCategoriesWidget({super.key});

  @override
  State<BentoCategoriesWidget> createState() => _BentoCategoriesWidgetState();
}

class _BentoCategoriesWidgetState extends State<BentoCategoriesWidget> {
  final ScrollController _scrollController = ScrollController();

  // Video-er moton 4-ti vibrant color palette
  final List<_BentoPalette> _palettes = const [
    _BentoPalette(
      btnColor: Color(0xFF4F46E5), // Indigo Purple
      badgeBg: Color(0xFFEEF2FF),
      badgeText: Color(0xFF4338CA),
      iconBg: Color(0xFFF8FAFC),
    ),
    _BentoPalette(
      btnColor: Color(0xFFE11D48), // Rose Red
      badgeBg: Color(0xFFFFE4E6),
      badgeText: Color(0xFFBE123C),
      iconBg: Color(0xFFFFF1F2),
    ),
    _BentoPalette(
      btnColor: Color(0xFF059669), // Emerald Green
      badgeBg: Color(0xFFD1FAE5),
      badgeText: Color(0xFF047857),
      iconBg: Color(0xFFECFDF5),
    ),
    _BentoPalette(
      btnColor: Color(0xFFD97706), // Amber Orange
      badgeBg: Color(0xFFFEF3C7),
      badgeText: Color(0xFFB45309),
      iconBg: Color(0xFFFFFBEB),
    ),
  ];

  void _scroll(double offset) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        (_scrollController.offset + offset).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final List<StoreCategory> categories = store.categories;

    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🌟 Top Header: Title, All Categories & Arrow Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 13,
                      color: store.primaryColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'MODERN BENTO TILES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: store.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                InkWell(
                  onTap: () => store.filterByCategory(null),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'All Categories',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: Colors.blueGrey.shade700,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildArrowBtn(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _scroll(-210),
                ),
                const SizedBox(width: 6),
                _buildArrowBtn(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _scroll(210),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 🌟 Horizontal Scrollable Bento Cards
        SizedBox(
          height: 195,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final palette = _palettes[index % _palettes.length];
              final bool isSelected = store.selectedCategorySlug == cat.slug;

              // Product count ber kora
              final int count = store.products
                  .where((p) =>
                      p.categoryName.toLowerCase() == cat.name.toLowerCase() ||
                      p.slug.toLowerCase().contains(cat.slug.toLowerCase()))
                  .length;
              final String itemCountText = count < 10 ? '0$count' : '$count';

              return Container(
                width: 185,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color:
                        isSelected ? palette.btnColor : const Color(0xFFE2E8F0),
                    width: isSelected ? 2.0 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? palette.btnColor.withOpacity(0.18)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row: Icon Container + Items Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: palette.iconBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.05),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: _buildCategoryIcon(cat.icon, cat.name),
                          ),
                        ),
                        Container(
                          width: 58,
                          height: 52,
                          decoration: BoxDecoration(
                            color: palette.badgeBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                itemCountText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: palette.badgeText,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'ITEMS',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                  color: palette.badgeText.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Middle: BENTO COLLECTION Label + Category Name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BENTO COLLECTION',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Colors.blueGrey.shade400,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          cat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Bottom: EXPLORE BENTO Button
                    InkWell(
                      onTap: () =>
                          store.filterByCategory(isSelected ? null : cat.slug),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 9, horizontal: 12),
                        decoration: BoxDecoration(
                          color: palette.btnColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: palette.btnColor.withOpacity(0.32),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'EXPLORE BENTO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
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

  Widget _buildCategoryIcon(String iconStr, String categoryName) {
    if (iconStr.trim().startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          iconStr,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallbackIcon(categoryName),
        ),
      );
    }
    if (iconStr.trim().isNotEmpty) {
      return Text(
        iconStr,
        style: const TextStyle(fontSize: 26),
      );
    }
    return _fallbackIcon(categoryName);
  }

  Widget _fallbackIcon(String name) {
    final lower = name.toLowerCase();
    IconData icon = Icons.category_rounded;
    if (lower.contains('bag') || lower.contains('wallet')) {
      icon = Icons.shopping_bag_rounded;
    } else if (lower.contains('beauty') ||
        lower.contains('personal') ||
        lower.contains('care')) {
      icon = Icons.face_retouching_natural_rounded;
    } else if (lower.contains('computer') ||
        lower.contains('monitor') ||
        lower.contains('tech')) {
      icon = Icons.desktop_windows_rounded;
    } else if (lower.contains('food') ||
        lower.contains('healthy') ||
        lower.contains('grocery')) {
      icon = Icons.fastfood_rounded;
    } else if (lower.contains('jewel') ||
        lower.contains('access') ||
        lower.contains('ring')) {
      icon = Icons.diamond_rounded;
    } else if (lower.contains('cloth') ||
        lower.contains('fashion') ||
        lower.contains('men')) {
      icon = Icons.checkroom_rounded;
    }
    return Icon(icon, size: 26, color: Colors.blueGrey.shade700);
  }

  Widget _buildArrowBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: Colors.blueGrey.shade800),
      ),
    );
  }
}

class _BentoPalette {
  final Color btnColor;
  final Color badgeBg;
  final Color badgeText;
  final Color iconBg;

  const _BentoPalette({
    required this.btnColor,
    required this.badgeBg,
    required this.badgeText,
    required this.iconBg,
  });
}
