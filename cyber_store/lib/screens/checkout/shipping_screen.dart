import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key});
  @override State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  String    _method       = 'free';
  DateTime? _scheduledDate;

  @override
  void initState() {
    super.initState();
    final co = context.read<CheckoutProvider>();
    _method        = co.shippingMethod;
    _scheduledDate = co.scheduledDate;
  }

  @override
  Widget build(BuildContext context) {
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
          const CheckoutStepper(currentStep: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Shipment Method',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),

                  // ── Free shipping ──────────────────────────────────────
                  _ShippingOption(
                    value:    'free',
                    selected: _method,
                    onTap:    () => setState(() => _method = 'free'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Free',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          const Text('Regular shipment',
                            style: TextStyle(fontSize: 13, color: AppTheme.grey600)),
                        ]),
                        const Text('17 Oct, 2024',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Express ────────────────────────────────────────────
                  _ShippingOption(
                    value:    'express',
                    selected: _method,
                    onTap:    () => setState(() => _method = 'express'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('\$8.50',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          const Text('Get your delivery\nas soon as possible',
                            style: TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.4)),
                        ]),
                        const Text('1 Oct, 2024',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Scheduled ─────────────────────────────────────────
                  _ShippingOption(
                    value:    'scheduled',
                    selected: _method,
                    onTap:    () => setState(() => _method = 'scheduled'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Schedule',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          const Text('Pick a date when\nyou want to get\nyour delivery',
                            style: TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.4)),
                        ]),
                        // Date picker
                        GestureDetector(
                          onTap: _method == 'scheduled' ? _pickDate : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.grey200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(children: [
                              Text(
                                _scheduledDate != null
                                  ? '${_scheduledDate!.day} ${_monthName(_scheduledDate!.month)}'
                                  : 'Select Date',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down, size: 16),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Back / Next ──────────────────────────────────────────────────
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
                  onPressed: _canProceed ? _proceed : null,
                  child: const Text('Next'),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  bool get _canProceed =>
      _method != 'scheduled' || _scheduledDate != null;

  void _proceed() {
    final co = context.read<CheckoutProvider>();
    co.selectShipping(_method);
    if (_scheduledDate != null) co.selectDate(_scheduledDate!);
    context.push('/checkout/payment');
  }

  Future<void> _pickDate() async {
    final now  = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate:   now.add(const Duration(days: 1)),
      lastDate:    now.add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.black),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _scheduledDate = date);
  }

  String _monthName(int m) => const [
    '', 'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ][m];
}

// ─────────────────────────────────────────────────────────────────────────────

class _ShippingOption extends StatelessWidget {
  final String   value;
  final String   selected;
  final VoidCallback onTap;
  final Widget   child;

  const _ShippingOption({
    required this.value,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.black : AppTheme.grey200,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value:      value,
              groupValue: selected,
              onChanged:  (_) => onTap(),
              activeColor: AppTheme.black,
            ),
            const SizedBox(width: 4),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
