// lib/screens/store_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../widgets/store_product_card.dart';
import '../widgets/scrollable_bottom_nav_bar.dart';
import '../widgets/hero_banner_widget.dart';
import '../models/store_models.dart';
import 'cart_checkout_screen.dart';
import 'product_details_screen.dart';

class StoreHomeScreen extends StatefulWidget {
  const StoreHomeScreen({super.key});

  @override
  State<StoreHomeScreen> createState() => _StoreHomeScreenState();
}

class _StoreHomeScreenState extends State<StoreHomeScreen> {
  int _currentNavIndex = 0;
  final ScrollController _bentoScrollController = ScrollController();

  final List<_BentoPalette> _bentoPalettes = const [
    _BentoPalette(
      btnColor: Color(0xFF4F46E5),
      badgeBg: Color(0xFFEEF2FF),
      badgeText: Color(0xFF4338CA),
      iconBg: Color(0xFFF8FAFC),
    ),
    _BentoPalette(
      btnColor: Color(0xFFE11D48),
      badgeBg: Color(0xFFFFE4E6),
      badgeText: Color(0xFFBE123C),
      iconBg: Color(0xFFFFF1F2),
    ),
    _BentoPalette(
      btnColor: Color(0xFF059669),
      badgeBg: Color(0xFFD1FAE5),
      badgeText: Color(0xFF047857),
      iconBg: Color(0xFFECFDF5),
    ),
    _BentoPalette(
      btnColor: Color(0xFFD97706),
      badgeBg: Color(0xFFFEF3C7),
      badgeText: Color(0xFFB45309),
      iconBg: Color(0xFFFFFBEB),
    ),
  ];

  void _scrollBento(double offset) {
    if (_bentoScrollController.hasClients) {
      _bentoScrollController.animateTo(
        (_bentoScrollController.offset + offset).clamp(
          0.0,
          _bentoScrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  List<StoreCategory> _resolveCategories(StoreProvider store) {
    if (store.categories.isNotEmpty) {
      return store.categories;
    }

    final Map<String, StoreCategory> fromProducts = {};
    for (final p in store.products) {
      final name = p.categoryName.trim();
      if (name.isNotEmpty && !fromProducts.containsKey(name.toLowerCase())) {
        fromProducts[name.toLowerCase()] = StoreCategory(
          name: name,
          slug: name.toLowerCase().replaceAll(' ', '-'),
          icon: _resolveCategoryIcon(name),
        );
      }
    }
    if (fromProducts.isNotEmpty) {
      return fromProducts.values.toList();
    }

    return [
      StoreCategory(name: 'Bags & Wallets', slug: 'bags-wallets', icon: '👜'),
      StoreCategory(
          name: 'Beauty & Personal Care',
          slug: 'beauty-personal-care',
          icon: '💄'),
      StoreCategory(name: 'Computer', slug: 'computer', icon: '🖥️'),
      StoreCategory(
          name: 'Foods And Healthy', slug: 'foods-and-healthy', icon: '🍱'),
      StoreCategory(name: 'General', slug: 'general', icon: '📦'),
      StoreCategory(
          name: 'Jewelry & Accessories',
          slug: 'jewelry-accessories',
          icon: '💍'),
      StoreCategory(name: 'Kids', slug: 'kids', icon: '🧸'),
      StoreCategory(name: "Men's Fashions", slug: 'mens-fashions', icon: '👔'),
      StoreCategory(name: "Men's Clothing", slug: 'mens-clothing', icon: '👕'),
      StoreCategory(name: 'Monitors', slug: 'monitors', icon: '🖥️'),
      StoreCategory(name: 'Vegetable', slug: 'vegetable', icon: '🥦'),
    ];
  }

  String _resolveCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('bag') || lower.contains('wallet')) return '👜';
    if (lower.contains('beauty') || lower.contains('care')) return '💄';
    if (lower.contains('comp') ||
        lower.contains('monitor') ||
        lower.contains('tech')) return '🖥️';
    if (lower.contains('food') || lower.contains('health')) return '🍱';
    if (lower.contains('jewel') || lower.contains('ring')) return '💍';
    if (lower.contains('kid') || lower.contains('toy')) return '🧸';
    if (lower.contains('men') ||
        lower.contains('cloth') ||
        lower.contains('shoe')) return '👔';
    if (lower.contains('veg')) return '🥦';
    return '📦';
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: store.primaryColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              store.storeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            Text(
              store.announcementText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _currentNavIndex = 2;
              });
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined),
                if (store.cartCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '${store.cartCount}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildHomeBody(store),
          _buildPlaceholderPage(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Ekhon kono notun notification nei.',
            primaryColor: store.primaryColor,
          ),
          const CartCheckoutScreen(),
          _buildPlaceholderPage(
            icon: Icons.account_circle_outlined,
            title: 'Customer Dashboard',
            subtitle: 'Apnar order history ebong profile ekhane ashbe.',
            primaryColor: store.primaryColor,
          ),
          _buildSearchPage(store),
        ],
      ),
      bottomNavigationBar: ScrollableBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeBody(StoreProvider store) {
    final categories = _resolveCategories(store);
    final selectedSlug = store.selectedCategorySlug;
    final StoreCategory? activeCategory = selectedSlug == null
        ? null
        : categories.firstWhere(
            (c) => c.slug == selectedSlug,
            orElse: () => StoreCategory(
              name: selectedSlug.toUpperCase(),
              slug: selectedSlug,
              icon: _resolveCategoryIcon(selectedSlug),
            ),
          );

    return RefreshIndicator(
      onRefresh: store.initializeStore,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        children: [
          // Jodi kono category select kora na thake tobe Hero Banner o Bento Categories dekhabe
          if (activeCategory == null) ...[
            const HeroBannerWidget(),
            const SizedBox(height: 22),
            _buildBentoCategorySection(store, categories),
            const SizedBox(height: 24),
          ] else ...[
            // 🌟 Category Click korle Video-er moto Category Header Banner dekhabe
            _buildSelectedCategoryBanner(store, activeCategory),
            const SizedBox(height: 20),
          ],

          // 🌟 PRODUCTS SECTION HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  activeCategory != null
                      ? 'Products in ${activeCategory.name}'
                      : 'Popular Products',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (activeCategory != null)
                InkWell(
                  onTap: () => store.filterByCategory(null),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_rounded,
                            size: 15, color: store.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'Back to Store',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: store.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // 🌟 HEXAGON PRODUCTS GRID
          if (store.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (store.products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                  child: Text('এই ক্যাটাগরিতে কোনো প্রোডাক্ট পাওয়া যায়নি।')),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: store.products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio:
                    0.56, // Hexagon card design-er jonno perfect ratio
              ),
              itemBuilder: (context, idx) {
                final product = store.products[idx];
                return StoreProductCard(
                  index: idx,
                  product: product,
                  primaryColor: store.primaryColor,
                  // 🌟 Product-e click korle Product Details Page-e jabe
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(
                          product: product,
                          paletteIndex: idx,
                        ),
                      ),
                    );
                  },
                  onAddToCart: () {
                    store.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} কার্টে যুক্ত হয়েছে!'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  // 🌟 Category select korle upore green/brand card header
  Widget _buildSelectedCategoryBanner(
      StoreProvider store, StoreCategory category) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            store.primaryColor,
            Color.lerp(store.primaryColor, Colors.black, 0.35) ??
                const Color(0xFF064E3B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: store.primaryColor.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.icon.isNotEmpty ? category.icon : '📦',
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Curated ${category.name} collection & essentials for everyday use.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Showing ${store.products.length} Products',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCategorySection(
      StoreProvider store, List<StoreCategory> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    Icon(Icons.auto_awesome,
                        size: 13, color: store.primaryColor),
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
                const SizedBox(width: 6),
                _buildCircleArrow(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _scrollBento(-210),
                ),
                const SizedBox(width: 5),
                _buildCircleArrow(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _scrollBento(210),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 195,
          child: ListView.separated(
            controller: _bentoScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final palette = _bentoPalettes[index % _bentoPalettes.length];
              final bool isSelected = store.selectedCategorySlug == cat.slug;

              final int count = store.products
                  .where((p) =>
                      p.categoryName
                          .toLowerCase()
                          .contains(cat.name.toLowerCase()) ||
                      cat.name
                          .toLowerCase()
                          .contains(p.categoryName.toLowerCase()))
                  .length;
              final String itemCountText = count < 10 ? '0$count' : '$count';

              return GestureDetector(
                onTap: () =>
                    store.filterByCategory(isSelected ? null : cat.slug),
                child: Container(
                  width: 185,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? palette.btnColor
                          : const Color(0xFFE2E8F0),
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
                              child: cat.icon.trim().startsWith('http')
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(cat.icon,
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.contain),
                                    )
                                  : Text(
                                      cat.icon.isNotEmpty ? cat.icon : '📦',
                                      style: const TextStyle(fontSize: 26),
                                    ),
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
                      Container(
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
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCircleArrow(
      {required IconData icon, required VoidCallback onTap}) {
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

  Widget _buildPlaceholderPage({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: primaryColor),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPage(StoreProvider store) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      child: Column(
        children: [
          TextField(
            onSubmitted: (query) {
              store.searchProducts(query);
              setState(() {
                _currentNavIndex = 0;
              });
            },
            decoration: InputDecoration(
              hintText: 'Product search korun...',
              prefixIcon: Icon(Icons.search, color: store.primaryColor),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: store.primaryColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: store.primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Icon(Icons.manage_search_rounded,
              size: 64, color: store.primaryColor.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            'Product-er naam likhe search korun',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
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
