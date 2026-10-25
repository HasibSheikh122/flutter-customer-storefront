// lib/widgets/hero_banner_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/store_models.dart';

class HeroBannerWidget extends StatefulWidget {
  const HeroBannerWidget({super.key});

  @override
  State<HeroBannerWidget> createState() => _HeroBannerWidgetState();
}

class _HeroBannerWidgetState extends State<HeroBannerWidget> {
  final PageController _pageController = PageController();
  int _activePage = 0;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final Color brandColor = store.primaryColor;

    // Backend-er banner thakle sheti ashbe, na thakle store info diye vibrant banner toiri hobe
    final List<StoreBanner> banners = store.heroBanners.isNotEmpty
        ? store.heroBanners
        : [
            StoreBanner(
              badgeTitle: 'EXCLUSIVE OFFER • UP TO 50% OFF',
              title: store.storeName,
              subtitle: store.announcementText.isNotEmpty
                  ? store.announcementText
                  : 'Get authentic products delivered directly to your doorstep with instant cash on delivery.',
              buttonText: 'Shop Now',
              image: '',
            ),
          ];

    return Column(
      children: [
        SizedBox(
          height: 195, // Mobile screen-er jonno perfect balanced height
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (idx) => setState(() => _activePage = idx),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return _buildSplitBannerCard(
                  banner, brandColor, store.secondaryColor);
            },
          ),
        ),
        if (banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _activePage == i ? 18 : 6,
                height: 5,
                decoration: BoxDecoration(
                  color: _activePage == i ? brandColor : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSplitBannerCard(
      StoreBanner banner, Color brandColor, Color secondaryColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            brandColor,
            Color.lerp(brandColor, Colors.black, 0.15) ?? brandColor,
            const Color(0xFF0F172A), // Deep stylish dark gradient finish
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: brandColor.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background soft ambient glow bubbles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.18),
              ),
            ),
          ),

          // Main 55/45 Side-by-Side (Split) Layout
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 🌟 BAAM PASH: Badge, Title, Subtitle & Button
                Expanded(
                  flex: 55,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded,
                                color: Colors.amberAccent, size: 12),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                banner.badgeTitle.isNotEmpty
                                    ? banner.badgeTitle
                                    : 'MEGA DEAL • 50% OFF',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        banner.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Subtitle
                      Text(
                        banner.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Clean Elevated White Button
                      InkWell(
                        onTap: () {
                          // Banner click action
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                banner.buttonText.isNotEmpty
                                    ? banner.buttonText
                                    : 'Shop Now',
                                style: TextStyle(
                                  color: brandColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: brandColor,
                                size: 13,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // 🌟 DAAN PASH: Stylish Product Picture with Glow Card
                Expanded(
                  flex: 45,
                  child: Center(
                    child: Container(
                      height: 145,
                      width: 145,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.28),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: banner.image.isNotEmpty
                            ? (banner.image.startsWith('http')
                                ? Image.network(
                                    banner.image,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        _buildFallbackVisual(brandColor),
                                  )
                                : Image.asset(
                                    banner.image,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        _buildFallbackVisual(brandColor),
                                  ))
                            : _buildFallbackVisual(brandColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackVisual(Color brandColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.shopping_bag_rounded,
          color: Colors.white,
          size: 52,
        ),
      ),
    );
  }
}
