import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  late ProductFilter _filter;

  // Expanded state of each accordion
  final Map<String, bool> _expanded = {
    'price':      true,
    'brand':      true,
    'memory':     true,
    'protection': false,
    'screen_diag':false,
    'screen_type':false,
    'battery':    false,
  };

  RangeValues _priceRange = const RangeValues(0, 2000);
  String _brandSearch  = '';
  String _memorySearch = '';

  final List<_BrandOption> _brands = [
    _BrandOption('Apple',   110),
    _BrandOption('Samsung', 125),
    _BrandOption('Xiaomi',   68),
    _BrandOption('Poco',     44),
    _BrandOption('OPPO',     36),
    _BrandOption('Honor',    10),
    _BrandOption('Motorola', 34),
    _BrandOption('Nokia',    22),
    _BrandOption('Realme',   35),
  ];

  final List<_MemOption> _memories = [
    _MemOption('16GB',  65),
    _MemOption('32GB',  123),
    _MemOption('64GB',  48),
    _MemOption('128GB', 50),
    _MemOption('256GB', 24),
    _MemOption('512GB', 8),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    _filter = (extra is ProductFilter) ? extra : const ProductFilter();
    _priceRange = RangeValues(
      _filter.minPrice ?? 0,
      _filter.maxPrice ?? 2000,
    );
    for (final b in _brands)  b.checked = _filter.brands.contains(b.name);
    for (final m in _memories) m.checked = _filter.memories.contains(m.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _accordion('price',       'Price',             _buildPriceSection()),
          _accordion('brand',       'Brand',             _buildBrandSection()),
          _accordion('memory',      'Built-in memory',   _buildMemorySection()),
          _accordion('protection',  'Protection class',  _buildSimpleSection('No options available')),
          _accordion('screen_diag', 'Screen diagonal',   _buildSimpleSection('No options available')),
          _accordion('screen_type', 'Screen type',       _buildSimpleSection('No options available')),
          _accordion('battery',     'Battery capacity',  _buildSimpleSection('No options available')),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: _applyFilters,
            child: const Text('Apply'),
          ),
        ),
      ),
    );
  }

  // ── Accordion ─────────────────────────────────────────────────────────────

  Widget _accordion(String key, String title, Widget child) {
    final open = _expanded[key] ?? false;
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded[key] = !open),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Icon(open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
        if (open) Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: child,
        ),
        const Divider(height: 1),
      ],
    );
  }

  // ── Price Section ─────────────────────────────────────────────────────────

  Widget _buildPriceSection() => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _priceField(
              'From', _priceRange.start.toInt().toString(),
              (v) {
                final val = double.tryParse(v);
                if (val != null) setState(() => _priceRange = RangeValues(val, _priceRange.end));
              },
            ),
          ),
          Container(
            width: 20, height: 1, color: AppTheme.grey400,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: _priceField(
              'To', _priceRange.end.toInt().toString(),
              (v) {
                final val = double.tryParse(v);
                if (val != null) setState(() => _priceRange = RangeValues(_priceRange.start, val));
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      RangeSlider(
        values: _priceRange,
        min: 0, max: 2000,
        activeColor: AppTheme.black,
        inactiveColor: AppTheme.grey200,
        onChanged: (v) => setState(() => _priceRange = v),
      ),
    ],
  );

  Widget _priceField(String label, String value, ValueChanged<String> onChange) =>
      TextFormField(
        initialValue: value,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: AppTheme.grey400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.grey200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.grey200)),
        ),
        onChanged: onChange,
      );

  // ── Brand Section ─────────────────────────────────────────────────────────

  Widget _buildBrandSection() => Column(
    children: [
      // Search
      TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search, size: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.grey200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.grey200)),
        ),
        onChanged: (v) => setState(() => _brandSearch = v.toLowerCase()),
      ),
      const SizedBox(height: 8),
      ..._brands.where((b) => b.name.toLowerCase().contains(_brandSearch)).map((b) =>
        _checkRow(
          label: b.name,
          count: b.count,
          checked: b.checked,
          onChanged: (v) => setState(() => b.checked = v ?? false),
        ),
      ),
    ],
  );

  // ── Memory Section ────────────────────────────────────────────────────────

  Widget _buildMemorySection() => Column(
    children: [
      TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search, size: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.grey200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.grey200)),
        ),
        onChanged: (v) => setState(() => _memorySearch = v.toLowerCase()),
      ),
      const SizedBox(height: 8),
      ..._memories.where((m) => m.value.toLowerCase().contains(_memorySearch)).map((m) =>
        _checkRow(
          label: m.value,
          count: m.count,
          checked: m.checked,
          onChanged: (v) => setState(() => m.checked = v ?? false),
        ),
      ),
    ],
  );

  Widget _buildSimpleSection(String msg) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(msg, style: const TextStyle(color: AppTheme.grey400, fontSize: 13)),
  );

  Widget _checkRow({
    required String label,
    required int count,
    required bool checked,
    required ValueChanged<bool?> onChanged,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Checkbox(value: checked, onChanged: onChanged),
        Expanded(
          child: RichText(text: TextSpan(
            text: label,
            style: const TextStyle(color: AppTheme.black, fontSize: 14),
            children: [
              TextSpan(
                text: '  $count',
                style: const TextStyle(color: AppTheme.grey400, fontSize: 12),
              ),
            ],
          )),
        ),
      ],
    ),
  );

  // ── Apply ─────────────────────────────────────────────────────────────────

  void _applyFilters() {
    final filter = _filter.copyWith(
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end  < 2000 ? _priceRange.end : null,
      brands:   _brands.where((b) => b.checked).map((b) => b.name).toList(),
      memories: _memories.where((m) => m.checked).map((m) => m.value).toList(),
    );
    context.pop(filter);
  }
}

class _BrandOption {
  final String name;
  final int    count;
  bool         checked;
  _BrandOption(this.name, this.count, {this.checked = false});
}

class _MemOption {
  final String value;
  final int    count;
  bool         checked;
  _MemOption(this.value, this.count, {this.checked = false});
}
