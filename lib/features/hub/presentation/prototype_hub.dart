import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../../theme.dart';
import '../../../models/user_model.dart';

// Import screens we will define next to navigate correctly
import '../../auth/presentation/onboarding_screen.dart';

class PrototypeHub extends ConsumerStatefulWidget {
  const PrototypeHub({super.key});

  @override
  ConsumerState<PrototypeHub> createState() => _PrototypeHubState();
}

class _PrototypeHubState extends ConsumerState<PrototypeHub> {
  String _activeTab = 'flows'; // 'flows', 'roadmap', 'monetization', 'trust', 'analytics'

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpotCart Prototype Hub'),
        leading: Icon(
          Icons.blur_on_outlined,
          color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.orange,
        ),
        actions: [
          // Theme toggler directly on the hub
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(),
        onTap: (index) {
          setState(() {
            _activeTab = ['flows', 'roadmap', 'monetization', 'trust', 'analytics'][index];
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill), label: 'Flows'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Roadmap'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Business'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'Trust'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildActiveContent(),
          ),
        ),
      ),
    );
  }

  int _getCurrentIndex() {
    switch (_activeTab) {
      case 'flows':
        return 0;
      case 'roadmap':
        return 1;
      case 'monetization':
        return 2;
      case 'trust':
        return 3;
      case 'analytics':
        return 4;
      default:
        return 0;
    }
  }

  Widget _buildActiveContent() {
    switch (_activeTab) {
      case 'flows':
        return _buildFlowsPanel();
      case 'roadmap':
        return _buildRoadmapPanel();
      case 'monetization':
        return _buildMonetizationPanel();
      case 'trust':
        return _buildTrustPanel();
      case 'analytics':
        return _buildAnalyticsPanel();
      default:
        return _buildFlowsPanel();
    }
  }

  // PANEL 1: FLOWS
  Widget _buildFlowsPanel() {
    return ListView(
      key: const ValueKey('flows'),
      children: [
        const SizedBox(height: 8),
        Text(
          'SpotCart Presentation Flows',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryOrange,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a user flow to launch and present the application modules:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        
        // Customer Flow Card
        _buildLaunchCard(
          title: '1. Customer Experience Flow',
          subtitle: 'Onboarding → Location selection → Dosa/Tea chips filters → Live Leaflet Map → Bottom Sheet Menu → Get directions launcher.',
          icon: Icons.directions_walk,
          color: AppTheme.primaryOrange,
          onTap: () async {
            // Enable Demo Mode
            ref.read(isDemoModeProvider.notifier).state = true;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('is_demo_mode', true);
            
            // Clear role so onboarding triggers
            await prefs.remove('demo_user_role');
            
            // Set state to unauthenticated to force onboarding flow
            ref.read(authControllerProvider.notifier).logout();
            
            // Navigate to Onboarding
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const OnboardingScreen()),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        
        // Vendor Flow Card
        _buildLaunchCard(
          title: '2. Vendor Control Dashboard',
          subtitle: 'Status toggle (OPEN/CLOSED) → Menu manager (Snacks/Meals/Specials) → Draggable pin live coordinates updates → Sales analytics mock graphs.',
          icon: Icons.storefront_outlined,
          color: AppTheme.statusGreen,
          onTap: () async {
            // Enable Demo Mode and Mock Vendor User
            ref.read(isDemoModeProvider.notifier).state = true;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('is_demo_mode', true);
            
            final vendorUser = UserModel(
              id: 'mock_user_id',
              phoneNumber: '+91 99999 55555',
              role: 'vendor',
              name: 'Spicy Fish Tacos Truck',
              isOnline: false,
            );
            
            final repo = ref.read(authRepositoryProvider);
            repo.setMockCurrentUser(MockUser(uid: vendorUser.id, phoneNumber: vendorUser.phoneNumber));
            repo.setMockUserData(vendorUser.id, vendorUser);
            
            await prefs.setString('demo_user_id', vendorUser.id);
            await prefs.setString('demo_user_phone', vendorUser.phoneNumber);
            await prefs.setString('demo_user_role', 'vendor');
            await prefs.setString('demo_user_name', vendorUser.name!);

            // Force autologin check
            ref.read(authControllerProvider.notifier).checkUserProfile(vendorUser.id, vendorUser.phoneNumber);
          },
        ),
        const SizedBox(height: 16),
        
        // Admin Flow Card
        _buildLaunchCard(
          title: '3. Admin Panel & Moderation',
          subtitle: 'Total/Live vendor counts → Pending listings verification queue → Customer reports moderator (Fake Location/Duplicate Stall) → Community leaderboards.',
          icon: Icons.admin_panel_settings_outlined,
          color: AppTheme.ratingYellow,
          onTap: () async {
            // Enable Demo Mode and Mock Admin User
            ref.read(isDemoModeProvider.notifier).state = true;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('is_demo_mode', true);
            
            final adminUser = UserModel(
              id: 'demo_admin_id',
              phoneNumber: '+91 99999 00000',
              role: 'admin',
              name: 'SpotCart Admin Console',
            );
            
            final repo = ref.read(authRepositoryProvider);
            repo.setMockCurrentUser(MockUser(uid: adminUser.id, phoneNumber: adminUser.phoneNumber));
            repo.setMockUserData(adminUser.id, adminUser);
            
            await prefs.setString('demo_user_id', adminUser.id);
            await prefs.setString('demo_user_phone', adminUser.phoneNumber);
            await prefs.setString('demo_user_role', 'admin');
            await prefs.setString('demo_user_name', adminUser.name!);

            ref.read(authControllerProvider.notifier).checkUserProfile(adminUser.id, adminUser.phoneNumber);
          },
        ),
      ],
    );
  }

  Widget _buildLaunchCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.85),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // PANEL 2: ROADMAP
  Widget _buildRoadmapPanel() {
    return Card(
      key: const ValueKey('roadmap'),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SpotCart Expansion Roadmap',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildRoadmapNode(
                    phase: 'PHASE 1: Tamil Nadu Launch (Current)',
                    desc: 'Deploy Leaflet maps rendering OpenStreetMap tiles, SMS Verification flow, role selector onboarding, menu catalog sorting (Snacks, Meals, Drinks, Specials), and draggable live location updates for mobile/web.',
                    isDone: true,
                  ),
                  _buildRoadmapNode(
                    phase: 'PHASE 2: Trust & Micro-reviews (Q3 2026)',
                    desc: 'Deploy community gamification metrics: user accuracy rating levels, badges (Spot Hunter, Accuracy Hero), verification polls (is coordinates accurate? timing accurate?), and photographic reviews with automatic geotags.',
                    isDone: false,
                  ),
                  _buildRoadmapNode(
                    phase: 'PHASE 3: AI Mobility Optimizer (Q1 2027)',
                    desc: 'Train prediction algorithms analyzing historical vendor patterns, footfalls, and timeslots. Recommend optimal spots for moving food trucks and pushcarts to maximize revenue in Chennai, Madurai, & Coimbatore.',
                    isDone: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadmapNode({
    required String phase,
    required String desc,
    required bool isDone,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? AppTheme.statusGreen : Colors.grey,
              size: 26,
            ),
            Container(
              width: 2.5,
              height: 120,
              color: isDone ? AppTheme.statusGreen : Colors.grey.shade300,
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                phase,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: const TextStyle(fontSize: 13, height: 1.45),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  // PANEL 3: MONETIZATION
  Widget _buildMonetizationPanel() {
    return ListView(
      key: const ValueKey('monetization'),
      children: [
        Text(
          'Monetization Strategy',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryOrange,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'How SpotCart sustains operation and scales commercial margins:',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 24),
        
        _buildMonetizationRow(
          title: 'Sponsored Map Highlights',
          price: '₹299/week',
          desc: 'Vendors can pin their food truck as a glowing animated marker on the customer Map. Increases customer clicks by 40%.',
          icon: Icons.campaign_rounded,
        ),
        const SizedBox(height: 16),
        
        _buildMonetizationRow(
          title: 'Premium Analytics Dashboard',
          price: '₹149/month',
          desc: 'Gives vendors weekly and monthly visual reports detailing Customer Saves, Peak View timeslots, and top-performing dishes.',
          icon: Icons.trending_up,
        ),
        const SizedBox(height: 16),
        
        _buildMonetizationRow(
          title: 'Featured Category Placements',
          price: '₹499/week',
          desc: 'Highlight vendor cards at the very top of the customer Home Screen (e.g. "Trending Near You" or "Today\'s Specials").',
          icon: Icons.star_rate_rounded,
        ),
      ],
    );
  }

  Widget _buildMonetizationRow({
    required String title,
    required String price,
    required String desc,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppTheme.primaryOrange, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryOrange,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  // PANEL 4: TRUST
  Widget _buildTrustPanel() {
    return Card(
      key: const ValueKey('trust'),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Trust System',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Because street vendors move frequently, SpotCart implements a self-correcting community reporting loop to guarantee reliability:',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildTrustItem(
                    title: '1. Crowd-Sourced Verification',
                    desc: 'Every customer review prompts trust confirmation questions: "Is the vendor location accurate?" and "Is the timing accurate?". Responses dynamically recalculate the vendor\'s confidence score.',
                    icon: Icons.group,
                  ),
                  const SizedBox(height: 16),
                  _buildTrustItem(
                    title: '2. Admin Moderation Queue',
                    desc: 'Customer reports (Fake Vendor, Duplicate Card, Wrong Coordinates) alert the Admin Panel immediately, allowing quick warning triggers or listings suspension.',
                    icon: Icons.security,
                  ),
                  const SizedBox(height: 16),
                  _buildTrustItem(
                    title: '3. Reputable Contributor Badges',
                    desc: 'Users gain gamification badges (Accuracy Hero, Spot Hunter) for providing accurate reports, shifting them to high positions on the weekly Contributors Leaderboard.',
                    icon: Icons.emoji_events,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustItem({
    required String title,
    required String desc,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryOrange, size: 30),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // PANEL 5: ANALYTICS
  Widget _buildAnalyticsPanel() {
    return ListView(
      key: const ValueKey('analytics'),
      children: [
        Text(
          'Simulated Analytics Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryOrange,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Live statistics indicating app usage and visitor profiles (Chennai Area):',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 24),
        
        // Main charts mock
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Active Users (DAU) Growth',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 16),
                // Simple bar representation for graph
                _buildBarGraphRow(day: 'Mon', count: 120, max: 200),
                _buildBarGraphRow(day: 'Tue', count: 145, max: 200),
                _buildBarGraphRow(day: 'Wed', count: 168, max: 200),
                _buildBarGraphRow(day: 'Thu', count: 195, max: 200),
                _buildBarGraphRow(day: 'Fri', count: 240, max: 240),
                _buildBarGraphRow(day: 'Sat', count: 210, max: 240),
                _buildBarGraphRow(day: 'Sun', count: 150, max: 240),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Circle representations
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Total Registrations', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('1,250', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primaryOrange)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Live Active Stalls', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('84', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.statusGreen)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildBarGraphRow({required String day, required int count, required int max}) {
    final double fillPercentage = count / max;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(day, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: fillPercentage,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(width: 40, child: Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
