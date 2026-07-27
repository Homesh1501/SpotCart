import 'package:flutter/material.dart';
import 'location_selector_screen.dart';
import '../../../theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      title: 'Discover Moving Food Spots',
      description: 'Find active roadside pushcarts, tiffin stalls, tea shops, and food trucks moving through Chennai streets in real-time.',
      icon: Icons.local_shipping_outlined,
      gradientColors: [Colors.orange.shade800, Colors.orange.shade400],
      citySceneText: 'Chennai Streets',
    ),
    OnboardingSlideData(
      title: 'See Live Timings & Locations',
      description: 'Check active coordinates, operational hours, and when the vendor was last updated to catch the cart before it moves.',
      icon: Icons.map_outlined,
      gradientColors: [Color(0xFF22C55E), Color(0xFF86EFAC)],
      citySceneText: 'Live Spot Mapping',
    ),
    OnboardingSlideData(
      title: 'View Menus & Sold-Out Items',
      description: 'Browse the active menu card, highlight today\'s specials, and instantly see what dishes are already sold out for the day.',
      icon: Icons.restaurant_menu,
      gradientColors: [Color(0xFFF5B301), Color(0xFFFDE047)],
      citySceneText: 'Street Food Menu',
    ),
    OnboardingSlideData(
      title: 'Follow Favorite Carts',
      description: 'Get push alerts the moment your favorite Dosa or Shawarma vendor arrives in your area, updates timings, or posts specials.',
      icon: Icons.notifications_active_outlined,
      gradientColors: [Color(0xFFDC4C4C), Color(0xFFFCA5A5)],
      citySceneText: 'Real-Time Alerts',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : AppTheme.lightTextDark),
          onPressed: () => Navigator.of(context).pop(), // Returns to Prototype Hub
        ),
        actions: [
          TextButton(
            onPressed: () => _goToLocationSelector(),
            child: const Text(
              'Skip',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Simulated High-Fidelity Illustration Card
                      Container(
                        height: MediaQuery.of(context).size.height * 0.35,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: slide.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: slide.gradientColors.first.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Abstract graphics
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 30,
                              bottom: -30,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                            ),
                            // Central Scene Display
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(slide.icon, size: 90, color: Colors.white),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      slide.citySceneText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Slide Title
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 26,
                              color: isDark ? Colors.white : AppTheme.lightTextDark,
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Slide Description
                      Text(
                        slide.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              height: 1.45,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Indicators & Navigation Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dots Indicator
                Row(
                  children: List.generate(
                    _slides.length,
                    (index) => Container(
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppTheme.primaryOrange : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                // Next/Get Started Button
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _goToLocationSelector();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToLocationSelector() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LocationSelectorScreen()),
    );
  }
}

class OnboardingSlideData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String citySceneText;

  OnboardingSlideData({
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradientColors,
    required String citySceneText,
  })  : title = title,
        description = description,
        icon = icon,
        gradientColors = gradientColors,
        citySceneText = citySceneText;
}
