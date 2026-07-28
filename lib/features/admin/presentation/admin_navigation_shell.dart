import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../theme.dart';

import 'admin_queries_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class AdminNavigationShell extends ConsumerStatefulWidget {
  const AdminNavigationShell({super.key});

  @override
  ConsumerState<AdminNavigationShell> createState() => _AdminNavigationShellState();
}

class _AdminNavigationShellState extends ConsumerState<AdminNavigationShell> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const AdminDashboardTab(),
      const AdminQueriesTab(),
      const AdminVerificationTab(),
      const AdminReportsTab(),
      const SharedProfileScreen(role: 'admin'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryOrange,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined),
            activeIcon: Icon(Icons.support_agent),
            label: 'Queries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined),
            activeIcon: Icon(Icons.verified_user),
            label: 'Approvals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem_outlined),
            activeIcon: Icon(Icons.report_problem),
            label: 'Flags',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// TAB 0: ADMIN OVERVIEW DASHBOARD
// ----------------------------------------------------
class AdminDashboardTab extends ConsumerWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Command Center'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            ref.read(authControllerProvider.notifier).changeRole();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Headline Cards
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard('Total Stalls', '1,420', '+12 today', Icons.storefront, Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOverviewCard('Live Carts Now', '342', '+24 active', Icons.location_on, AppTheme.statusGreen),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard('Verification Queue', '8 Pending', 'Need review', Icons.fact_check, AppTheme.primaryOrange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOverviewCard('Unresolved Reports', '4 Flags', '2 high priority', Icons.warning_amber, AppTheme.dangerRed),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Visual Chart Pitch
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Stall Registration Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('Weekly registrations across Tamil Nadu', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildChartBar('Chennai', 80),
                          _buildChartBar('Coimbatore', 65),
                          _buildChartBar('Madurai', 45),
                          _buildChartBar('Trichy', 30),
                          _buildChartBar('Salem', 20),
                        ],
                      ),
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

  Widget _buildOverviewCard(String title, String count, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(String label, int value) {
    final double percentage = value / 100;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 80 * percentage,
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }
}

// ----------------------------------------------------
// TAB 1: APPROVALS / VERIFICATION QUEUE
// ----------------------------------------------------
class AdminVerificationTab extends StatefulWidget {
  const AdminVerificationTab({super.key});

  @override
  State<AdminVerificationTab> createState() => _AdminVerificationTabState();
}

class _AdminVerificationTabState extends State<AdminVerificationTab> {
  final List<MockApplication> _applications = [
    MockApplication(
      id: '1',
      name: 'Ramu\'s Evening Bajji Stall',
      fssaiLicense: 'FSSAI-23321008000142',
      city: 'Chennai',
      ownerName: 'Ramu K.',
      submittedDate: '1 day ago',
    ),
    MockApplication(
      id: '2',
      name: 'Madurai Kari Dosai Cart',
      fssaiLicense: 'FSSAI-12219001000958',
      city: 'Madurai',
      ownerName: 'Subramanian M.',
      submittedDate: '2 days ago',
    ),
    MockApplication(
      id: '3',
      name: 'Ooty Varkey Tea Corner',
      fssaiLicense: 'FSSAI-22020005001140',
      city: 'Coimbatore',
      ownerName: 'Ganesh Pillai',
      submittedDate: '3 days ago',
    ),
  ];

  void _resolveApp(String id, bool approved) {
    setState(() {
      _applications.removeWhere((app) => app.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(approved ? 'Vendor account successfully approved and verified!' : 'Application rejected.'),
        backgroundColor: approved ? AppTheme.statusGreen : AppTheme.dangerRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Approval Board'),
      ),
      body: _applications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, size: 64, color: AppTheme.statusGreen),
                  const SizedBox(height: 16),
                  Text('All applications processed!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Verification queue is empty.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _applications.length,
              itemBuilder: (context, index) {
                final app = _applications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                app.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(app.city, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Owner', app.ownerName),
                        _buildDetailRow('FSSAI Reg', app.fssaiLicense),
                        _buildDetailRow('Submitted', app.submittedDate),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _resolveApp(app.id, false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.dangerRed,
                                  side: const BorderSide(color: AppTheme.dangerRed),
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _resolveApp(app.id, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.statusGreen,
                                ),
                                child: const Text('Approve & Verify'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class MockApplication {
  final String id;
  final String name;
  final String fssaiLicense;
  final String city;
  final String ownerName;
  final String submittedDate;

  MockApplication({
    required this.id,
    required this.name,
    required this.fssaiLicense,
    required this.city,
    required this.ownerName,
    required this.submittedDate,
  });
}

// ----------------------------------------------------
// TAB 2: REPORTS PANEL
// ----------------------------------------------------
class AdminReportsTab extends StatefulWidget {
  const AdminReportsTab({super.key});

  @override
  State<AdminReportsTab> createState() => _AdminReportsTabState();
}

class _AdminReportsTabState extends State<AdminReportsTab> {
  final List<MockReport> _reports = [
    MockReport(
      id: '1',
      vendorName: 'Earthy Green Fruit Stand',
      reason: 'Incorrect location coordinates. The vendor cart is not present there.',
      reporterName: 'Aravind S.',
      severity: 'High',
    ),
    MockReport(
      id: '2',
      vendorName: 'Mani\'s Tea Corner',
      reason: 'Wrong timings. Listed as open but was closed.',
      reporterName: 'Pavithra R.',
      severity: 'Low',
    ),
  ];

  void _resolveReport(String id, String resolution) {
    setState(() {
      _reports.removeWhere((r) => r.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report resolved: Action [$resolution] applied.'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Flags & Reports'),
      ),
      body: _reports.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: AppTheme.statusGreen),
                  const SizedBox(height: 16),
                  Text('All clean! No active flags.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                final isHigh = report.severity == 'High';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                report.vendorName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isHigh ? AppTheme.dangerRed.withOpacity(0.12) : Colors.amber.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                report.severity.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 8, 
                                  fontWeight: FontWeight.bold, 
                                  color: isHigh ? AppTheme.dangerRed : Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Issue: "${report.reason}"',
                          style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Reported by: ${report.reporterName}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _resolveReport(report.id, 'Dismissed'),
                                child: const Text('Dismiss'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _resolveReport(report.id, 'Warned Vendor'),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                                child: const Text('Warn Stall'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _resolveReport(report.id, 'Stall Suspended'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
                                child: const Text('Suspend'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class MockReport {
  final String id;
  final String vendorName;
  final String reason;
  final String reporterName;
  final String severity;

  MockReport({
    required this.id,
    required this.vendorName,
    required this.reason,
    required this.reporterName,
    required this.severity,
  });
}

// ----------------------------------------------------
// TAB 3: COMMUNITY LEADERBOARDS & XP
// ----------------------------------------------------
class AdminLeaderboardTab extends StatelessWidget {
  const AdminLeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User XP & Gamification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Icon(Icons.stars, color: AppTheme.ratingYellow, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'Accuracy Champion program',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Users earn +15 XP for every correct live location update check they report.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Leaderboard Champions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _buildLeaderboardItem(1, 'Arun Kumar', '450 XP', '100% accuracy rate'),
                  const Divider(height: 1),
                  _buildLeaderboardItem(2, 'Divya Karthik', '380 XP', '98% accuracy rate'),
                  const Divider(height: 1),
                  _buildLeaderboardItem(3, 'Siddharth M.', '310 XP', '97% accuracy rate'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(int rank, String name, String xp, String note) {
    return ListTile(
      leading: CircleAvatar(
        radius: 12,
        backgroundColor: rank == 1 ? AppTheme.ratingYellow : Colors.grey.shade200,
        child: Text('$rank', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(note, style: const TextStyle(fontSize: 11)),
      trailing: Text(xp, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryOrange)),
    );
  }
}

// ----------------------------------------------------
// TAB 4: SYSTEM CONTROLS
// ----------------------------------------------------
class AdminSettingsTab extends ConsumerWidget {
  const AdminSettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Controls'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Demo Database Override'),
                  subtitle: Text(isDemo ? 'Running in Simulated Mode' : 'Connected to Firestore production'),
                  trailing: Switch(
                    value: isDemo,
                    onChanged: (val) {
                      ref.read(isDemoModeProvider.notifier).state = val;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(val ? 'Switched to Demo Database' : 'Switched to Firestore production')),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('System Color Scheme'),
                  subtitle: Text(themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode'),
                  trailing: Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
