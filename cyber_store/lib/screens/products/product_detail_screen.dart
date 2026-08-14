import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final String id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  bool          _loadingProduct = true;
  int           _imageIndex     = 0;
  String?       _selectedColor;
  String?       _selectedStorage;
  bool          _specExpanded   = false;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    final svc = context.read<ApiService>();
    final p   = await svc.getProduct(widget.id);
    if (mounted) setState(() { _product = p; _loadingProduct = false; });
    if (p != null) {
      _selectedColor   = p.colors.isNotEmpty   ? p.colors[0]   : null;
      _selectedStorage = p.storageOptions.isNotEmpty ? p.storageOptions[0] : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProduct) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Product not found')),
      );
    }
    final p = _product!;
    final wishlist = context.watch<WishlistProvider>();
    final auth     = context.watch<AuthProvider>();

    // Check availability for selected variant
    bool isAvailable = p.inStock;
    if (p.variants.isNotEmpty) {
      final variant = p.variants.firstWhere(
        (v) => (v.color == _selectedColor || v.color == null) &&
               (v.storage == _selectedStorage || v.storage == null),
        orElse: () => ProductVariantModel(id: '', stock: 0),
      );
      isAvailable = variant.stock > 0;
    }

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        slivers: [
          // ── Image Gallery ───────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: AppTheme.white,
            foregroundColor: AppTheme.black,
            actions: [
              IconButton(
                icon: Icon(
                  wishlist.isWishlisted(p.id) ? Icons.favorite : Icons.favorite_border,
                  color: wishlist.isWishlisted(p.id) ? Colors.red : AppTheme.black,
                ),
                onPressed: () async {
                  if (!auth.isSignedIn) { context.push('/login'); return; }
                  await wishlist.toggle(p.id);
                },
              ),
              IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(p),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Name & Availability ─────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Text(p.name, style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700, height: 1.2)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isAvailable ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                color: isAvailable ? Colors.green : Colors.red,
                                fontSize: 11, fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ── Price ─────────────────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('\$${p.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                          if (p.originalPrice != null) ...[
                            const SizedBox(width: 8),
                            Text('\$${p.originalPrice!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16, color: AppTheme.grey400,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ── Color Selection ───────────────────────────────────
                      if (p.colors.isNotEmpty) ...[
                        const Text('Select colors', style: TextStyle(fontSize: 13, color: AppTheme.grey600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: p.colors.map((c) {
                            final selected = _selectedColor == c;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColor = c),
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: _colorFromName(c),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected ? AppTheme.black : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4, offset: const Offset(0, 1)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── Storage Selection ─────────────────────────────────
                      if (p.storageOptions.isNotEmpty) ...[
                        const Text('Select storage', style: TextStyle(fontSize: 13, color: AppTheme.grey600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: p.storageOptions.map((s) {
                            final selected = _selectedStorage == s;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedStorage = s),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected ? AppTheme.black : AppTheme.white,
                                  border: Border.all(
                                    color: selected ? AppTheme.black : AppTheme.grey200),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(s, style: TextStyle(
                                  color: selected ? AppTheme.white : AppTheme.black,
                                  fontSize: 13, fontWeight: FontWeight.w500,
                                )),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── Delivery Info ─────────────────────────────────────
                      _DeliveryRow(
                        icon: Icons.local_shipping_outlined,
                        label: 'Free Delivery',
                        sub: '1-5 days',
                      ),
                      _DeliveryRow(icon: Icons.inventory_2_outlined, label: 'In Stock', sub: 'Today'),
                      _DeliveryRow(icon: Icons.refresh_outlined, label: 'Guaranteed', sub: '1 year'),

                      const SizedBox(height: 16),

                      // ── Action Buttons ────────────────────────────────────
                      if (p.arModelUrl != null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/products/ar', extra: p.arModelUrl),
                            icon: const Icon(Icons.view_in_ar),
                            label: const Text('View in Room'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.black,
                              side: const BorderSide(color: AppTheme.black),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _addToWishlist(context, auth, wishlist, p),
                            icon: const Icon(Icons.favorite_border, size: 18),
                            label: const Text('Add to Wishlist'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isAvailable ? () => _addToCart(context, auth, p) : null,
                            child: const Text('Add to Cart'),
                          ),
                        ),
                      ]),

                      const SizedBox(height: 20),
                      const Divider(),

                      // ── Details / Specs ───────────────────────────────────
                      GestureDetector(
                        onTap: () => setState(() => _specExpanded = !_specExpanded),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            Icon(_specExpanded ? Icons.expand_less : Icons.expand_more),
                          ],
                        ),
                      ),
                      if (_specExpanded) _buildSpecs(p),

                      const SizedBox(height: 16),
                      const Divider(),
                    ],
                  ),
                ),

                // ── Reviews ─────────────────────────────────────────────────
                _ReviewsSection(productId: p.id, rating: p.rating, reviewCount: p.reviewCount),

                // ── Frequently Bought Together ───────────────────────────────
                _FrequentlyBoughtTogether(productId: p.id),

                const SizedBox(height: 24),

                // ── Related Products ─────────────────────────────────────────
                _RelatedProducts(category: p.category, excludeId: p.id),

                const SizedBox(height: 32),
                const CyberFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Image Gallery ──────────────────────────────────────────────────────────

  Widget _buildImageGallery(ProductModel p) => Container(
    color: AppTheme.grey100,
    child: Column(
      children: [
        Expanded(
          child: p.images.isNotEmpty
              ? PageView.builder(
                  itemCount: p.images.length,
                  onPageChanged: (i) => setState(() => _imageIndex = i),
          itemBuilder: (_, i) => Hero(
                    tag: i == 0 ? 'product_${p.id}' : 'product_img_${p.id}_$i',
                    child: CachedNetworkImage(
                      imageUrl: p.images[i], fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                )
              : const Center(child: Icon(Icons.image_outlined, size: 80, color: AppTheme.grey400)),
        ),
        if (p.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(p.images.length, (i) => Container(
                width: 6, height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _imageIndex == i ? AppTheme.black : AppTheme.grey400,
                ),
              )),
            ),
          ),
      ],
    ),
  );

  // ── Specs ──────────────────────────────────────────────────────────────────

  Widget _buildSpecs(ProductModel p) {
    final specs = p.specs;
    if (specs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: specs.entries.map((e) => _SpecRow(
          label: e.key.replaceAll('_', ' ').toUpperCase(),
          value: e.value.toString(),
        )).toList(),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color _colorFromName(String name) {
    final n = name.toLowerCase();
    if (n.contains('black') || n.contains('space'))   return const Color(0xFF1A1A2E);
    if (n.contains('gold'))   return const Color(0xFFFFD700);
    if (n.contains('silver') || n.contains('white'))  return const Color(0xFFE8E8E8);
    if (n.contains('blue'))   return const Color(0xFF4A90D9);
    if (n.contains('purple')) return const Color(0xFF6B4EBB);
    if (n.contains('red'))    return const Color(0xFFD32F2F);
    if (n.contains('green'))  return const Color(0xFF388E3C);
    if (n.contains('pink'))   return const Color(0xFFE91E8C);
    return AppTheme.grey400;
  }

  void _addToCart(BuildContext ctx, AuthProvider auth, ProductModel p) async {
    if (!auth.isSignedIn) { ctx.push('/login'); return; }
    await ctx.read<CartProvider>().add(
      product: p,
      color: _selectedColor, storage: _selectedStorage,
    );
    if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(content: Text('Added to cart!'), duration: Duration(seconds: 1)),
    );
  }

  void _addToWishlist(BuildContext ctx, AuthProvider auth, WishlistProvider w, ProductModel p) async {
    if (!auth.isSignedIn) { ctx.push('/login'); return; }
    await w.toggle(p.id);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DeliveryRow extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  const _DeliveryRow({required this.icon, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 18, color: AppTheme.grey600),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(width: 4),
      Text(sub, style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
    ]),
  );
}

class _SpecRow extends StatelessWidget {
  final String label, value;
  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
          child: Text(label, style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.grey600)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Reviews Section
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewsSection extends StatelessWidget {
  final String productId;
  final double rating;
  final int    reviewCount;
  const _ReviewsSection({required this.productId, required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    final svc = context.read<ApiService>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating summary
          Row(children: [
            Text(rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RatingBarIndicator(
                  rating: rating,
                  itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.accent),
                  itemSize: 20,
                  itemCount: 5,
                ),
                Text('$reviewCount reviews',
                  style: const TextStyle(color: AppTheme.grey600, fontSize: 12)),
              ],
            ),
          ]),
          const SizedBox(height: 16),
          ...[('Excellent', 0.7), ('Good', 0.2), ('Average', 0.06), ('Poor', 0.04)]
              .map((e) => _RatingBar(label: e.$1, fraction: e.$2)),
          const SizedBox(height: 20),
          const Text('Reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          FutureBuilder<List<ReviewModel>>(
            future: svc.getReviews(productId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Reviews loading...', style: TextStyle(color: AppTheme.grey600));
              }
              final reviews = snapshot.data ?? [];
              if (reviews.isEmpty) {
                return const Text('No reviews yet.', style: TextStyle(color: AppTheme.grey600));
              }
              return Column(
                children: reviews.map((r) => _ReviewCard(review: r)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final String label;
  final double fraction;
  const _RatingBar({required this.label, required this.fraction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12))),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction, minHeight: 6,
            backgroundColor: AppTheme.grey200,
            color: AppTheme.black,
          ),
        ),
      ),
    ]),
  );
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          CircleAvatar(
            radius: 18, backgroundColor: AppTheme.grey200,
            backgroundImage: review.userAvatar.isNotEmpty
                ? CachedNetworkImageProvider(review.userAvatar) : null,
            child: review.userAvatar.isEmpty
                ? Text(review.userName[0], style: const TextStyle(fontWeight: FontWeight.w700))
                : null,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              RatingBarIndicator(
                rating: review.rating,
                itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.accent),
                itemSize: 14, itemCount: 5,
              ),
            ],
          ),
          const Spacer(),
          Text(DateFormat('MMM d, y').format(review.createdAt),
            style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
        ]),
        const SizedBox(height: 8),
        Text(review.comment, style: const TextStyle(fontSize: 13, height: 1.5)),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Frequently Bought Together
// ─────────────────────────────────────────────────────────────────────────────

class _FrequentlyBoughtTogether extends StatelessWidget {
  final String productId;
  const _FrequentlyBoughtTogether({required this.productId});

  @override
  Widget build(BuildContext context) {
    final svc = context.read<ApiService>();
    return FutureBuilder<List<ProductModel>>(
      future: svc.getFrequentlyBoughtTogether(productId),
      builder: (context, snapshot) {
        final products = snapshot.data ?? [];
        if (products.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Frequently Bought Together',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => SizedBox(
                  width: 160,
                  child: ProductCard(product: products[index]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Related Products
// ─────────────────────────────────────────────────────────────────────────────

class _RelatedProducts extends StatelessWidget {
  final String category, excludeId;
  const _RelatedProducts({required this.category, required this.excludeId});

  @override
  Widget build(BuildContext context) {
    final svc = context.read<ApiService>();
    return FutureBuilder<List<ProductModel>>(
      future: svc.getRelatedProducts(excludeId),
      builder: (context, snapshot) {
        final products = snapshot.data ?? [];
        if (products.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Related Products',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => SizedBox(
                  width: 160,
                  child: ProductCard(product: products[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
