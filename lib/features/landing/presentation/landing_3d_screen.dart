import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../theme.dart';
import '../../auth/presentation/login_screen.dart';

class Landing3DScreen extends StatefulWidget {
  const Landing3DScreen({super.key});

  @override
  State<Landing3DScreen> createState() => _Landing3DScreenState();
}

class _Landing3DScreenState extends State<Landing3DScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _proceedToLoginPortal() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const LoginScreen(),
        transitionsBuilder: (context, anim1, anim2, child) {
          return FadeTransition(opacity: anim1, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = true; // Dark mode default

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D11), // Deep Dark Canvas
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // -------------------------------------------------------------
          // 3D HERO HEADER
          // -------------------------------------------------------------
          SliverToBoxAdapter(
            child: SizedBox(
              height: size.height * 0.9,
              child: Stack(
                children: [
                  // Animated Background Grid Glow
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.0, -0.4),
                          radius: 1.2,
                          colors: [
                            Color(0x35FF6B00), // Glowing Orange Halo
                            Color(0x10181824),
                            Color(0xFF0D0D11),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Floating 3D Depth Elements
                  Positioned(
                    top: 60 - (_scrollOffset * 0.2),
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        // Top Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.radar, color: AppTheme.primaryOrange, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'REAL-TIME STREET FOOD RADAR',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryOrange,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title Header
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.white, Color(0xFFFFB074)],
                          ).createShader(bounds),
                          child: const Text(
                            'SpotCart',
                            style: TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Track Roadside Food Carts Live on Map',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade300,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // 3D Perspective Floating Interactive Card Box
                        Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // 3D Perspective depth
                            ..rotateX((_scrollOffset * 0.002).clamp(-0.4, 0.4))
                            ..rotateY(math.sin(_scrollOffset * 0.003) * 0.15),
                          alignment: Alignment.center,
                          child: Container(
                            width: math.min(size.width * 0.85, 450),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161622).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: Colors.white.withOpacity(0.12)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryOrange.withOpacity(0.25),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.storefront, size: 56, color: AppTheme.primaryOrange),
                                const SizedBox(height: 14),
                                const Text(
                                  'Empowering Local Food Carts',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Designed specifically for local roadside food stall owners. No complex bureaucracy—just simple live location sharing & hungry local customers.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade400,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _proceedToLoginPortal,
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Proceed to SpotCart Portal'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryOrange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Scroll Indicator Arrow
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Text(
                          'Scroll Down for 3D Features Showcase',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 4),
                        Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -------------------------------------------------------------
          // 3D FEATURE TILES SHOWCASE SECTION
          // -------------------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Step-by-step App Experience',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover how SpotCart connects local street food stalls with food lovers in real time.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 32),

                  // Feature Card 1
                  _build3DFeatureCard(
                    step: 'STEP 1',
                    icon: Icons.explore_outlined,
                    iconColor: Colors.blueAccent,
                    title: 'Interactive 3D Radar Showcase',
                    description: 'Explore active roadside food carts moving in Chennai, Madurai & Coimbatore with live location markers.',
                    offset: _scrollOffset,
                    cardIndex: 1,
                  ),
                  const SizedBox(height: 20),

                  // Feature Card 2
                  _build3DFeatureCard(
                    step: 'STEP 2',
                    icon: Icons.person_pin_outlined,
                    iconColor: Colors.purpleAccent,
                    title: 'Multi-Role Portal Access',
                    description: 'Choose whether you are a Customer searching for meals, a Roadside Food Vendor broadcasting location, or an Admin managing queries.',
                    offset: _scrollOffset,
                    cardIndex: 2,
                  ),
                  const SizedBox(height: 20),

                  // Feature Card 3
                  _build3DFeatureCard(
                    step: 'STEP 3',
                    icon: Icons.badge_outlined,
                    iconColor: AppTheme.statusGreen,
                    title: 'Profile Credentials Registration',
                    description: 'Enter your phone number, name, user ID, and password. No complex certifications required for small roadside vendors!',
                    offset: _scrollOffset,
                    cardIndex: 3,
                  ),
                  const SizedBox(height: 20),

                  // Feature Card 4
                  _build3DFeatureCard(
                    step: 'STEP 4',
                    icon: Icons.dashboard_customize_outlined,
                    iconColor: AppTheme.primaryOrange,
                    title: 'Role Dashboard & Live Operations',
                    description: 'Access customer cart maps, vendor live location stream toggles, or the admin query resolution center.',
                    offset: _scrollOffset,
                    cardIndex: 4,
                  ),
                  const SizedBox(height: 40),

                  // Final CTA Container
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E1E2D), Color(0xFF2A1B16)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Ready to Get Started?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Launch the SpotCart Multi-Role Portal and sign in now.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _proceedToLoginPortal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryOrange,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Launch SpotCart Portal Now',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DFeatureCard({
    required String step,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required double offset,
    required int cardIndex,
  }) {
    final tiltAngle = math.sin((offset * 0.002) + cardIndex) * 0.05;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(tiltAngle),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF161622),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
