import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../../models/user_model.dart';
import '../../../models/menu_item_model.dart';
import '../../dashboard/controllers/menu_controller.dart';
import '../../../theme.dart';

class VendorDetailScreen extends ConsumerStatefulWidget {
  final UserModel vendor;

  const VendorDetailScreen({super.key, required this.vendor});

  @override
  ConsumerState<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends ConsumerState<VendorDetailScreen> {
  bool _isFollowing = false;
  double _trustAccuracyScore = 94.0; // Mock starting accuracy score

  // List of mock reviews
  final List<MockReviewData> _mockReviews = [
    MockReviewData(
      userName: 'Karthik S.',
      rating: 5,
      text: 'Best Dosa around Anna Nagar! Very hygienic and the pricing is unbeatable. Highly recommended.',
      tags: ['Tasty', 'Budget', 'Hygienic'],
      time: '2 hours ago',
    ),
    MockReviewData(
      userName: 'Priya Rajan',
      rating: 4,
      text: 'Location is very accurate. Found them exactly near the library corner. Podi Dosa was amazing!',
      tags: ['Tasty', 'Fast Service'],
      time: '1 day ago',
    ),
  ];

  void _submitReview(double rating, String text, List<String> tags, bool locAccurate, bool timeAccurate) {
    setState(() {
      _mockReviews.insert(
        0,
        MockReviewData(
          userName: 'You',
          rating: rating.round(),
          text: text,
          tags: tags,
          time: 'Just now',
        ),
      );
      
      // Dynamic simulated recalculation of trust score based on survey responses
      if (locAccurate && timeAccurate) {
        _trustAccuracyScore = ((_trustAccuracyScore * 20) + 100) / 21;
      } else {
        _trustAccuracyScore = ((_trustAccuracyScore * 20) + 50) / 21;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you! Review and Trust survey submitted.'),
        backgroundColor: AppTheme.statusGreen,
      ),
    );
  }

  void _openAddReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddReviewBottomSheet(onSubmit: _submitReview),
    );
  }

  Future<void> _launchMapDirections() async {
    if (widget.vendor.location == null) return;
    final lat = widget.vendor.location!.latitude;
    final lng = widget.vendor.location!.longitude;
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    
    try {
      final googleUri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(googleUri)) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch maps URL';
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItemsAsync = ref.watch(vendorMenuItemsProvider(widget.vendor.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Banner Sliver AppBar
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryOrange, Color(0xFFC43E00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.storefront,
                    size: 80,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ),
          
          // Vendor Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title + Verified Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.vendor.name ?? 'Street Cart Vendor',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.verified, color: AppTheme.statusGreen, size: 20),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.statusGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: AppTheme.statusGreen, size: 8),
                            SizedBox(width: 6),
                            Text(
                              'OPEN NOW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.statusGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Trust Accuracy Badge Card
                  Card(
                    color: AppTheme.primaryOrange.withOpacity(0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppTheme.primaryOrange.withOpacity(0.2)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user, color: AppTheme.primaryOrange, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Accuracy Rating: ${_trustAccuracyScore.toStringAsFixed(0)}% verified by local foodies',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Detail list items
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text('Timings: 6:00 PM - 11:30 PM', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.my_location, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Location: Near Anna Nagar Bus Depot, Chennai',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Follow, Navigate Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _launchMapDirections,
                          icon: const Icon(Icons.navigation_outlined),
                          label: const Text('Get Directions'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isFollowing = !_isFollowing;
                          });
                        },
                        icon: Icon(_isFollowing ? Icons.favorite : Icons.favorite_border),
                        label: Text(_isFollowing ? 'Following' : 'Follow'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _isFollowing ? AppTheme.primaryOrange : AppTheme.primaryOrange,
                          side: BorderSide(color: AppTheme.primaryOrange.withOpacity(0.4)),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 48),
                  
                  // Active Specials & Dishes Section
                  Text(
                    'Active Menu Items',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  // Menu Items Query
                  menuItemsAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text('No menu items listed by vendor.', style: TextStyle(color: Colors.grey)),
                          ),
                        );
                      }
                      
                      final specials = items.where((i) => i.isTodaySpecial).toList();
                      final available = items.where((i) => !i.isTodaySpecial).toList();
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (specials.isNotEmpty) ...[
                            const Text('TODAY\'S SPECIALS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
                            const SizedBox(height: 8),
                            ...specials.map((item) => _MenuItemCard(item: item, isSpecial: true)),
                            const SizedBox(height: 16),
                          ],
                          if (available.isNotEmpty) ...[
                            const Text('AVAILABLE ITEMS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
                            const SizedBox(height: 8),
                            ...available.map((item) => _MenuItemCard(item: item, isSpecial: false)),
                          ],
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error loading menu: $err')),
                  ),
                  
                  const Divider(height: 48),
                  
                  // Reviews Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Community Reviews',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: _openAddReviewSheet,
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Add Review'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Review Lists
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _mockReviews.length,
                    itemBuilder: (context, index) {
                      final rev = _mockReviews[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(rev.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(rev.time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star,
                                    size: 16,
                                    color: i < rev.rating ? AppTheme.ratingYellow : Colors.grey.shade300,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(rev.text, style: const TextStyle(fontSize: 13, height: 1.4)),
                              if (rev.tags.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  children: rev.tags
                                      .map(
                                        (t) => Chip(
                                          label: Text(t, style: const TextStyle(fontSize: 10)),
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final bool isSpecial;

  const _MenuItemCard({required this.item, required this.isSpecial});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: isSpecial && !item.isSoldOut ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 10),
      color: item.isSoldOut
          ? (isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade100)
          : Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSpecial && !item.isSoldOut
            ? const BorderSide(color: AppTheme.primaryOrange, width: 1.5)
            : BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Opacity(
          opacity: item.isSoldOut ? 0.4 : 1.0,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fastfood, color: AppTheme.primaryOrange),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: item.isSoldOut ? TextDecoration.lineThrough : null,
                  color: item.isSoldOut ? Colors.grey : null,
                ),
              ),
            ),
            if (item.isSoldOut)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.dangerRed.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SOLD OUT',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dangerRed,
                  ),
                ),
              ),
          ],
        ),
        subtitle: item.description != null && item.description!.isNotEmpty
            ? Text(
                item.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: item.isSoldOut ? Colors.grey : null,
                ),
              )
            : null,
        trailing: Text(
          '₹${item.price.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: item.isSoldOut 
                ? Colors.grey 
                : (isSpecial ? AppTheme.primaryOrange : Colors.brown.shade800),
          ),
        ),
      ),
    );
  }
}

class MockReviewData {
  final String userName;
  final int rating;
  final String text;
  final List<String> tags;
  final String time;

  MockReviewData({
    required this.userName,
    required this.rating,
    required this.text,
    required this.tags,
    required this.time,
  });
}

class _AddReviewBottomSheet extends StatefulWidget {
  final Function(double rating, String text, List<String> tags, bool locAccurate, bool timeAccurate) onSubmit;

  const _AddReviewBottomSheet({required this.onSubmit});

  @override
  State<_AddReviewBottomSheet> createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<_AddReviewBottomSheet> {
  double _rating = 5.0;
  final _reviewController = TextEditingController();
  final List<String> _selectedTags = [];
  bool _isLocationAccurate = true;
  bool _isTimingAccurate = true;

  final List<String> _tags = ['Tasty', 'Budget', 'Hygienic', 'Worth It', 'Fast Service'];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Review & Verify Trust',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 16),
            
            // Rating stars slider/row
            const Text('Rating', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _rating,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              activeColor: AppTheme.ratingYellow,
              label: '${_rating.round()} Stars',
              onChanged: (val) {
                setState(() {
                  _rating = val;
                });
              },
            ),
            
            // Review Text
            TextFormField(
              controller: _reviewController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Review Text',
                hintText: 'Share your street food experience...',
              ),
            ),
            const SizedBox(height: 16),
            
            // Tags selector
            const Text('Select Tags', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryOrange.withOpacity(0.12),
                  checkmarkColor: AppTheme.primaryOrange,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryOrange : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            
            // Trust Questions Section
            const Text('Verification Poll', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Is the location accurate?'),
                Switch(
                  value: _isLocationAccurate,
                  activeColor: AppTheme.statusGreen,
                  onChanged: (val) {
                    setState(() {
                      _isLocationAccurate = val;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Are the timings accurate?'),
                Switch(
                  value: _isTimingAccurate,
                  activeColor: AppTheme.statusGreen,
                  onChanged: (val) {
                    setState(() {
                      _isTimingAccurate = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Submit Button
            ElevatedButton(
              onPressed: () {
                widget.onSubmit(
                  _rating,
                  _reviewController.text.trim(),
                  _selectedTags,
                  _isLocationAccurate,
                  _isTimingAccurate,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
