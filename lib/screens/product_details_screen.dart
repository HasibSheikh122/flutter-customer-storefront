// lib/screens/product_details_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/store_models.dart';
import '../providers/store_provider.dart';
import 'cart_checkout_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final StoreProduct product;
  final int paletteIndex;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.paletteIndex = 0,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  bool _isWishlisted = false;

  // Color & Size selection state
  int _selectedColorIndex = 0;
  String _selectedSize = 'M';
  int _quantity = 1;

  // Flash sale live countdown timer
  late Timer _countdownTimer;
  Duration _remainingTime = const Duration(
    days: 435,
    hours: 3,
    minutes: 27,
    seconds: 53,
  );

  // Interactive Review Form State
  int _userRating = 5;
  final TextEditingController _reviewController = TextEditingController();
  late List<_ReviewItem> _reviews;

  final List<Color> _colorOptions = const [
    Color(0xFF4F46E5), // Indigo Blue
    Color(0xFFF59E0B), // Amber Yellow
    Color(0xFF10B981), // Emerald Green
    Color(0xFFE11D48), // Rose Pink
  ];

  final List<String> _sizeOptions = const ['S', 'M', 'L'];

  @override
  void initState() {
    super.initState();
    _reviews = [
      const _ReviewItem(
        authorName: 'Designing World',
        dateText: '12 Dec 2026',
        comment: "Very good product. It's just amazing!",
        rating: 5,
        avatarColor: Color(0xFF6366F1),
        hasThumbnails: true,
      ),
      const _ReviewItem(
        authorName: 'Designing World',
        dateText: '8 Dec 2026',
        comment: 'Very excellent product. Love it.',
        rating: 5,
        avatarColor: Color(0xFFEC4899),
        hasThumbnails: true,
      ),
      const _ReviewItem(
        authorName: 'Designing World',
        dateText: '28 Nov 2026',
        comment: "What a nice product it is. I am looking it's.",
        rating: 5,
        avatarColor: Color(0xFF10B981),
        hasThumbnails: false,
      ),
    ];

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _imagePageController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  List<String> get _productImages {
    final p = widget.product;
    if (p.galleryImages.length > 1) {
      return p.galleryImages;
    }
    final main = p.primaryImage ?? p.image;
    if (main.isNotEmpty) {
      // স্লাইডার টেস্ট করার জন্য অন্তত ২টি স্লাইড রাখা হয়েছে
      return [main, main];
    }
    return [''];
  }

  void _prevImage() {
    if (_currentImageIndex > 0) {
      _imagePageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _imagePageController.animateToPage(
        _productImages.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextImage() {
    if (_currentImageIndex < _productImages.length - 1) {
      _imagePageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _imagePageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatCountdown(Duration d) {
    final days = d.inDays;
    final hours = (d.inHours % 24).toString().padLeft(2, '0');
    final mins = (d.inMinutes % 60).toString().padLeft(2, '0');
    final secs = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '${days}d ${hours}h ${mins}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final product = widget.product;
    final images = _productImages;

    final double oldPrice =
        (product.regularPrice != null && product.regularPrice! > product.price)
            ? product.regularPrice!
            : (product.price * 1.12).roundToDouble();

    // Related products (স্টোরের অন্যান্য প্রোডাক্ট)
    final List<StoreProduct> relatedProducts =
        store.products.where((p) => p.id != product.id).take(6).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      // 🌟 TOP APP BAR (Video Style)
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartCheckoutScreen()),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notes_rounded,
                        size: 19, color: Color(0xFF334155)),
                    if (store.cartCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE11D48),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ===================================================================
          // 🌟 1. CIRCULAR PRODUCT IMAGE CAROUSEL WITH PLAY & ARROW BUTTONS
          // ===================================================================
          Container(
            height: 320,
            color: const Color(0xFFF1F5F9),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // White Circular Frame
                Container(
                  width: 265,
                  height: 265,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: PageView.builder(
                      controller: _imagePageController,
                      itemCount: images.length,
                      onPageChanged: (idx) =>
                          setState(() => _currentImageIndex = idx),
                      itemBuilder: (context, index) {
                        final imgUrl = images[index];
                        return Padding(
                          padding: const EdgeInsets.all(28),
                          child: imgUrl.isNotEmpty && imgUrl.startsWith('http')
                              ? Image.network(
                                  imgUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.local_florist_rounded,
                                    size: 90,
                                    color: store.primaryColor.withOpacity(0.5),
                                  ),
                                )
                              : Icon(
                                  Icons.shopping_bag_rounded,
                                  size: 90,
                                  color: store.primaryColor.withOpacity(0.5),
                                ),
                        );
                      },
                    ),
                  ),
                ),

                // Top-Left Pink Video Play Button
                Positioned(
                  top: 4,
                  left: 6,
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('প্রোডাক্ট ভিডিও প্রিভিউ শীঘ্রই আসছে!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE11D48).withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),

                // Left Arrow (<)
                Positioned(
                  left: 6,
                  child: _buildSliderArrowButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: _prevImage,
                  ),
                ),

                // Right Arrow (>)
                Positioned(
                  right: 6,
                  child: _buildSliderArrowButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: _nextImage,
                  ),
                ),
              ],
            ),
          ),

          // ===================================================================
          // 🌟 2. TITLE, WISHLIST, PRICE & RATING CARD
          // ===================================================================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Heart Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          setState(() => _isWishlisted = !_isWishlisted),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          _isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: const Color(0xFFE11D48),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Sale Price + Strikethrough Compare Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '৳${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '৳${oldPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Stars + Ratings Count + "5.0 Very Good"
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (_) => const Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_reviews.length} ratings',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Very Good',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ===================================================================
          // 🌟 3. FLASH SALE COUNTDOWN & 82% SOLD OUT BAR
          // ===================================================================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Flash sale end in',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCountdown(_remainingTime),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '82% Sold Out',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 115,
                      height: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 0.82,
                          backgroundColor: Color(0xFFE2E8F0),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ===================================================================
          // 🌟 4. COLOR SWATCHES & SIZE SELECTOR
          // ===================================================================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Color Picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Color',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(_colorOptions.length, (idx) {
                        final c = _colorOptions[idx];
                        final isSelected = _selectedColorIndex == idx;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedColorIndex = idx),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 16)
                                : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),

                // Size Picker (S, M, L)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Size',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: _sizeOptions.map((size) {
                        final isSelected = _selectedSize == size;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSize = size),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFE11D48)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFE11D48)
                                          : const Color(0xFFCBD5E1),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  size,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w900
                                        : FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ===================================================================
          // 🌟 5. QUANTITY STEPPER & "Add To Cart" BUTTON
          // ===================================================================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                // Minus (-) Button
                _buildQtySquareButton(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                ),
                const SizedBox(width: 10),

                // Quantity Pill Display
                Container(
                  constraints: const BoxConstraints(minWidth: 54),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Plus (+) Button
                _buildQtySquareButton(
                  icon: Icons.add_rounded,
                  onTap: () => setState(() => _quantity++),
                ),

                const SizedBox(width: 18),

                // Add To Cart Pill Button
                ElevatedButton(
                  onPressed: () {
                    for (int i = 0; i < _quantity; i++) {
                      store.addToCart(product);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '$_quantityটি ${product.name} কার্টে যুক্ত হয়েছে!'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text(
                    'Add To Cart',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ===================================================================
          // 🌟 6. SPECIFICATIONS & SUMMER CLOTHING PROMO VIDEO BANNER
          // ===================================================================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Specifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  product.description.isNotEmpty
                      ? product.description
                      : 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Quasi, eum? Id, culpa? At officia quisquam laudantium nisi mollitia nesciunt, qui porro asperiores cum voluptates placeat similique recusandae in facere quos vitae?',
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.55,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 14),
                _buildSpecCheckRow('100% Good Reviews'),
                const SizedBox(height: 6),
                _buildSpecCheckRow('7 Days Returns'),
                const SizedBox(height: 6),
                _buildSpecCheckRow('Warranty not Aplicable'),
                const SizedBox(height: 6),
                _buildSpecCheckRow('100% Brand New Product'),
                const SizedBox(height: 14),
                const Text(
                  'Lorem ipsum dolor sit amet consectetur adipisicing elit. Quasi, eum? Id, culpa? At officia quisquam laudantium nisi mollitia nesciunt, qui porro asperiores cum voluptates placeat similique recusandae in facere quos vitae?',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.55,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),

                // Promotional Banner ("Summer Clothing" + Play Button)
                Container(
                  height: 145,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFBAE6FD),
                        Color(0xFF38BDF8),
                        Color(0xFF0284C7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Subtle wave overlay
                      Positioned(
                        bottom: -20,
                        left: -20,
                        right: -20,
                        child: Container(
                          height: 65,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Summer Clothing',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ===================================================================
          // 🌟 7. RELATED PRODUCTS HORIZONTAL SECTION
          // ===================================================================
          if (relatedProducts.isNotEmpty) ...[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Related Products',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'View all',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 235,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: relatedProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, idx) {
                        final relProd = relatedProducts[idx];
                        return _buildRelatedProductCard(
                            context, store, relProd, idx);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ===================================================================
          // 🌟 8. RATINGS & REVIEWS LIST
          // ===================================================================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ratings & Reviews',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 14),
                ...List.generate(_reviews.length, (idx) {
                  final rev = _reviews[idx];
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: idx == _reviews.length - 1 ? 0 : 16),
                    child: _buildReviewRow(rev, images.first),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ===================================================================
          // 🌟 9. SUBMIT A REVIEW FORM
          // ===================================================================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Submit A Review',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(5, (idx) {
                    final starNumber = idx + 1;
                    final isFilled = starNumber <= _userRating;
                    return GestureDetector(
                      onTap: () => setState(() => _userRating = starNumber),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.star_rounded,
                          size: 28,
                          color: isFilled
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reviewController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write your review...',
                    hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 13.5),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {
                    final text = _reviewController.text.trim();
                    if (text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('অনুগ্রহ করে আপনার মতামত লিখুন।')),
                      );
                      return;
                    }
                    setState(() {
                      _reviews.insert(
                        0,
                        _ReviewItem(
                          authorName: 'Verified Customer',
                          dateText: 'Just now',
                          comment: text,
                          rating: _userRating,
                          avatarColor: store.primaryColor,
                          hasThumbnails: false,
                        ),
                      );
                      _reviewController.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('আপনার রিভিউ সফলভাবে যুক্ত হয়েছে!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Save Review',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderArrowButton(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF4F46E5)),
      ),
    );
  }

  Widget _buildQtySquareButton(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1E293B)),
      ),
    );
  }

  Widget _buildSpecCheckRow(String text) {
    return Row(
      children: [
        const Icon(Icons.check_rounded, size: 16, color: Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedProductCard(
    BuildContext context,
    StoreProvider store,
    StoreProduct relProd,
    int idx,
  ) {
    final String imgUrl = relProd.primaryImage ?? relProd.image;
    final bool isEven = idx % 2 == 0;

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(
              product: relProd,
              paletteIndex: idx,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Badge + Heart
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isEven
                        ? const Color(0xFFE11D48)
                        : const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isEven ? '-11%' : 'On Sale',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.favorite_border_rounded,
                    size: 18, color: Color(0xFFE11D48)),
              ],
            ),

            // Product Image
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: imgUrl.isNotEmpty && imgUrl.startsWith('http')
                      ? Image.network(imgUrl, fit: BoxFit.contain)
                      : const Icon(Icons.shopping_bag_outlined,
                          size: 48, color: Colors.grey),
                ),
              ),
            ),

            // Title
            Text(
              relProd.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 4),

            // Price + Stars + Circular (+) Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '৳${relProd.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '৳${(relProd.price * 1.15).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: List.generate(
                        5,
                        (_) => const Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    store.addToCart(relProd);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${relProd.name} কার্টে যুক্ত হয়েছে!'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(_ReviewItem rev, String thumbUrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: rev.avatarColor.withOpacity(0.15),
          child: Icon(Icons.person_rounded, color: rev.avatarColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < rev.rating
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rev.comment,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${rev.authorName} - ${rev.dateText}',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                ),
              ),
              if (rev.hasThumbnails &&
                  thumbUrl.isNotEmpty &&
                  thumbUrl.startsWith('http')) ...[
                const SizedBox(height: 8),
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Image.network(thumbUrl, fit: BoxFit.contain),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewItem {
  final String authorName;
  final String dateText;
  final String comment;
  final int rating;
  final Color avatarColor;
  final bool hasThumbnails;

  const _ReviewItem({
    required this.authorName,
    required this.dateText,
    required this.comment,
    required this.rating,
    required this.avatarColor,
    this.hasThumbnails = false,
  });
}
