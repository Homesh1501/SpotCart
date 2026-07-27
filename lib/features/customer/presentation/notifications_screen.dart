import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme.dart';

enum AlertType { all, arrivals, stock, deals }

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final AlertType type;
  final String vendorName;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    required this.vendorName,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      description: description,
      timestamp: timestamp,
      type: type,
      vendorName: vendorName,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  AlertType _selectedFilter = AlertType.all;
  
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Vendor Arrived Nearby! 🚚',
      description: 'Annapoorani Tiffin Stall is now LIVE 120m away in T-Nagar. Open for hot Idlis and Crispy Dosa!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: AlertType.arrivals,
      vendorName: 'Annapoorani Tiffin Stall',
    ),
    NotificationItem(
      id: '2',
      title: 'Item Sold Out 🚫',
      description: 'Mani\'s Tea & Vadai Shop just marked "Masaal Vadai" as Sold Out for today.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      type: AlertType.stock,
      vendorName: 'Mani\'s Tea & Vadai Shop',
    ),
    NotificationItem(
      id: '3',
      title: 'Today\'s Special Offer 🍛',
      description: 'Selvam Fast Food added a special: Special Chilli Parotta for only ₹120!',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      type: AlertType.deals,
      vendorName: 'Selvam Fast Food',
    ),
    NotificationItem(
      id: '4',
      title: 'Vendor Went Offline 👋',
      description: 'Karthi Soup Shop has closed streaming and is heading home for the day.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: AlertType.arrivals,
      vendorName: 'Karthi Soup Shop',
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Fresh Stock Updated! 🥤',
      description: 'Madurai Jil Jil Jigarthanda updated stock: Fresh Jigarthanda and Rose Milk are back!',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      type: AlertType.stock,
      vendorName: 'Madurai Jil Jil Jigarthanda',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final filteredNotifications = _notifications.where((item) {
      if (_selectedFilter == AlertType.all) return true;
      return item.type == _selectedFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Feed & Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read_outlined),
            onPressed: () {
              setState(() {
                for (var i = 0; i < _notifications.length; i++) {
                  _notifications[i] = _notifications[i].copyWith(isRead: true);
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All alerts marked as read')),
              );
            },
            tooltip: 'Mark all read',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(AlertType.all, 'All Alerts', Icons.all_inbox_outlined),
                  const SizedBox(width: 8),
                  _buildFilterChip(AlertType.arrivals, 'Arrivals', Icons.directions_run_outlined),
                  const SizedBox(width: 8),
                  _buildFilterChip(AlertType.stock, 'Availability', Icons.inventory_2_outlined),
                  const SizedBox(width: 8),
                  _buildFilterChip(AlertType.deals, 'Specials & Deals', Icons.local_offer_outlined),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No alerts found',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'You\'ll get notified when vendors near you update status.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final item = filteredNotifications[index];
                      return _buildNotificationCard(item, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(AlertType type, String label, IconData icon) {
    final isSelected = _selectedFilter == type;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppTheme.primaryOrange,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          setState(() {
            _selectedFilter = type;
          });
        }
      },
      selectedColor: AppTheme.primaryOrange,
      backgroundColor: Colors.transparent,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item, bool isDark) {
    Color typeColor;
    IconData typeIcon;
    switch (item.type) {
      case AlertType.arrivals:
        typeColor = AppTheme.statusGreen;
        typeIcon = Icons.location_on;
        break;
      case AlertType.stock:
        typeColor = AppTheme.dangerRed;
        typeIcon = Icons.inventory_2;
        break;
      case AlertType.deals:
        typeColor = AppTheme.ratingYellow;
        typeIcon = Icons.local_offer;
        break;
      default:
        typeColor = AppTheme.primaryOrange;
        typeIcon = Icons.notifications;
    }

    final String timeAgo = _getTimeAgo(item.timestamp);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.dangerRed,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeWhere((n) => n.id == item.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alert from ${item.vendorName} cleared'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _notifications.insert(0, item);
                });
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: item.isRead ? 0 : 2,
        color: item.isRead
            ? (isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade100)
            : Theme.of(context).cardTheme.color,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              final index = _notifications.indexWhere((n) => n.id == item.id);
              if (index != -1) {
                _notifications[index] = _notifications[index].copyWith(isRead: true);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon column
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 20),
                ),
                const SizedBox(width: 14),
                
                // Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            timeAgo,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? Colors.grey.shade300 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
