import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';

class AdminCouponListScreen extends StatefulWidget {
  const AdminCouponListScreen({super.key});

  @override
  State<AdminCouponListScreen> createState() => _AdminCouponListScreenState();
}

class _AdminCouponListScreenState extends State<AdminCouponListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminCouponProvider>().fetchCoupons());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCouponProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Coupons')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.coupons.length,
              itemBuilder: (context, index) {
                final coupon = provider.coupons[index];
                return _buildCouponCard(coupon);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCouponDialog(),
        backgroundColor: AppTheme.black,
        child: const Icon(Icons.add, color: AppTheme.white),
      ),
    );
  }

  Widget _buildCouponCard(CouponModel coupon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.grey200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                coupon.code,
                style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            Text(
              coupon.type == 'percent' ? '${coupon.value}% OFF' : '\$${coupon.value} OFF',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text('Min order: \$${coupon.minOrderValue}'),
            if (coupon.expiresAt != null)
              Text('Expires: ${DateFormat('MMM dd, yyyy').format(coupon.expiresAt!)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _confirmDelete(coupon.id),
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coupon?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              context.read<AdminCouponProvider>().deleteCoupon(id);
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddCouponDialog() {
    final codeCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final minCtrl = TextEditingController();
    String type = 'percent';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add New Coupon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Coupon Code')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'percent', child: Text('Percentage (%)')),
                  DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount (\$)')),
                ],
                onChanged: (v) => setModalState(() => type = v!),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: valueCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Value'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Min Order'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await context.read<AdminCouponProvider>().addCoupon({
                    'code': codeCtrl.text,
                    'type': type,
                    'value': double.tryParse(valueCtrl.text) ?? 0,
                    'min_order_value': double.tryParse(minCtrl.text) ?? 0,
                  });
                  Navigator.pop(context);
                },
                child: const Text('CREATE COUPON'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
