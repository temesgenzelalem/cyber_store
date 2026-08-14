import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import 'package:lottie/lottie.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promoCtrl      = TextEditingController();
  final _bonusCardCtrl  = TextEditingController();
  String? _promoError;
  String? _promoSuccess;
  bool _showConfetti = false;

  @override
  void dispose() {
    _promoCtrl.dispose();
    _bonusCardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: const CyberAppBar(showSearch: false),
      body: Stack(
        children: [
          cart.items.isEmpty ? _emptyCart(context) : _buildCart(context, cart, auth),
          if (_showConfetti)
            IgnorePointer(
              child: Lottie.network(
                'https://assets5.lottiefiles.com/packages/lf20_rovf9gzu.json',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                onLoaded: (comp) {
                   Future.delayed(comp.duration, () {
                     if (mounted) setState(() => _showConfetti = false);
                   });
                }
              ),
            ),
        ],
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _emptyCart(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.shopping_cart_outlined, size: 80, color: AppTheme.grey400),
        const SizedBox(height: 16),
        const Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Add items to get started', style: TextStyle(color: AppTheme.grey600)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => context.go('/products'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
          child: const Text('Browse Products'),
        ),
      ],
    ),
  );

  // ── Full Cart ──────────────────────────────────────────────────────────────

  Widget _buildCart(BuildContext ctx, CartProvider cart, AuthProvider auth) =>
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Shopping Cart',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            ),

            // ── Cart Items ───────────────────────────────────────────────
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const Divider(indent: 16, endIndent: 16),
              itemBuilder: (_, i) => _CartItemRow(
                item: cart.items[i],
                uid: auth.user?.uid,
              ),
            ),

            const Divider(thickness: 1, height: 32),

            // ── Order Summary ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),

                  // Promo Code
                  const Text('Discount code / Promo code',
                    style: TextStyle(fontSize: 13, color: AppTheme.grey600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoCtrl,
                          decoration: InputDecoration(
                            hintText: 'Code',
                            errorText: _promoError,
                            suffixText: _promoSuccess,
                            suffixStyle: const TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _applyPromo,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(80, 52), padding: EdgeInsets.zero),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bonus Card
                  const Text('Your bonus card number',
                    style: TextStyle(fontSize: 13, color: AppTheme.grey600)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _bonusCardCtrl,
                        decoration: const InputDecoration(hintText: 'Enter Card Number'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 52), padding: EdgeInsets.zero),
                      child: const Text('Apply'),
                    ),
                  ]),
                  const SizedBox(height: 8),

                  const Divider(height: 28),

                  // Totals
                  _summaryRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _summaryRow('Estimated Tax', '\$${cart.tax.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _summaryRow(
                    'Estimated shipping & Handling',
                    cart.shipping == 0 ? 'Free' : '\$${cart.shipping.toStringAsFixed(0)}',
                  ),
                  if (cart.promoDiscount > 0) ...[
                    const SizedBox(height: 8),
                    _summaryRow('Promo (${cart.promoCode})',
                      '-\$${cart.promoDiscount.toStringAsFixed(0)}',
                      valueColor: Colors.green),
                  ],
                  const Divider(height: 20),
                  _summaryRow('Total', '\$${cart.total.toStringAsFixed(0)}',
                    bold: true, fontSize: 18),

                  const SizedBox(height: 20),

                  // Checkout Button
                  ElevatedButton(
                    onPressed: () {
                      if (!context.read<AuthProvider>().isSignedIn) {
                        context.push('/login?redirect=/checkout/address');
                        return;
                      }
                      context.push('/checkout/address');
                    },
                    child: const Text('Checkout'),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            const CyberFooter(),
          ],
        ),
      );

  Widget _summaryRow(String label, String value, {
    bool bold = false, double fontSize = 14, Color? valueColor,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        color: AppTheme.grey600,
      )),
      Text(value, style: TextStyle(
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
        color: valueColor ?? AppTheme.black,
      )),
    ],
  );

  void _applyPromo() async {
    final code = _promoCtrl.text.trim();
    if (code.isEmpty) return;

    final cart = context.read<CartProvider>();
    final api = context.read<ApiService>();

    setState(() {
      _promoError = null;
      _promoSuccess = 'Validating...';
    });

    try {
      final res = await api.validateCoupon(code, cart.subtotal);
      final discount = (res['discount'] as num).toDouble();
      cart.setPromo(code, discount);
      setState(() {
        _promoSuccess = 'Applied!';
        _showConfetti = true;
      });
    } catch (e) {
      setState(() {
        _promoError = e.toString().replaceFirst('Exception: ', '');
        _promoSuccess = null;
      });
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CartItemRow extends StatelessWidget {
  final CartItem  item;
  final String?   uid;
  const _CartItemRow({required this.item, this.uid});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 72, height: 72,
              child: item.image.isNotEmpty
                  ? CachedNetworkImage(imageUrl: item.image, fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppTheme.grey100))
                  : Container(color: AppTheme.grey100,
                      child: const Icon(Icons.image_outlined, color: AppTheme.grey400)),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('#${item.sku}', style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
                const SizedBox(height: 8),

                // Qty controls + price
                Row(
                  children: [
                    _QtyButton(icon: Icons.remove, onTap: () {
                      cart.updateQty(item.productId, item.qty - 1);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.qty}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                    _QtyButton(icon: Icons.add, onTap: () {
                      cart.updateQty(item.productId, item.qty + 1);
                    }),
                    const Spacer(),
                    Text('\$${item.subtotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),

          // Remove
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppTheme.grey400),
            padding: EdgeInsets.zero,
            onPressed: () {
              cart.remove(item.productId);
            },
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.grey200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16),
    ),
  );
}
