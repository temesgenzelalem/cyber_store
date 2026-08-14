import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final String id;
  const AdminOrderDetailScreen({super.key, required this.id});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  Map<String, dynamic>? _order;
  bool _loading = true;
  String? _updatingStatus;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _loading = true);
    try {
      final api = context.read<ApiService>();
      final data = await api.adminGetOrder(widget.id);
      setState(() {
        _order = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading order: $e')),
        );
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _updatingStatus = newStatus);
    try {
      await context.read<AdminOrderProvider>().updateStatus(widget.id, newStatus);
      await _loadOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    } finally {
      setState(() => _updatingStatus = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.black)),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Order not found')),
      );
    }

    final user = _order!['user'] ?? {};
    final address = _order!['address'] ?? {};
    final items = (_order!['items'] as List?) ?? [];
    final status = _order!['status'] ?? 'Pending';

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildSection(
              title: 'Order Status',
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: _updatingStatus != null ? null : (val) {
                        if (val != null && val != status) _updateStatus(val);
                      },
                    ),
                  ),
                  if (_updatingStatus != null)
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.black),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Customer Info
            _buildSection(
              title: 'Customer Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Name', value: user['name'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Email', value: user['email'] ?? 'N/A'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Shipping Address
            _buildSection(
              title: 'Shipping Address',
              child: Text(
                '${address['street'] ?? ''}\n${address['city'] ?? ''}, ${address['state'] ?? ''} ${address['zip'] ?? ''}\nPhone: ${address['phone'] ?? 'N/A'}',
                style: AppTheme.light.textTheme.bodyMedium,
              ),
            ),

            const SizedBox(height: 16),

            // Items List
            _buildSection(
              title: 'Items (${items.length})',
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.grey100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: item['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(item['image'], fit: BoxFit.cover),
                              )
                            : const Icon(Icons.image_outlined, color: AppTheme.grey400),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] ?? 'Unknown Product',
                              style: AppTheme.light.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Qty: ${item['qty']} • \$${(item['price'] as num).toDouble().toStringAsFixed(2)}',
                              style: AppTheme.light.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '\$${((item['price'] as num) * (item['qty'] as num)).toDouble().toStringAsFixed(2)}',
                        style: AppTheme.light.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Order Summary
            _buildSection(
              title: 'Order Summary',
              child: Column(
                children: [
                  _SummaryRow(label: 'Subtotal', value: (_order!['subtotal'] as num).toDouble()),
                  const SizedBox(height: 8),
                  _SummaryRow(label: 'Shipping', value: (_order!['shipping'] as num).toDouble()),
                  const SizedBox(height: 8),
                  _SummaryRow(label: 'Tax', value: (_order!['tax'] as num).toDouble()),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: AppTheme.light.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${(_order!['total'] as num).toDouble().toStringAsFixed(2)}',
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.light.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.grey600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: AppTheme.light.textTheme.bodySmall),
        ),
        Expanded(
          child: Text(value, style: AppTheme.light.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.light.textTheme.bodyMedium),
        Text('\$${value.toStringAsFixed(2)}', style: AppTheme.light.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
