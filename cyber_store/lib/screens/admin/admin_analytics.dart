import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  late Future<Map<String, dynamic>> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _analyticsFuture = context.read<ApiService>().adminGetAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            tooltip: 'Ask Business AI',
            onPressed: _showAiAnalyst,
            icon: const Icon(Icons.auto_awesome, color: Colors.purple),
          ),
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.black));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  TextButton(onPressed: _refreshData, child: const Text('Retry')),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final totalSales = (data['total_sales'] as num?)?.toDouble() ?? 0.0;
          final totalOrders = data['total_orders'] ?? 0;
          final totalCustomers = data['total_customers'] ?? 0;
          final recentSales = data['recent_sales'] as List? ?? [];
          final topSelling = data['top_selling_products'] as List? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _SummaryCard(
                      label: 'Total Sales',
                      value: currencyFormat.format(totalSales),
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                    _SummaryCard(
                      label: 'Total Orders',
                      value: totalOrders.toString(),
                      icon: Icons.shopping_bag_outlined,
                      color: Colors.blue,
                    ),
                    _SummaryCard(
                      label: 'Total Customers',
                      value: totalCustomers.toString(),
                      icon: Icons.people_outline,
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sales Chart
                Text('Recent Sales (Last 30 Days)', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Container(
                  height: 250,
                  padding: const EdgeInsets.only(top: 16, right: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _SalesChart(salesData: recentSales),
                ),
                const SizedBox(height: 24),

                // Top Selling Products
                Text('Top Selling Products', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topSelling.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = topSelling[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.grey200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: item['image_url'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(item['image_url'], fit: BoxFit.cover),
                              )
                            : const Icon(Icons.image_outlined),
                      ),
                      title: Text(item['name'] ?? 'Unknown Product', style: AppTheme.light.textTheme.titleMedium),
                      subtitle: Text('${item['sales_count'] ?? 0} sales'),
                      trailing: Text(
                        currencyFormat.format((item['total_revenue'] as num?)?.toDouble() ?? 0.0),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                if (topSelling.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No data available')),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.grey200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  void _showAiAnalyst() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _AiAnalystSheet(),
    );
  }
}

class _AiAnalystSheet extends StatefulWidget {
  const _AiAnalystSheet();
  @override State<_AiAnalystSheet> createState() => _AiAnalystSheetState();
}

class _AiAnalystSheetState extends State<_AiAnalystSheet> {
  final _ctrl = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.grey200)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.purple),
                const SizedBox(width: 8),
                const Text('Business AI Analyst', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
          ),
          Expanded(
            child: _messages.isEmpty
              ? _buildSuggestions()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (c, i) => _buildBubble(_messages[i]),
                ),
          ),
          if (_loading) const LinearProgressIndicator(color: Colors.purple),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(hintText: 'Ask about your store...'),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loading ? null : _send,
                  icon: const Icon(Icons.send, color: Colors.purple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Try asking:', style: TextStyle(color: AppTheme.grey600)),
        const SizedBox(height: 16),
        _suggest('Summarize this month\'s performance'),
        _suggest('Which products should I restock?'),
        _suggest('How can I increase my sales?'),
      ],
    ),
  );

  Widget _suggest(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: ActionChip(
      label: Text(text),
      onPressed: () { _ctrl.text = text; _send(); },
    ),
  );

  Widget _buildBubble(Map<String, String> msg) {
    final isMe = msg['role'] == 'user';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.purple.shade100 : AppTheme.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Text(msg['content']!),
      ),
    );
  }

  void _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _ctrl.clear();
      _loading = true;
    });

    try {
      final reply = await context.read<ApiService>().adminAiAnalyzeBusiness(text);
      setState(() {
        _messages.add({'role': 'assistant', 'content': reply});
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Error: $e'});
        _loading = false;
      });
    }
  }
}

class _SalesChart extends StatelessWidget {
  final List salesData;

  const _SalesChart({required this.salesData});

  @override
  Widget build(BuildContext context) {
    if (salesData.isEmpty) {
      return const Center(child: Text('No sales data'));
    }

    final List<FlSpot> spots = [];
    double maxY = 0;

    for (int i = 0; i < salesData.length; i++) {
      final item = salesData[i];
      double val = 0;
      if (item is num) {
        val = item.toDouble();
      } else if (item is Map) {
        val = (item['amount'] as num?)?.toDouble() ?? 0.0;
      }
      spots.add(FlSpot(i.toDouble(), val));
      if (val > maxY) maxY = val;
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: spots.length > 1 ? spots.length - 1.0 : 1.0,
        minY: 0,
        maxY: maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.black,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowArea: BarAreaData(
              show: true,
              color: AppTheme.black.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
