import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vendor_detail_screen.dart';
import '../../map/controllers/map_controller.dart';
import '../../../theme.dart';
import '../../../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onMapToggle;

  const CustomerHomeScreen({super.key, required this.onMapToggle});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  String _selectedFilter = 'All';

  // Realistic Tamil Nadu street food vendors mock database
  final List<UserModel> _allMockVendors = [
    UserModel(
      id: 'mock_vendor_2',
      phoneNumber: '+91 99999 88888',
      role: 'vendor',
      name: 'Spicy Fish Tacos Truck',
      isOnline: true,
      location: const GeoPoint(13.040, 80.170),
      lastUpdated: DateTime.now(),
    ),
    UserModel(
      id: 'mock_vendor_3',
      phoneNumber: '+91 88888 77777',
      role: 'vendor',
      name: 'Earthy Green Fruit Stand',
      isOnline: true,
      location: const GeoPoint(13.038, 80.168),
      lastUpdated: DateTime.now(),
    ),
    UserModel(
      id: 'mock_vendor_4',
      phoneNumber: '+91 77777 66666',
      role: 'vendor',
      name: 'Annapoorani Tiffin Stall',
      isOnline: true,
      location: const GeoPoint(13.045, 80.175),
      lastUpdated: DateTime.now(),
    ),
    UserModel(
      id: 'mock_vendor_5',
      phoneNumber: '+91 66666 55555',
      role: 'vendor',
      name: 'Selvam Fast Food (Kothu Parotta)',
      isOnline: true,
      location: const GeoPoint(13.035, 80.162),
      lastUpdated: DateTime.now(),
    ),
    UserModel(
      id: 'mock_vendor_6',
      phoneNumber: '+91 55555 44444',
      role: 'vendor',
      name: 'Bhai Shawarma & Juice',
      isOnline: true,
      location: const GeoPoint(13.042, 80.172),
      lastUpdated: DateTime.now(),
    ),
    UserModel(
      id: 'mock_vendor_7',
      phoneNumber: '+91 44444 33333',
      role: 'vendor',
      name: 'Mani\'s Tea & Vadai Shop',
      isOnline: true,
      location: const GeoPoint(13.039, 80.166),
      lastUpdated: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final userPositionAsync = ref.watch(customerLocationProvider);
    final userPos = userPositionAsync.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filterChips = [
      'All',
      'Open Now',
      'Under ₹100',
      'Tea',
      'Shawarma',
      'Dosa',
      'Fast Food',
      'Juice',
      'Night Food',
      'Veg',
      'Non Veg'
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onMapToggle,
        icon: const Icon(Icons.map_outlined),
        label: const Text('Map View'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT LOCATION',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: AppTheme.primaryOrange),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  userPos != null ? 'Anna Nagar, Chennai' : 'Fetching location...',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.notifications_none, size: 20),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search dishes, vendors, or areas...',
                    filled: true,
                    fillColor: isDark ? AppTheme.darkCard : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // FILTER CHIPS
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filterChips.length,
                  itemBuilder: (context, index) {
                    final chip = filterChips[index];
                    final isSelected = _selectedFilter == chip;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(chip),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryOrange,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          setState(() {
                            _selectedFilter = chip;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 1: TRENDING
              _buildSectionHeader('Trending Near You'),
              const SizedBox(height: 12),
              _buildHorizVendorList(_allMockVendors.sublist(0, 3)),
              const SizedBox(height: 24),

              // SECTION 2: LIVE NEAR YOU
              _buildSectionHeader('Live Near You'),
              const SizedBox(height: 12),
              _buildHorizVendorList(_allMockVendors.sublist(3, 6)),
              const SizedBox(height: 24),

              // SECTION 3: TODAY'S SPECIALS
              _buildSectionHeader('Today\'s Specials'),
              const SizedBox(height: 12),
              _buildHorizVendorList([_allMockVendors[0], _allMockVendors[2], _allMockVendors[4]]),
              const SizedBox(height: 24),

              // SECTION 4: POPULAR
              _buildSectionHeader('Popular In Your Area'),
              const SizedBox(height: 12),
              _buildHorizVendorList([_allMockVendors[1], _allMockVendors[3], _allMockVendors[5]]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const Text(
            'See All',
            style: TextStyle(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizVendorList(List<UserModel> vendors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 175,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => VendorDetailScreen(vendor: vendor),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              vendor.name ?? 'Street Cart',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.statusGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'OPEN',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.statusGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Dosa, Idli & Tamil Nadu Tiffin Stalls',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppTheme.ratingYellow, size: 16),
                          const SizedBox(width: 4),
                          const Text('4.5', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 12),
                          Icon(Icons.location_on, color: Colors.grey.shade400, size: 16),
                          const SizedBox(width: 4),
                          const Text('230m away', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Last updated 10 mins ago',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
