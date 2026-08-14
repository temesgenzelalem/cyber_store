import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminOrderProvider>();
    final orders = provider.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Orders'),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.black))
          : orders.isEmpty
              ? const Center(child: Text('No orders found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _OrderCard(order: order);
                  },
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final id = order['id'].toString();
    final dateStr = order['created_at'];
    final date = DateTime.tryParse(dateStr ?? '') ?? DateTime.now();
    final customer = order['user']?['name'] ?? 'Unknown';
    final total = (order['total'] as num).toDouble();
    final status = order['status'] ?? 'Pending';

    return Card(
      elevation: 0,
      color: AppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.grey200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/admin/orders/$id'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #$id',
                    style: AppTheme.light.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppTheme.grey600),
                  const SizedBox(width: 8),
                  Text(
                    customer,
                    style: AppTheme.light.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.grey600),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(date),
                    style: AppTheme.light.textTheme.bodySmall,
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: AppTheme.light.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: AppTheme.light.textTheme.titleLarge?.copyWith(
                      color: AppTheme.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
        color = Colors.green;
        break;
      case 'shipped':
        color = Colors.blue;
        break;
      case 'processing':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = AppTheme.grey600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
