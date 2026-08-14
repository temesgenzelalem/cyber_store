import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class AdminProductList extends StatefulWidget {
  const AdminProductList({super.key});

  @override
  State<AdminProductList> createState() => _AdminProductListState();
}

class _AdminProductListState extends State<AdminProductList> {
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _productsFuture = context.read<ApiService>().getProducts(perPage: 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Products')),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.black));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final p = products[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: p.images.isNotEmpty
                    ? Image.network(p.images.first, width: 50, height: 50, fit: BoxFit.cover)
                    : Container(width: 50, height: 50, color: AppTheme.grey100),
                title: Text(p.name, style: Theme.of(context).textTheme.titleLarge),
                subtitle: Text('\$${p.price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => context.push('/admin/products/edit', extra: p).then((_) => _refresh()),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(p),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.black,
        foregroundColor: AppTheme.white,
        child: const Icon(Icons.add),
        onPressed: () => context.push('/admin/products/add').then((_) => _refresh()),
      ),
    );
  }

  void _confirmDelete(ProductModel p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${p.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<AdminProductProvider>().deleteProduct(p.id);
                _refresh();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
