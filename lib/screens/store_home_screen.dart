// lib/screens/store_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../widgets/store_product_card.dart';
import 'cart_checkout_screen.dart';

class StoreHomeScreen extends StatelessWidget {
  const StoreHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: store.primaryColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              store.storeName,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
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
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartCheckoutScreen()),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined),
              ),
              if (store.cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${store.cartCount}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: store.initializeStore,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (store.categories.isNotEmpty) ...[
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: store.categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isAll = store.selectedCategorySlug == null;
                      return ChoiceChip(
                        label: const Text('All Items'),
                        selected: isAll,
                        selectedColor: store.primaryColor,
                        labelStyle: TextStyle(
                          color: isAll ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                        onSelected: (_) => store.filterByCategory(null),
                      );
                    }
                    final cat = store.categories[index - 1];
                    final isSelected = store.selectedCategorySlug == cat.slug;
                    return ChoiceChip(
                      label: Text('${cat.icon} ${cat.name}'),
                      selected: isSelected,
                      selectedColor: store.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                      onSelected: (_) => store.filterByCategory(cat.slug),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (store.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (store.products.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: Text('এই ক্যাটাগরিতে কোনো প্রোডাক্ট পাওয়া যায়নি।')),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: store.products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, idx) {
                  final product = store.products[idx];
                  return StoreProductCard(
                    product: product,
                    primaryColor: store.primaryColor,
                    onAddToCart: () {
                      store.addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} কার্টে যুক্ত হয়েছে!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
