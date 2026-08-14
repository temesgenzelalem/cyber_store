import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/providers.dart';
import '../theme/app_theme.dart';
import '../utils/app_strings.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// ─────────────────────────────────────────────────────────────────────────────
//  Cyber AppBar
// ─────────────────────────────────────────────────────────────────────────────

class CyberAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showSearch;
  final bool showBack;
  const CyberAppBar({super.key, this.showSearch = true, this.showBack = false});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: AppTheme.white.withOpacity(0.8),
            elevation: 0,
            automaticallyImplyLeading: showBack,
            title: const Text('cyber',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
                fontStyle: FontStyle.normal,
              ),
            ),
            actions: [
              if (showSearch)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => showSearch_(context),
                ),
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSearch_(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SearchSheet(),
    );
  }
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet();
  @override State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _ctrl = TextEditingController();
  final _stt = stt.SpeechToText();
  bool _isListening = false;

  @override
  Widget build(BuildContext ctx) => Container(
    decoration: const BoxDecoration(
      color: AppTheme.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    padding: EdgeInsets.only(
      left: 16, right: 16, top: 16,
      bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
    ),
    child: Row(children: [
      Expanded(
        child: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppStrings.tr(ctx, 'Search'),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : AppTheme.black),
              onPressed: _toggleListening,
            ),
          ),
          onSubmitted: (q) {
            Navigator.pop(ctx);
            ctx.go('/products?q=$q');
          },
        ),
      ),
      const SizedBox(width: 8),
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
    ]),
  );

  void _toggleListening() async {
    if (!_isListening) {
      bool available = await _stt.initialize(
        onStatus: (val) { if (val == 'done' || val == 'notListening') setState(() => _isListening = false); },
        onError: (val) => print('STT Error: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _stt.listen(
          onResult: (val) => setState(() {
            _ctrl.text = val.recognizedWords;
          }),
          localeId: 'am_ET', // Explicitly support Amharic
        );
      }
    } else {
      setState(() => _isListening = false);
      _stt.stop();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Product Card  (matches Figma grid card exactly)
// ─────────────────────────────────────────────────────────────────────────────

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final wishlist  = context.watch<WishlistProvider>();
    final isWished  = wishlist.isWishlisted(product.id);

    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Wishlist
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Hero(
                      tag: 'product_${product.id}',
                      child: product.images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.images[0],
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: AppTheme.grey100),
                              errorWidget: (_, __, ___) => _imgPlaceholder(),
                            )
                          : _imgPlaceholder(),
                    ),
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      if (!auth.isSignedIn) { context.push('/login'); return; }
                      await wishlist.toggle(product.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWished ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isWished ? Colors.red : AppTheme.grey400,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.grey400,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _BuyButton(product: product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    color: AppTheme.grey100,
    child: const Center(child: Icon(Icons.image_outlined, color: AppTheme.grey400, size: 40)),
  );
}

class _BuyButton extends StatelessWidget {
  final ProductModel product;
  const _BuyButton({required this.product});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();

    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.black,
          foregroundColor: AppTheme.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          if (!auth.isSignedIn) {
            context.push('/login');
            return;
          }
          await cart.add(product: product);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to cart'), duration: Duration(seconds: 1)),
            );
          }
        },
        child: Text(AppStrings.tr(context, 'Buy Now')),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Section Header
// ─────────────────────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(actionLabel!, style: const TextStyle(color: AppTheme.grey600, fontSize: 13)),
          ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Category Chip / Tile
// ─────────────────────────────────────────────────────────────────────────────

class CategoryTile extends StatelessWidget {
  final CategoryModel category;
  const CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.go('/products?category=${category.name}'),
    child: Column(
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppTheme.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: category.icon.startsWith('http')
              ? CachedNetworkImage(imageUrl: category.icon, fit: BoxFit.contain)
              : Icon(_categoryIcon(category.name), size: 28, color: AppTheme.black),
        ),
        const SizedBox(height: 6),
        Text(
          category.name,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );

  IconData _categoryIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('phone'))   return Icons.smartphone;
    if (n.contains('watch'))   return Icons.watch;
    if (n.contains('camera'))  return Icons.camera_alt_outlined;
    if (n.contains('headph') || n.contains('audio')) return Icons.headphones;
    if (n.contains('laptop') || n.contains('comput')) return Icons.laptop;
    if (n.contains('gaming'))  return Icons.sports_esports_outlined;
    if (n.contains('tablet'))  return Icons.tablet_outlined;
    return Icons.devices_other_outlined;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Cyber Footer
// ─────────────────────────────────────────────────────────────────────────────

class CyberFooter extends StatelessWidget {
  const CyberFooter({super.key});

  @override
  Widget build(BuildContext context) => Container(
    color: AppTheme.black,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('cyber',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 22,
            fontWeight: FontWeight.w200,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'We are a residential interior design firm located in Portland. Our boutique-studio offers more than',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.grey400, fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 24),
        _footerSection('Services', [
          'Bonus program', 'Gift cards', 'Credit and payment',
          'Service contracts', 'Non-cash account', 'Payment',
        ]),
        const SizedBox(height: 20),
        _footerSection('Assistance to the buyer', [
          'Find an order', 'Terms of delivery', 'Exchange and return of goods',
          'Guarantee', 'Frequently asked questions', 'Terms of use of the site',
        ]),
        const SizedBox(height: 24),
        // Social icons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon('𝕏'),
            _socialIcon('f'),
            _socialIcon('♪'),
            _socialIcon('◎'),
          ],
        ),
      ],
    ),
  );

  Widget _footerSection(String title, List<String> items) => Column(
    children: [
      Text(title, style: const TextStyle(
        color: AppTheme.white, fontSize: 13, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      ...items.map((i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(i, style: const TextStyle(color: AppTheme.grey400, fontSize: 12)),
      )),
    ],
  );

  Widget _socialIcon(String label) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 8),
    width: 36, height: 36,
    decoration: BoxDecoration(
      border: Border.all(color: AppTheme.grey600),
      shape: BoxShape.circle,
    ),
    child: Center(child: Text(label, style: const TextStyle(color: AppTheme.white, fontSize: 14))),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Checkout Step Indicator
// ─────────────────────────────────────────────────────────────────────────────

class CheckoutStepper extends StatelessWidget {
  final int currentStep; // 1, 2, or 3
  const CheckoutStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (icon: Icons.location_on, label: 'Address'),
      (icon: Icons.local_shipping_outlined, label: 'Shipping'),
      (icon: Icons.payment_outlined, label: 'Payment'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(steps.length, (i) {
          final step     = i + 1;
          final done     = step < currentStep;
          final active   = step == currentStep;
          final color    = (done || active) ? AppTheme.black : AppTheme.grey400;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: active ? AppTheme.black : (done ? AppTheme.black : AppTheme.grey200),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(steps[i].icon, size: 16,
                        color: (active || done) ? AppTheme.white : AppTheme.grey400),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Step $step\n${steps[i].label}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                        color: color,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 1, margin: const EdgeInsets.only(bottom: 28),
                      color: done ? AppTheme.black : AppTheme.grey200,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
