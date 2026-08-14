import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ReferralProvider>().fetchData());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReferralProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(provider.balance),
                    const SizedBox(height: 32),
                    _buildReferralCode(provider.code),
                    const SizedBox(height: 32),
                    Text('My Referrals', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    _buildReferralList(provider.referrals),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Wallet Balance',
            style: TextStyle(color: AppTheme.grey400, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCode(String? code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Refer your friends and earn!',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.grey100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.grey200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  code ?? '---',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (code != null) {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard')),
                    );
                  }
                },
                icon: const Icon(Icons.copy, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferralList(List<Map<String, dynamic>> referrals) {
    if (referrals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppTheme.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(Icons.people_outline, size: 48, color: AppTheme.grey400),
            SizedBox(height: 16),
            Text(
              'No referrals yet',
              style: TextStyle(color: AppTheme.grey600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: referrals.length,
      separatorBuilder: (c, i) => const Divider(),
      itemBuilder: (context, index) {
        final r = referrals[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: AppTheme.grey200,
            backgroundImage: r['avatar'] != null ? NetworkImage(r['avatar']) : null,
            child: r['avatar'] == null ? const Icon(Icons.person, color: AppTheme.grey600) : null,
          ),
          title: Text(r['name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('Joined ${r['date'] ?? ''}'),
          trailing: Text(
            '+\$${r['reward'] ?? '0.00'}',
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
          ),
        );
      },
    );
  }
}
