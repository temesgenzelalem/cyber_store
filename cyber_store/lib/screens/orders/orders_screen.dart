import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final svc  = context.read<ApiService>();

    return Scaffold(
      backgroundColor: AppTheme.grey100,
      appBar: AppBar(
        backgroundColor: AppTheme.white, elevation: 0,
        title: const Text('Order History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: !auth.isSignedIn
          ? _notSignedIn(context)
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: svc.getOrders(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snap.data ?? [];
                if (orders.isEmpty) return _empty(context);
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _OrderCard(order: orders[i]),
                );
              },
            ),
    );
  }

  Widget _notSignedIn(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.lock_outline, size: 60, color: AppTheme.grey400),
      const SizedBox(height: 16),
      const Text('Sign in to view orders',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () => context.push('/login'),
        style: ElevatedButton.styleFrom(minimumSize: const Size(180, 46)),
        child: const Text('Sign In'),
      ),
    ]),
  );

  Widget _empty(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.receipt_long_outlined, size: 72, color: AppTheme.grey400),
      const SizedBox(height: 16),
      const Text('No orders yet', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      const Text('Your completed orders will appear here',
        style: TextStyle(color: AppTheme.grey600)),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () => context.go('/products'),
        style: ElevatedButton.styleFrom(minimumSize: const Size(180, 46)),
        child: const Text('Start Shopping'),
      ),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final items    = List<Map<String, dynamic>>.from(order['items'] ?? []);
    final total    = (order['total'] as num?)?.toDouble() ?? 0;
    final status   = (order['status'] as String? ?? 'pending');
    final orderId  = (order['id'] as String? ?? '').take(12).join();
    final createdAt = order['created_at'];

    String dateStr = '';
    if (createdAt != null) {
      try {
        final dt = DateTime.parse(createdAt.toString());
        dateStr = DateFormat('MMM d, y').format(dt);
      } catch (_) {}
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${order['id'].toString().substring(0, 8).toUpperCase()}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                _StatusBadge(status: status),
              ],
            ),
            if (dateStr.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(dateStr, style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
            ],
            const Divider(height: 16),

            // Items preview
            ...items.take(2).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Container(
                  width: 40, height: 40, margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, size: 20, color: AppTheme.grey400),
                ),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item['name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    Text('Qty: ${item['qty']} · \$${(item['price'] as num).toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
                  ]),
                ),
              ]),
            )),

            if (items.length > 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('+${items.length - 2} more items',
                  style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
              ),

            const Divider(height: 16),

            // Total + reorder
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Total', style: TextStyle(fontSize: 11, color: AppTheme.grey600)),
                  Text('\$${total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ]),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(110, 38),
                    backgroundColor: AppTheme.black,
                  ),
                  child: const Text('Reorder', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final map = {
      'pending':   (Colors.orange.shade50, Colors.orange.shade700),
      'confirmed': (Colors.blue.shade50,   Colors.blue.shade700),
      'shipped':   (Colors.purple.shade50, Colors.purple.shade700),
      'delivered': (Colors.green.shade50,  Colors.green.shade700),
      'cancelled': (Colors.red.shade50,    Colors.red.shade700),
    };
    final colors = map[status] ?? (AppTheme.grey100, AppTheme.grey600);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: colors.$1, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.$2),
      ),
    );
  }
}

extension on String {
  Iterable<String> take(int n) sync* {
    int i = 0;
    for (final c in split('')) {
      if (i++ >= n) break;
      yield c;
    }
  }
}
