import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  late Future<Map<String, dynamic>> _loyaltyDataFuture;

  @override
  void initState() {
    super.initState();
    _loyaltyDataFuture = Provider.of<ApiService>(context, listen: false).getLoyaltyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Program'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loyaltyDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.black));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final data = snapshot.data!;
          final String rank = data['rank'] ?? 'Silver';
          final int points = data['points'] ?? 0;
          final double progress = (data['progress'] as num?)?.toDouble() ?? 0.0;
          final String nextRank = data['next_rank'] ?? 'Gold';
          final List history = data['history'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLoyaltyCard(rank, points),
                const SizedBox(height: 32),
                _buildProgressSection(progress, nextRank),
                const SizedBox(height: 32),
                _buildRewardsSection(),
                const SizedBox(height: 32),
                _buildHistorySection(history),
                const SizedBox(height: 40),
                const CyberFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoyaltyCard(String rank, int points) {
    Color cardColor;
    Color textColor = AppTheme.white;

    switch (rank.toLowerCase()) {
      case 'gold':
        cardColor = const Color(0xFFFFD700);
        textColor = AppTheme.black;
        break;
      case 'elite':
        cardColor = const Color(0xFF2C3E50);
        break;
      default: // Silver
        cardColor = const Color(0xFFBDC3C7);
        textColor = AppTheme.black;
    }

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor,
            cardColor.withOpacity(0.8),
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CYBER STORE',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Icon(Icons.nfc, color: textColor.withOpacity(0.5)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rank.toUpperCase(),
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Loyalty Member',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL POINTS',
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    points.toString(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=loyalty-$points',
                width: 50,
                height: 50,
                color: textColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(double progress, String nextRank) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Next Rank Progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              nextRank,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.grey600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppTheme.grey200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.black),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}% towards your next tier',
          style: const TextStyle(fontSize: 12, color: AppTheme.grey600),
        ),
      ],
    );
  }

  Widget _buildRewardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tier Rewards',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        _rewardItem(Icons.workspace_premium, 'Silver', '1% cashback on all purchases'),
        _rewardItem(Icons.stars, 'Gold', '5% cashback + Exclusive Deals'),
        _rewardItem(Icons.diamond, 'Elite', 'Free Shipping + 10% cashback + VIP Support'),
      ],
    );
  }

  Widget _rewardItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(List history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Point Earnings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        if (history.isEmpty)
          const Text('No recent earnings', style: TextStyle(color: AppTheme.grey600))
        else
          ...history.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'] ?? 'Purchase', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(item['date'] ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
                  ],
                ),
                Text(
                  item['points']?.toString() ?? '+0',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          )).toList(),
      ],
    );
  }
}
