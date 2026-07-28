import 'package:flutter/material.dart';
import '../../../theme.dart';
import '../../profile/presentation/profile_screen.dart';

class SupportQuery {
  final String id;
  final String senderName;
  final String senderRole; // 'Customer' or 'Vendor'
  final String senderPhone;
  final String category;
  final String subject;
  final String message;
  final String timestamp;
  final String priority; // 'High', 'Medium', 'Low'
  String status; // 'Open', 'In Progress', 'Resolved'
  List<QueryMessage> replies;

  SupportQuery({
    required this.id,
    required this.senderName,
    required this.senderRole,
    required this.senderPhone,
    required this.category,
    required this.subject,
    required this.message,
    required this.timestamp,
    required this.priority,
    this.status = 'Open',
    required this.replies,
  });
}

class QueryMessage {
  final String sender;
  final String text;
  final String time;
  final bool isAdmin;

  QueryMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.isAdmin,
  });
}

class AdminQueriesTab extends StatefulWidget {
  const AdminQueriesTab({super.key});

  @override
  State<AdminQueriesTab> createState() => _AdminQueriesTabState();
}

class _AdminQueriesTabState extends State<AdminQueriesTab> {
  String _selectedRoleFilter = 'All'; // 'All', 'Customer', 'Vendor'
  String _selectedStatusFilter = 'All'; // 'All', 'Open', 'In Progress', 'Resolved'

  final List<SupportQuery> _queries = [
    SupportQuery(
      id: 'TICK-8021',
      senderName: 'Priya Sundaram',
      senderRole: 'Customer',
      senderPhone: '+91 98401 22334',
      category: 'Order & Location Dispute',
      subject: 'Cart was 200m away from pinned location on map',
      message: 'I visited Marina Beach to find Chennai Super Crispy Dosa, but the cart was moved 200 meters down near the lighthouse. Please update location calibration.',
      timestamp: '15 mins ago',
      priority: 'High',
      status: 'Open',
      replies: [
        QueryMessage(
          sender: 'Priya Sundaram',
          text: 'I visited Marina Beach to find Chennai Super Crispy Dosa, but the cart was moved 200 meters down near the lighthouse.',
          time: '10:45 AM',
          isAdmin: false,
        ),
      ],
    ),
    SupportQuery(
      id: 'TICK-7994',
      senderName: 'Ramu K. (Ramu\'s Evening Bajji Stall)',
      senderRole: 'Vendor',
      senderPhone: '+91 97910 88776',
      category: 'Vendor Menu Approval',
      subject: 'New Special Combo menu items pending approval',
      message: 'I added "Special Onion Mirchi Bajji Combo ₹60" to my menu list yesterday. Kindly approve it so customers can view it online.',
      timestamp: '1 hour ago',
      priority: 'Medium',
      status: 'In Progress',
      replies: [
        QueryMessage(
          sender: 'Ramu K.',
          text: 'I added "Special Onion Mirchi Bajji Combo ₹60" to my menu list yesterday. Kindly approve it so customers can view it online.',
          time: '09:30 AM',
          isAdmin: false,
        ),
        QueryMessage(
          sender: 'Admin Support',
          text: 'Hello Ramu! We are reviewing your food hygiene and price details now.',
          time: '09:50 AM',
          isAdmin: true,
        ),
      ],
    ),
    SupportQuery(
      id: 'TICK-7850',
      senderName: 'Karthik Subramanian',
      senderRole: 'Customer',
      senderPhone: '+91 94432 11990',
      category: 'UPI Refund Issue',
      subject: 'Amount debited twice during GPay payment',
      message: 'My GPay account was debited ₹120 twice for order #SC-9041 at Madurai Jigarthanda Hub. Requesting refund for the duplicate transaction.',
      timestamp: '3 hours ago',
      priority: 'High',
      status: 'Open',
      replies: [
        QueryMessage(
          sender: 'Karthik Subramanian',
          text: 'My GPay account was debited ₹120 twice for order #SC-9041. Requesting refund.',
          time: '08:15 AM',
          isAdmin: false,
        ),
      ],
    ),
    SupportQuery(
      id: 'TICK-7620',
      senderName: 'Murugan P. (Madurai Kari Dosai)',
      senderRole: 'Vendor',
      senderPhone: '+91 98840 55112',
      category: 'GPS Live Location Sync',
      subject: 'GPS marker icon flickering on live map',
      message: 'When I move my cart near T.Nagar bus stand, the green dot flickers between blue and green. Please calibrate my device GPS signal.',
      timestamp: 'Yesterday',
      priority: 'Low',
      status: 'Resolved',
      replies: [
        QueryMessage(
          sender: 'Murugan P.',
          text: 'GPS marker icon flickering on live map near T.Nagar bus stand.',
          time: 'Yesterday 4:00 PM',
          isAdmin: false,
        ),
        QueryMessage(
          sender: 'Admin Technical Support',
          text: 'We refreshed your device telemetry channel. High-accuracy continuous stream has been activated.',
          time: 'Yesterday 5:10 PM',
          isAdmin: true,
        ),
      ],
    ),
  ];

  List<SupportQuery> get _filteredQueries {
    return _queries.where((q) {
      final matchesRole = _selectedRoleFilter == 'All' || q.senderRole == _selectedRoleFilter;
      final matchesStatus = _selectedStatusFilter == 'All' || q.status == _selectedStatusFilter;
      return matchesRole && matchesStatus;
    }).toList();
  }

  void _openResolutionModal(SupportQuery query) {
    final replyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  query.id,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryOrange),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: query.senderRole == 'Customer'
                                        ? Colors.blue.withOpacity(0.15)
                                        : Colors.purple.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    query.senderRole,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: query.senderRole == 'Customer' ? Colors.blue : Colors.purple,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'From: ${query.senderName} (${query.senderPhone})',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Query Title & Status Controls
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            query.subject,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Category: ${query.category}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Ticket Status:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              DropdownButton<String>(
                                value: query.status,
                                isDense: true,
                                items: ['Open', 'In Progress', 'Resolved'].map((st) {
                                  return DropdownMenuItem(
                                    value: st,
                                    child: Text(
                                      st,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: st == 'Resolved'
                                            ? AppTheme.statusGreen
                                            : st == 'In Progress'
                                                ? Colors.amber.shade900
                                                : AppTheme.dangerRed,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      query.status = val;
                                    });
                                    setModalState(() {});
                                  }
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Chat/Message Log
                    const Text('Conversation History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: query.replies.length,
                        itemBuilder: (context, idx) {
                          final msg = query.replies[idx];
                          return Align(
                            alignment: msg.isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                              decoration: BoxDecoration(
                                color: msg.isAdmin ? AppTheme.primaryOrange : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.sender,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: msg.isAdmin ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    msg.text,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: msg.isAdmin ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      msg.time,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: msg.isAdmin ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Quick Action Templates
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickResponseChip('✅ Resolved & Pushed Update', () {
                            replyController.text = 'Your request has been resolved successfully by SpotCart Admin team.';
                          }),
                          _buildQuickResponseChip('💳 Refund Processed', () {
                            replyController.text = 'Duplicate payment refunded back to your source bank account within 24 hours.';
                          }),
                          _buildQuickResponseChip('📍 Location Calibrated', () {
                            replyController.text = 'Cart GPS location coordinates updated live on map.';
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Reply Input Box
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: replyController,
                            decoration: InputDecoration(
                              hintText: 'Write admin response to ${query.senderRole}...',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final text = replyController.text.trim();
                            if (text.isNotEmpty) {
                              setState(() {
                                query.replies.add(
                                  QueryMessage(
                                    sender: 'Admin Support',
                                    text: text,
                                    time: 'Just now',
                                    isAdmin: true,
                                  ),
                                );
                                query.status = 'In Progress';
                              });
                              replyController.clear();
                              setModalState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Response dispatched to user!'),
                                  backgroundColor: AppTheme.statusGreen,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryOrange,
                            padding: const EdgeInsets.all(14),
                          ),
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickResponseChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        onPressed: onTap,
        backgroundColor: Colors.grey.shade100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer & Vendor Query Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support ticket queue refreshed')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Role: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'All', label: Text('All')),
                          ButtonSegment(value: 'Customer', label: Text('Customers')),
                          ButtonSegment(value: 'Vendor', label: Text('Vendors')),
                        ],
                        selected: {_selectedRoleFilter},
                        onSelectionChanged: (val) {
                          setState(() {
                            _selectedRoleFilter = val.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 8,
                      children: ['All', 'Open', 'In Progress', 'Resolved'].map((st) {
                        final isSelected = _selectedStatusFilter == st;
                        return ChoiceChip(
                          label: Text(st, style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryOrange.withOpacity(0.2),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedStatusFilter = st;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Query Tickets List
          Expanded(
            child: _filteredQueries.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.headset_mic_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No pending support queries', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('All customer and vendor tickets resolved!', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredQueries.length,
                    itemBuilder: (context, index) {
                      final query = _filteredQueries[index];
                      final isCustomer = query.senderRole == 'Customer';

                      Color statusColor;
                      if (query.status == 'Resolved') {
                        statusColor = AppTheme.statusGreen;
                      } else if (query.status == 'In Progress') {
                        statusColor = Colors.amber.shade900;
                      } else {
                        statusColor = AppTheme.dangerRed;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isCustomer ? Colors.blue.withOpacity(0.12) : Colors.purple.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          query.senderRole,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isCustomer ? Colors.blue.shade800 : Colors.purple.shade800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        query.id,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      query.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                query.subject,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                query.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'By ${query.senderName} • ${query.timestamp}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _openResolutionModal(query),
                                    icon: const Icon(Icons.forum, size: 16),
                                    label: const Text('Solve Query'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryOrange,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
