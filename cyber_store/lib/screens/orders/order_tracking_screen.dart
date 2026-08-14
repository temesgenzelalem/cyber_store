import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _loading = true;
  Map<String, dynamic>? _order;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final svc = context.read<ApiService>();
    final orders = await svc.getOrders();
    final order = orders.firstWhere(
      (o) => o['id'].toString() == widget.orderId,
      orElse: () => {},
    );
    setState(() {
      _order = order.isEmpty ? null : order;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Order not found'))
              : _buildTimeline(),
    );
  }

  Widget _buildTimeline() {
    final steps = List<Map<String, dynamic>>.from(_order!['tracking_steps'] ?? []);
    if (steps.isEmpty) {
      return const Center(child: Text('No tracking info available yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        final isFirst = index == 0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isFirst ? AppTheme.black : AppTheme.grey400,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    color: AppTheme.grey200,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['status'] ?? 'Updated',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isFirst ? FontWeight.w700 : FontWeight.w600,
                      color: isFirst ? AppTheme.black : AppTheme.grey600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['message'] ?? '',
                    style: TextStyle(fontSize: 14, color: AppTheme.grey600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['time'] != null
                        ? DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.parse(step['time']))
                        : '',
                    style: TextStyle(fontSize: 12, color: AppTheme.grey400),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
