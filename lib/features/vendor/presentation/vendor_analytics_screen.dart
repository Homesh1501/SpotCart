import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../theme.dart';

class VendorAnalyticsScreen extends ConsumerWidget {
  const VendorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            // Return to hub/role selection
            ref.read(authControllerProvider.notifier).changeRole();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Analytics Cards Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context, 
                    'Views Today', 
                    '342', 
                    '+18% vs yesterday', 
                    Icons.remove_red_eye_outlined, 
                    AppTheme.primaryOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context, 
                    'Total Saves', 
                    '1,204', 
                    '+45 this week', 
                    Icons.bookmark_outline, 
                    AppTheme.ratingYellow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context, 
                    'Community Checks', 
                    '89', 
                    '99% accuracy rate', 
                    Icons.verified_user_outlined, 
                    AppTheme.statusGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context, 
                    'Est. Revenue', 
                    '₹4.2k', 
                    '₹150 avg order', 
                    Icons.currency_rupee, 
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Custom Bar Chart for Weekly Visitors
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Visitor Trends',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Number of customer profile clicks per day',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildChartBar('Mon', 45, false),
                          _buildChartBar('Tue', 65, false),
                          _buildChartBar('Wed', 85, false),
                          _buildChartBar('Thu', 50, false),
                          _buildChartBar('Fri', 110, true), // Peak day
                          _buildChartBar('Sat', 95, false),
                          _buildChartBar('Sun', 70, false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Top Dishes List
            Text(
              'Most Popular Items',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    _buildPopularItemRow(
                      '1',
                      'Caramelized Onion Burger',
                      '140 views',
                      '₹180',
                      '42 saves',
                    ),
                    const Divider(height: 1),
                    _buildPopularItemRow(
                      '2',
                      'Earthy Sweet Potato Fries',
                      '98 views',
                      '₹120',
                      '28 saves',
                    ),
                    const Divider(height: 1),
                    _buildPopularItemRow(
                      '3',
                      'Filter Coffee Special',
                      '65 views',
                      '₹100',
                      '15 saves',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, 
    String title, 
    String value, 
    String trend, 
    IconData icon, 
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 22),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              trend,
              style: TextStyle(
                fontSize: 9, 
                color: trend.contains('+') ? AppTheme.statusGreen : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(String day, double count, bool isPeak) {
    final double percentage = count / 120; // Max count is 120
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${count.toInt()}',
          style: TextStyle(
            fontSize: 9, 
            fontWeight: FontWeight.bold, 
            color: isPeak ? AppTheme.primaryOrange : Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 24,
          height: 100 * percentage,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPeak 
                  ? [AppTheme.primaryOrange, Colors.orangeAccent] 
                  : [Colors.grey.shade400, Colors.grey.shade300],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPopularItemRow(
    String rank, 
    String name, 
    String views, 
    String price, 
    String saves,
  ) {
    return ListTile(
      leading: CircleAvatar(
        radius: 12,
        backgroundColor: rank == '1' ? AppTheme.primaryOrange.withOpacity(0.12) : Colors.grey.withOpacity(0.12),
        child: Text(
          rank, 
          style: TextStyle(
            color: rank == '1' ? AppTheme.primaryOrange : Colors.grey, 
            fontSize: 12, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Row(
        children: [
          Text(views, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(width: 8),
          const Icon(Icons.circle, size: 3, color: Colors.grey),
          const SizedBox(width: 8),
          Text(saves, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
      trailing: Text(
        price, 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryOrange),
      ),
    );
  }
}
