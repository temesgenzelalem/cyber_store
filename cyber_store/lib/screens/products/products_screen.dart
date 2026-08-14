import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import 'package:shimmer/shimmer.dart';

class ProductsScreen extends StatefulWidget {
  final String? category;
  final String? query;
  const ProductsScreen({super.key, this.category, this.query});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final List<ProductModel> _products = [];
  int     _page       = 1;
  int     _total      = 0;
  bool    _loading    = false;
  bool    _hasMore    = true;
  ProductFilter _filter = const ProductFilter();
  String _sortLabel   = 'By rating';

  static const _perPage = 8;

  @override
  void initState() {
    super.initState();
    _loadProducts(reset: true);
  }

  Future<void> _loadProducts({bool reset = false}) async {
    if (_loading) return;
    if (reset) { _products.clear(); _page = 1; _hasMore = true; }
    if (!_hasMore) return;

    setState(() => _loading = true);
    final svc      = context.read<ApiService>();
    final newItems = await svc.getProducts(
      category: widget.category,
      filter:   _filter,
      page:     _page,
      perPage:  _perPage,
    );

    if (reset) {
      // In a real implementation with Laravel, the API might return the total count
      // For now, we'll estimate or ignore for this migration step
      _total = newItems.length;
    }

    setState(() {
      _products.addAll(newItems);
      _hasMore  = newItems.length == _perPage;
      _page++;
      _loading  = false;
    });
  }

  void _openFilters() async {
    final result = await context.push<ProductFilter>('/filters', extra: _filter);
    if (result != null && mounted) {
      setState(() => _filter = result);
      _loadProducts(reset: true);
    }
  }

  void _changeSortBy(String sort, String label) {
    setState(() {
      _filter    = _filter.copyWith(sortBy: sort);
      _sortLabel = label;
    });
    _loadProducts(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(),
      endDrawer: _buildEndDrawer(context),
      body: Column(
        children: [
          // ── Filter / Sort Bar ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Filter button
                GestureDetector(
                  onTap: _openFilters,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.grey200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      const Text('Filters', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 6),
                      const Icon(Icons.tune, size: 16),
                      if (_filter.hasFilters) ...[
                        const SizedBox(width: 4),
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.black, shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ]),
                  ),
                ),
                const SizedBox(width: 12),
                // Sort dropdown
                Expanded(
                  child: GestureDetector(
                    onTap: _showSortSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.grey200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_sortLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          const Icon(Icons.keyboard_arrow_down, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Result count ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Products Result : $_total',
                style: const TextStyle(fontSize: 13, color: AppTheme.grey600),
              ),
            ),
          ),

          // ── Product Grid ───────────────────────────────────────────────
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                  _loadProducts();
                }
                return false;
              },
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.68,
                  crossAxisSpacing: 12, mainAxisSpacing: 12,
                ),
                itemCount: _products.length + (_loading ? 2 : 0),
                itemBuilder: (_, i) {
                  if (i >= _products.length) return _shimmer();
                  return ProductCard(product: _products[i]);
                },
              ),
            ),
          ),

          // ── Pagination Bar ─────────────────────────────────────────────
          if (_total > _perPage) _buildPaginationBar(),

          const CyberFooter(),
        ],
      ),
    );
  }

  Widget _buildPaginationBar() {
    final totalPages = (_total / _perPage).ceil();
    final currentPage = _page - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1 ? () {
              setState(() { _page = currentPage - 1; _products.clear(); });
              _loadProducts();
            } : null,
          ),
          ...List.generate(totalPages.clamp(0, 5), (i) {
            final p = i + 1;
            return GestureDetector(
              onTap: () {
                setState(() { _page = p; _products.clear(); });
                _loadProducts();
              },
              child: Container(
                width: 32, height: 32,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: p == currentPage ? AppTheme.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text('$p',
                    style: TextStyle(
                      color: p == currentPage ? AppTheme.white : AppTheme.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
          if (totalPages > 5) ...[
            const Text('….'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('$totalPages', style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _hasMore ? () {
              _loadProducts();
            } : null,
          ),
        ],
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sort By', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...[
              ('rating',     'By rating'),
              ('newest',     'Newest'),
              ('price_asc',  'Price: Low to High'),
              ('price_desc', 'Price: High to Low'),
            ].map((e) => ListTile(
              title: Text(e.$2),
              trailing: _filter.sortBy == e.$1 ? const Icon(Icons.check) : null,
              onTap: () {
                Navigator.pop(context);
                _changeSortBy(e.$1, e.$2);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEndDrawer(BuildContext ctx) => Drawer(
    child: SafeArea(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text('cyber', style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
        ),
        const Divider(),
        ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Home'), onTap: () => ctx.go('/')),
        ListTile(leading: const Icon(Icons.shopping_cart_outlined), title: const Text('Cart'), onTap: () => ctx.go('/cart')),
      ],
    )),
  );

  Widget _shimmer() => Shimmer.fromColors(
    baseColor: AppTheme.grey100,
    highlightColor: AppTheme.white,
    child: Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
