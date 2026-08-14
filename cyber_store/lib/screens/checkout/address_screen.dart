import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});
  @override State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  String? _selectedId;
  bool    _showAddForm = false;
  LatLng? _selectedLocation;

  // Add-address form
  final _formKey   = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _streetCtrl= TextEditingController();
  final _cityCtrl  = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl   = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _labelVal = 'HOME';

  @override
  void dispose() {
    for (final c in [_labelCtrl,_streetCtrl,_cityCtrl,_stateCtrl,_zipCtrl,_phoneCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.read<ApiService>();
    final co  = context.read<CheckoutProvider>();

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('cyber', style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
      ),
      body: Column(
        children: [
          const CheckoutStepper(currentStep: 1),
          Expanded(
            child: FutureBuilder<List<AddressModel>>(
              future: svc.getAddresses(),
              builder: (ctx, snap) {
                final addresses = snap.data ?? [];
                if (_selectedId == null && addresses.isNotEmpty) {
                  _selectedId = co.selectedAddressId ?? addresses[0].id;
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Address',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),

                      // Address cards
                      ...addresses.map((a) => _AddressCard(
                        address: a,
                        selected: _selectedId == a.id,
                        onSelect: () => setState(() => _selectedId = a.id),
                        onDelete: () async {
                          // await svc.deleteAddress(a.id);
                          if (_selectedId == a.id) setState(() => _selectedId = null);
                        },
                      )),

                      // Add new address button
                      GestureDetector(
                        onTap: () => setState(() => _showAddForm = !_showAddForm),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.grey200, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 28, height: 28,
                                decoration: const BoxDecoration(
                                  color: AppTheme.black, shape: BoxShape.circle),
                                child: const Icon(Icons.add, color: AppTheme.white, size: 18),
                              ),
                              const SizedBox(width: 8),
                              const Text('Add New Address',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),

                      // Add address form
                      if (_showAddForm) _buildAddForm(ctx, svc),

                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Back / Next ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedId == null ? null : () {
                    co.selectAddress(_selectedId!);
                    context.push('/checkout/shipping');
                  },
                  child: const Text('Next'),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildAddForm(BuildContext ctx, ApiService svc) => Form(
    key: _formKey,
    child: Column(
      children: [
        const SizedBox(height: 12),
        // Label chips
        Row(children: ['HOME', 'OFFICE', 'OTHER'].map((l) => GestureDetector(
          onTap: () => setState(() => _labelVal = l),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _labelVal == l ? AppTheme.black : AppTheme.grey100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(l, style: TextStyle(
              color: _labelVal == l ? AppTheme.white : AppTheme.black,
              fontSize: 12, fontWeight: FontWeight.w600,
            )),
          ),
        )).toList()),
        const SizedBox(height: 12),
        _field(_streetCtrl, 'Street Address', required: true),
        _field(_cityCtrl,  'City',           required: true),
        Row(children: [
          Expanded(child: _field(_stateCtrl, 'State', required: true)),
          const SizedBox(width: 8),
          Expanded(child: _field(_zipCtrl,  'ZIP Code', required: true)),
        ]),
        _field(_phoneCtrl, 'Phone', required: true, keyboardType: TextInputType.phone),
        const SizedBox(height: 12),

        // Map Picker Button
        OutlinedButton.icon(
          onPressed: () async {
            final LatLng? result = await context.push<LatLng>('/checkout/map');
            if (result != null) {
              setState(() => _selectedLocation = result);
            }
          },
          icon: const Icon(Icons.map_outlined, size: 20),
          label: const Text('Set Exact Location on Map'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            side: BorderSide(color: _selectedLocation != null ? Colors.green : AppTheme.grey200),
          ),
        ),
        if (_selectedLocation != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  '📍 Location Set (${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)})',
                  style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            // final id = await svc.addAddress(AddressModel(...));
            setState(() {
              // _selectedId = id;
              _showAddForm = false;
            });
          },
          child: const Text('Save Address'),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );

  Widget _field(TextEditingController ctrl, String hint, {
    bool required = false, TextInputType? keyboardType,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(hintText: hint),
      validator: required ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final bool         selected;
  final VoidCallback onSelect;
  final VoidCallback onDelete;
  const _AddressCard({required this.address, required this.selected,
    required this.onSelect, required this.onDelete});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onSelect,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? AppTheme.black : AppTheme.grey200,
          width: selected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Radio
          Radio<bool>(
            value: true,
            groupValue: selected,
            onChanged: (_) => onSelect(),
          ),
          const SizedBox(width: 4),

          // Address info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(address.label, style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(address.label, style: const TextStyle(
                      color: AppTheme.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(address.fullAddress,
                  style: const TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.4)),
                const SizedBox(height: 2),
                Text(address.phone, style: const TextStyle(fontSize: 13, color: AppTheme.grey600)),
              ],
            ),
          ),

          // Edit / Delete
          IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () {}),
          IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onDelete),
        ],
      ),
    ),
  );
}
