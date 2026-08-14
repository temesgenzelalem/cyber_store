import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'credit_card';
  bool   _sameAsBilling = true;
  bool   _processing    = false;
  String? _txRef;
  bool   _isWaitingForVerification = false;
  bool   _useWallet = false;

  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _cardCtrl   = TextEditingController();
  final _expCtrl    = TextEditingController();
  final _cvvCtrl    = TextEditingController();

  // Animated card display
  String get _displayCard {
    final raw = _cardCtrl.text.replaceAll(' ', '');
    final padded = raw.padRight(16, '·');
    return '${padded.substring(0,4)} ${padded.substring(4,8)} '
           '${padded.substring(8,12)} ${padded.substring(12,16)}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReferralProvider>().fetchData();
    });
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _cardCtrl, _expCtrl, _cvvCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final co   = context.watch<CheckoutProvider>();
    final shipping = co.shippingCost(cart.subtotal);

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
          const CheckoutStepper(currentStep: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),

                  // ── Wallet Balance Toggle ──────────────────────────────
                  _buildWalletToggle(),
                  const SizedBox(height: 20),

                  // ── Payment Method Tabs ───────────────────────────────
                  Row(children: [
                    _methodTab('credit_card',  'Credit Card'),
                    _methodTab('paypal',       'PayPal'),
                    _methodTab('paypal_credit','PayPal Credit'),
                  ]),

                  const SizedBox(height: 20),

                  if (_method == 'credit_card') ...[
                    // ── Card Visual ─────────────────────────────────────
                    _buildCardVisual(),
                    const SizedBox(height: 20),

                    // ── Card Form ───────────────────────────────────────
                    Form(
                      key: _formKey,
                      child: Column(children: [
                        _field(_nameCtrl, 'Cardholder Name',
                          validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
                        const SizedBox(height: 10),
                        _field(_cardCtrl, 'Card Number',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _CardNumberFormatter(),
                          ],
                          maxLength: 19,
                          validator: (v) {
                            final digits = v?.replaceAll(' ', '') ?? '';
                            return digits.length < 16 ? 'Enter valid card number' : null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: _field(_expCtrl, 'Exp. Date',
                              keyboardType: TextInputType.datetime,
                              inputFormatters: [_ExpDateFormatter()],
                              maxLength: 5,
                              validator: (v) =>
                                (v?.length ?? 0) < 5 ? 'MM/YY' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _field(_cvvCtrl, 'CVV',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              maxLength: 4,
                              obscureText: true,
                              validator: (v) =>
                                (v?.length ?? 0) < 3 ? 'Invalid CVV' : null,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          Checkbox(
                            value:     _sameAsBilling,
                            onChanged: (v) => setState(() => _sameAsBilling = v ?? true),
                          ),
                          const Text('Same as billing address',
                            style: TextStyle(fontSize: 14)),
                        ]),
                      ]),
                    ),
                  ] else ...[
                    // Chapa / Digital Payment placeholder
                    Container(
                      height: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.grey100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, size: 40, color: AppTheme.grey600),
                          const SizedBox(height: 8),
                          Text('You will be redirected to Chapa to complete payment via $_method',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.grey600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],

                  if (_isWaitingForVerification) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(color: AppTheme.black),
                          const SizedBox(height: 16),
                          const Text('Please complete the payment in your browser',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _verifyPayment,
                            child: const Text('I have paid, verify now'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Back / Pay ────────────────────────────────────────────────
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
                  onPressed: _processing ? null : _pay,
                  child: _processing
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.white))
                    : const Text('Pay'),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // ── Card Visual ────────────────────────────────────────────────────────────

  Widget _buildCardVisual() => Container(
    height: 180,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: const LinearGradient(
        colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.3),
          blurRadius: 16, offset: const Offset(0, 6)),
      ],
    ),
    child: Stack(
      children: [
        // Decorative lines
        Positioned(
          top: -20, right: 40,
          child: Transform.rotate(
            angle: 0.5,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.07), width: 30),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          top: -40, right: -20,
          child: Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 30),
              shape: BoxShape.circle,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chip + NFC
              Row(children: [
                const Icon(Icons.sim_card, color: Color(0xFFFFD700), size: 28),
                const SizedBox(width: 8),
                const Icon(Icons.wifi, color: Colors.white54, size: 20),
              ]),
              const Spacer(),
              // Card number
              Text(_displayCard,
                style: const TextStyle(
                  color: AppTheme.white, fontSize: 18,
                  fontWeight: FontWeight.w600, letterSpacing: 2,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 12),
              // Cardholder + Mastercard logo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _nameCtrl.text.isEmpty ? 'Cardholder' : _nameCtrl.text,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  // Mastercard circles
                  Stack(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEB001B), shape: BoxShape.circle),
                    ),
                    Positioned(
                      left: 18,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF79E1B).withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildWalletToggle() {
    final referral = context.watch<ReferralProvider>();
    if (referral.balance <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wallet Balance: \$${referral.balance.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                const Text('Use balance for this order', style: TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          ),
          Switch(
            value: _useWallet,
            onChanged: (v) => setState(() => _useWallet = v),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _methodTab(String value, String label) {
    final selected = _method == value;
    return GestureDetector(
      onTap: () => setState(() => _method = value),
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Text(label, style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? AppTheme.black : AppTheme.grey600,
            )),
            const SizedBox(height: 4),
            if (selected)
              Container(height: 2, width: label.length * 8.0, color: AppTheme.black),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    bool obscureText = false,
    ValueChanged<String>? onChanged,
  }) => TextFormField(
    controller:       ctrl,
    validator:        validator,
    keyboardType:     keyboardType,
    inputFormatters:  inputFormatters,
    maxLength:        maxLength,
    obscureText:      obscureText,
    onChanged:        onChanged,
    decoration: InputDecoration(
      hintText:       hint,
      counterText:    '',
    ),
  );

  // ── Pay ────────────────────────────────────────────────────────────────────

  Future<void> _pay() async {
    if (_method == 'credit_card' && !(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _processing = true);

    final auth     = context.read<AuthProvider>();
    final cart     = context.read<CartProvider>();
    final co       = context.read<CheckoutProvider>();
    final svc      = context.read<ApiService>();
    final referral = context.read<ReferralProvider>();
    final shipping = co.shippingCost(cart.subtotal);

    double walletDeduction = 0;
    if (_useWallet) {
      walletDeduction = referral.balance > cart.total ? cart.total : referral.balance;
    }

    try {
      // 1. Create the Order on backend
      final orderId = await svc.createOrder(
        items:          cart.items,
        addressId:      co.selectedAddressId!,
        shippingMethod: co.shippingMethod,
        paymentMethod:  _method,
        subtotal:       cart.subtotal,
        tax:            cart.tax,
        shipping:       shipping,
        total:          cart.total - walletDeduction,
        walletDeduction: walletDeduction,
      );

      // 2. Initialize Chapa Payment (only if total > 0)
      if (cart.total - walletDeduction > 0) {
        final names = auth.user!.name.split(' ');
        final firstName = names.isNotEmpty ? names[0] : 'Customer';
        final lastName = names.length > 1 ? names.last : 'Cyber';

        final initData = await svc.initializePayment(
          orderId: orderId,
          amount: cart.total - walletDeduction,
          email: auth.user!.email,
          firstName: firstName,
          lastName: lastName,
        );

        _txRef = initData['data']['tx_ref'];
        final checkoutUrl = initData['data']['checkout_url'];

        // 3. Launch the Chapa Checkout Page
        if (await canLaunchUrl(Uri.parse(checkoutUrl))) {
          await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
          setState(() {
            _processing = false;
            _isWaitingForVerification = true;
          });
        } else {
          throw 'Could not launch payment page';
        }
      } else {
        // Full wallet payment
        co.reset();
        if (mounted) context.go('/checkout/success?id=$orderId');
      }
    } catch (e) {
      setState(() => _processing = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment setup failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _verifyPayment() async {
    if (_txRef == null) return;

    setState(() => _processing = true);
    final svc = context.read<ApiService>();
    final cart = context.read<CartProvider>();
    final co = context.read<CheckoutProvider>();

    try {
      final success = await svc.verifyPayment(_txRef!);
      if (success) {
        // Extract order ID from txRef
        final parts = _txRef!.split('-');
        final orderId = parts.last;

        co.reset();
        if (mounted) context.go('/checkout/success?id=$orderId');
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment not yet confirmed. Please try again in a moment.')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _processing = false);
    }
  }
}

// ── Input Formatters ──────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return next.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    var text = next.text.replaceAll('/', '');
    if (text.length > 2) text = '${text.substring(0, 2)}/${text.substring(2)}';
    return next.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
