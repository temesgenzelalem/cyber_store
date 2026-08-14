import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import 'package:lottie/lottie.dart';

class SuccessScreen extends StatefulWidget {
  final String orderId;
  const SuccessScreen({super.key, required this.orderId});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Lottie check animation ───────────────────────────────
              Center(
                child: Lottie.network(
                  'https://assets10.lottiefiles.com/packages/lf20_awS6vC.json',
                  width: 200, height: 200, repeat: false,
                ),
              ),

              const SizedBox(height: 28),

              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    const Text('Order Placed!',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Text(
                      'Thank you for your purchase.\nYour order is being processed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppTheme.grey600, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.grey100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Order ID: ',
                            style: TextStyle(color: AppTheme.grey600, fontSize: 13)),
                          Text(widget.orderId.length > 12
                            ? widget.orderId.substring(0, 12) + '…'
                            : widget.orderId,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13,
                              fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Continue Shopping'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.go('/products'),
                      child: const Text('View All Products'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
