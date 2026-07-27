import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<MockFavoriteVendor> _favorites = [
    MockFavoriteVendor(name: 'Annapoorani Tiffin Stall', group: 'Open Now', cuisine: 'Idli & Dosa', distance: '120m away'),
    MockFavoriteVendor(name: 'Mani\'s Tea & Vadai Shop', group: 'Nearby', cuisine: 'Snacks & Tea', distance: '230m away'),
    MockFavoriteVendor(name: 'Selvam Fast Food', group: 'Recently Updated', cuisine: 'Kothu Parotta', distance: '450m away'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore & Community'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryOrange,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade400,
          tabs: const [
            Tab(text: 'Community & Rewards'),
            Tab(text: 'My Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCommunityTab(isDark),
          _buildFavoritesTab(isDark),
        ],
      ),
    );
  }

  // TAB 1: COMMUNITY & REWARDS
  Widget _buildCommunityTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // Gamification Progress Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Contributor Rank',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Level 3',
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryOrange, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const LinearProgressIndicator(
                  value: 0.72,
                  backgroundColor: Color(0xFFEFEFEF),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                ),
                const SizedBox(height: 8),
                const Text(
                  '180 / 250 XP to Level 4 (Accuracy Hero)',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Badges Section
        Text(
          'My Badges & Rewards',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildBadgeCard('Spot Hunter', Icons.gps_fixed, AppTheme.primaryOrange, true),
              _buildBadgeCard('Accuracy Hero', Icons.verified_user, AppTheme.statusGreen, true),
              _buildBadgeCard('Top Contributor', Icons.emoji_events, AppTheme.ratingYellow, true),
              _buildBadgeCard('Early Reporter', Icons.schedule, Colors.blue, false), // Locked
              _buildBadgeCard('Food Critic', Icons.rate_review, Colors.purple, false), // Locked
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Leaderboard
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly Accuracy Champions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Tamil Nadu',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildLeaderboardRow(1, 'Arun Kumar', '45 updates', '100% Acc'),
              const Divider(height: 1),
              _buildLeaderboardRow(2, 'Divya Karthik', '38 updates', '98% Acc'),
              const Divider(height: 1),
              _buildLeaderboardRow(3, 'Siddharth M.', '31 updates', '97% Acc'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(String name, IconData icon, Color color, bool unlocked) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Opacity(
          opacity: unlocked ? 1.0 : 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                unlocked ? 'UNLOCKED' : 'LOCKED',
                style: TextStyle(fontSize: 8, color: unlocked ? AppTheme.statusGreen : Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow(int rank, String name, String updates, String accuracy) {
    return ListTile(
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: rank == 1 ? AppTheme.ratingYellow : (rank == 2 ? Colors.grey.shade300 : Colors.orange.shade100),
        child: Text('$rank', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(updates, style: const TextStyle(fontSize: 12)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.statusGreen.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          accuracy,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.statusGreen, fontSize: 11),
        ),
      ),
    );
  }

  // TAB 2: MY FAVORITES
  Widget _buildFavoritesTab(bool isDark) {
    final groups = ['Open Now', 'Nearby', 'Recently Updated'];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final groupName = groups[index];
        final list = _favorites.where((element) => element.group == groupName).toList();
        
        if (list.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 12, bottom: 8),
              child: Text(
                groupName.toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
              ),
            ),
            ...list.map((item) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront, color: AppTheme.primaryOrange),
                ),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Row(
                  children: [
                    Text(item.cuisine, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    const Icon(Icons.circle, size: 4, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(item.distance, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.navigation, color: Colors.blue),
                      onPressed: () {},
                      tooltip: 'Navigate',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.dangerRed),
                      onPressed: () {
                        setState(() {
                          _favorites.remove(item);
                        });
                      },
                      tooltip: 'Unsave',
                    ),
                  ],
                ),
              ),
            )),
          ],
        );
      },
    );
  }
}

class MockFavoriteVendor {
  final String name;
  final String group;
  final String cuisine;
  final String distance;

  MockFavoriteVendor({required this.name, required this.group, required this.cuisine, required this.distance});
}
