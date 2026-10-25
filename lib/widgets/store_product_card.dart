// lib/widgets/store_product_card.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/store_models.dart';

class StoreProductCard extends StatelessWidget {
  final StoreProduct product;
  final Color primaryColor;
  final VoidCallback onAddToCart;
  final VoidCallback? onTap;
  final int index;

  const StoreProductCard({
    super.key,
    required this.product,
    required this.primaryColor,
    required this.onAddToCart,
    this.onTap,
    this.index = 0,
  });

  // Screenshot-er moto 4-ti vibrant neon gradient palette
  static const List<List<Color>> _cardPalettes = [
    [
      Color(0xFF06B6D4),
      Color(0xFF3B82F6),
      Color(0xFF4338CA)
    ], // Cyan -> Blue -> Indigo
    [
      Color(0xFFEC4899),
      Color(0xFF8B5CF6),
      Color(0xFF6D28D9)
    ], // Pink -> Purple -> Violet
    [
      Color(0xFF10B981),
      Color(0xFF0D9488),
      Color(0xFF0F766E)
    ], // Emerald -> Teal
    [
      Color(0xFFF97316),
      Color(0xFFEF4444),
      Color(0xFFE11D48)
    ], // Orange -> Red -> Rose
  ];

  int _calculateDiscountPercent() {
    if (product.regularPrice != null &&
        product.regularPrice! > product.price &&
        product.regularPrice! > 0) {
      return (((product.regularPrice! - product.price) /
                  product.regularPrice!) *
              100)
          .round();
    }
    // Demo fallback discount badges (-33%, -40%, -29%) jodi backend-e compare_price na thake
    const fallbackDiscounts = [33, 40, 29, 33];
    return fallbackDiscounts[index % fallbackDiscounts.length];
  }

  String _formatNumber(double val) {
    final intVal = val.round();
    final str = intVal.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> palette = _cardPalettes[index % _cardPalettes.length];
    final int discount = _calculateDiscountPercent();
    final String imgUrl = product.primaryImage ?? product.image;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: palette[0].withOpacity(0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: palette[1].withOpacity(0.14),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🌟 1. HEXAGON IMAGE FRAME + CORNER DISCOUNT HEXAGON BADGE
            SizedBox(
              height: 138,
              width: 138,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Outer Gradient Hexagon Border
                  ClipPath(
                    clipper: _HexagonClipper(),
                    child: Container(
                      width: 136,
                      height: 136,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: palette,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),

                  // Inner Dark Background Hexagon + Product Image
                  ClipPath(
                    clipper: _HexagonClipper(),
                    child: Container(
                      width: 126,
                      height: 126,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF090D16), Color(0xFF1E293B)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: imgUrl.isNotEmpty && imgUrl.startsWith('http')
                          ? Image.network(
                              imgUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_outlined,
                                color: Colors.white54,
                                size: 42,
                              ),
                            )
                          : const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white54,
                              size: 42,
                            ),
                    ),
                  ),

                  // Top-Right Hexagon Discount Badge (-33%, -40%, etc.)
                  if (discount > 0)
                    Positioned(
                      top: -2,
                      right: 2,
                      child: ClipPath(
                        clipper: _HexagonClipper(),
                        child: Container(
                          width: 38,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [palette[0], palette[2]],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '-$discount%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // 🌟 2. CATEGORY DOT + NAME
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipPath(
                  clipper: _HexagonClipper(),
                  child: Container(
                    width: 8,
                    height: 8,
                    color: palette[0].withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    (product.categoryName.isNotEmpty
                            ? product.categoryName
                            : 'COMPUTER')
                        .toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette[1],
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),

            // 🌟 3. PRODUCT TITLE (UPPERCASE BOLD)
            Text(
              product.name.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),

            // 🌟 4. 5-STAR RATING ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  5,
                  (_) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1),
                    child: Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(5.0)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
              ],
            ),

            // 🌟 5. BOLD PRICE
            Text(
              '৳${_formatNumber(product.price)}',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 4),

            // 🌟 6. HEXAGON-TIPPED GRADIENT "ADD TO CART" BUTTON
            GestureDetector(
              onTap: onAddToCart,
              child: ClipPath(
                clipper: _HexButtonClipper(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [palette[0], palette[2]],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'ADD TO CART',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pointy-top Hexagon Clipper (Image Frame & Discount Badge er jonno)
class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Hexagon-tipped Button Clipper (ADD TO CART button er jonno)
class _HexButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double cut = math.min(12.0, size.height * 0.35);
    path.moveTo(cut, 0);
    path.lineTo(size.width - cut, 0);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width - cut, size.height);
    path.lineTo(cut, size.height);
    path.lineTo(0, size.height * 0.5);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
