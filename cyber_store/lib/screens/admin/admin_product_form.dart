import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class AdminProductForm extends StatefulWidget {
  final ProductModel? product;
  const AdminProductForm({super.key, this.product});

  @override
  State<AdminProductForm> createState() => _AdminProductFormState();
}

class _AdminProductFormState extends State<AdminProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _nameCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _oldPriceCtrl;
  late TextEditingController _skuCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _aiMagicCtrl;

  String? _selectedCategory;
  bool _featured = false;
  final List<XFile> _images = [];
  final List<Map<String, dynamic>> _variants = [];
  List<CategoryModel> _categories = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name);
    _brandCtrl = TextEditingController(text: p?.brand);
    _priceCtrl = TextEditingController(text: p?.price.toString());
    _oldPriceCtrl = TextEditingController(text: p?.originalPrice?.toString());
    _skuCtrl = TextEditingController(text: p?.sku);
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _aiMagicCtrl = TextEditingController();
    _featured = p?.featured ?? false;
    _selectedCategory = p?.category;

    if (p != null) {
      for (var v in p.variants) {
        _variants.add({
          'color': v.color,
          'storage': v.storage,
          'price': v.price,
          'stock': v.stock,
        });
      }
    }

    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final cats = await context.read<ApiService>().getCategories();
    setState(() => _categories = cats);
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => _images.addAll(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AdminProductProvider>();
    final isEdit = widget.product != null;

            Text(isEdit ? 'Edit Product' : 'Add Product', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            if (!isEdit) ...[
              _buildAiMagicFill(),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Product Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _brandCtrl,
              decoration: const InputDecoration(labelText: 'Brand'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categories.any((c) => c.name == _selectedCategory) ? _selectedCategory : null,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _oldPriceCtrl,
                    decoration: const InputDecoration(labelText: 'Original Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _skuCtrl,
              decoration: const InputDecoration(labelText: 'SKU'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(
                labelText: 'Description',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.auto_awesome, color: Colors.purple),
                  tooltip: 'Generate Description with AI',
                  onPressed: _generateDescription,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Featured Product'),
              value: _featured,
              onChanged: (v) => setState(() => _featured = v!),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),
            _buildVariantSection(),
            const SizedBox(height: 24),
            Text('Images', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            if (isEdit && widget.product!.images.isNotEmpty) ...[
              const Text('Existing Images:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.product!.images.length,
                  itemBuilder: (c, i) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(widget.product!.images[i], width: 80, height: 80, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._images.map((f) => Stack(
                  children: [
                    Image.file(File(f.path), width: 100, height: 100, fit: BoxFit.cover),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _images.remove(f)),
                        child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                )),
                InkWell(
                  onTap: _pickImages,
                  child: Container(
                    width: 100,
                    height: 100,
                    color: AppTheme.grey100,
                    child: const Icon(Icons.add_a_photo_outlined, color: AppTheme.grey600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isAdmin.loading ? null : _save,
              child: isAdmin.loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isEdit ? 'Update Product' : 'Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Inventory & Variants', style: Theme.of(context).textTheme.headlineSmall),
            TextButton.icon(
              onPressed: _addVariant,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Variant'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_variants.isEmpty)
          const Text('No variants added. Default stock is 0.', style: TextStyle(color: AppTheme.grey600, fontSize: 13)),
        ..._variants.asMap().entries.map((entry) {
          final i = entry.key;
          final v = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(child: Text('${v['color'] ?? 'N/A'} / ${v['storage'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.w600))),
                const SizedBox(width: 8),
                SizedBox(width: 60, child: Text('Qty: ${v['stock']}')),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _editVariant(i),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  onPressed: () => setState(() => _variants.removeAt(i)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _addVariant() async {
    final result = await _showVariantDialog();
    if (result != null) {
      setState(() => _variants.add(result));
    }
  }

  void _editVariant(int index) async {
    final result = await _showVariantDialog(initial: _variants[index]);
    if (result != null) {
      setState(() => _variants[index] = result);
    }
  }

  Future<Map<String, dynamic>?> _showVariantDialog({Map<String, dynamic>? initial}) {
    final colorCtrl = TextEditingController(text: initial?['color']);
    final storageCtrl = TextEditingController(text: initial?['storage']);
    final stockCtrl = TextEditingController(text: initial?['stock']?.toString() ?? '1');
    final priceCtrl = TextEditingController(text: initial?['price']?.toString());

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(initial == null ? 'Add Variant' : 'Edit Variant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: colorCtrl, decoration: const InputDecoration(labelText: 'Color')),
            TextField(controller: storageCtrl, decoration: const InputDecoration(labelText: 'Storage')),
            TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'Stock Qty'), keyboardType: TextInputType.number),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Override Price (Optional)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx, {
                'color': colorCtrl.text,
                'storage': storageCtrl.text,
                'stock': int.tryParse(stockCtrl.text) ?? 0,
                'price': double.tryParse(priceCtrl.text),
              });
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMagicFill() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_fix_high, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              const Text('AI Magic Fill', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Paste product details or specs to auto-fill the form:', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: _aiMagicCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'e.g. Sony PS5, 45000 ETB, Gaming, 1TB SSD...',
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: Colors.purple),
                onPressed: _magicFill,
              ),
            ),
            onSubmitted: (_) => _magicFill(),
          ),
        ],
      ),
    );
  }

  void _magicFill() async {
    final text = _aiMagicCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _loading = true);
    try {
      final api = context.read<ApiService>();
      final result = await api.adminAiParseProductInfo(text: text);

      setState(() {
        _nameCtrl.text = result['name'] ?? '';
        _brandCtrl.text = result['brand'] ?? '';
        _priceCtrl.text = result['price']?.toString() ?? '';
        _skuCtrl.text = result['sku'] ?? '';
        _descCtrl.text = result['description'] ?? '';
        _selectedCategory = result['category_id']?.toString();
        _loading = false;
        _aiMagicCtrl.clear();
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Magic Fill Complete!')));
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI Error: $e')));
    }
  }

  void _generateDescription() async {
    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter product name first')));
      return;
    }
    setState(() => _loading = true);
    try {
      final api = context.read<ApiService>();
      final desc = await api.adminAiGenerateDescription(_nameCtrl.text, _brandCtrl.text);
      setState(() {
        _descCtrl.text = desc;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI Error: $e')));
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameCtrl.text,
      'brand': _brandCtrl.text,
      'category': _selectedCategory,
      'price': _priceCtrl.text,
      'original_price': _oldPriceCtrl.text,
      'sku': _skuCtrl.text,
      'featured': _featured ? '1' : '0',
      'description': _descCtrl.text,
      'variants': jsonEncode(_variants),
    };

    try {
      if (widget.product != null) {
        await context.read<AdminProductProvider>().updateProduct(
          widget.product!.id,
          data,
          newImages: _images.map((e) => e.path).toList(),
        );
      } else {
        await context.read<AdminProductProvider>().addProduct(
          data,
          _images.map((e) => e.path).toList(),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
