import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<ProductModel> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isSignedIn) { setState(() => _loading = false); return; }

    final svc       = context.read<ApiService>();
    final ids       = await svc.getWishlist();
    final products  = <ProductModel>[];
    for (final id in ids) {
      final p = await svc.getProduct(id);
      if (p != null) products.add(p);
    }
    if (mounted) setState(() { _products = products; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        title: const Text('Wishlist',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.black)),
      ),
      body: !auth.isSignedIn
          ? _guestState(context)
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
                  ? _emptyState(context)
                  : _buildList(context),
    );
  }

  Widget _guestState(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.favorite_border, size: 72, color: AppTheme.grey400),
        const SizedBox(height: 16),
        const Text('Sign in to see your wishlist',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('Save your favourite products here',
          style: TextStyle(color: AppTheme.grey600), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => context.push('/login'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
          child: const Text('Sign In'),
        ),
      ]),
    ),
  );

  Widget _emptyState(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.favorite_border, size: 72, color: AppTheme.grey400),
      const SizedBox(height: 16),
      const Text('Your wishlist is empty',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      const Text('Tap the heart on any product to save it here',
        style: TextStyle(color: AppTheme.grey600), textAlign: TextAlign.center),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () => context.go('/products'),
        style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
        child: const Text('Browse Products'),
      ),
    ]),
  );

  Widget _buildList(BuildContext context) {
    final auth     = context.watch<AuthProvider>();
    final cart     = context.read<CartProvider>();
    final wishlist = context.read<WishlistProvider>();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final p = _products[i];
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              // Image
              GestureDetector(
                onTap: () => context.push('/products/${p.id}'),
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  child: SizedBox(
                    width: 100, height: 100,
                    child: p.images.isNotEmpty
                        ? CachedNetworkImage(imageUrl: p.images[0], fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: AppTheme.grey100))
                        : Container(color: AppTheme.grey100,
                            child: const Icon(Icons.image_outlined, color: AppTheme.grey400)),
                  ),
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('\$${p.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (!auth.isSignedIn) return;
                              await cart.add(product: p);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Added to cart!'), duration: Duration(seconds: 1)));
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.black, borderRadius: BorderRadius.circular(6)),
                              child: const Center(
                                child: Text('Add to Cart',
                                  style: TextStyle(color: AppTheme.white, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            if (!auth.isSignedIn) return;
                            await wishlist.toggle(p.id);
                            setState(() => _products.removeWhere((prod) => prod.id == p.id));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.grey200),
                              borderRadius: BorderRadius.circular(6)),
                            child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
