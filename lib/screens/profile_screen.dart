import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Added for DateFormat
import '../theme/app_colors.dart';
import 'community_screen.dart';
import 'community_detail_screen.dart';

// Placeholder Layout widget
class Layout extends StatelessWidget {
  final Widget child;

  const Layout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: child,
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Set<String> joinedCommunities = {};
  bool notificationsEnabled = false;
  DateTime? selectedDate;
  bool isPeriod = false;
  List<String> selectedSymptoms = [];
  String? _activeSection; // Tracks which section is visible

  @override
  void initState() {
    super.initState();
    _loadJoinedCommunities();
    _loadNotificationsPreference();
  }

  Future<void> _loadJoinedCommunities() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList('joined_communities');
    if (saved != null) {
      setState(() {
        joinedCommunities = saved.toSet();
      });
    }
  }

  Future<void> _loadNotificationsPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      notificationsEnabled = value;
      _activeSection = null; // Hide notifications section after toggle
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notifications ${value ? 'enabled' : 'disabled'}')),
    );
  }

  Future<Map<String, dynamic>> _getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final age = prefs.getInt('age');
    final gender = prefs.getString('gender');

    if (name != null && age != null && gender != null) {
      return {'name': name, 'age': age, 'gender': gender};
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'name': 'User', 'age': 0, 'gender': 'Unknown'};
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        await prefs.setString('name', data['name'] ?? '');
        await prefs.setInt('age', data['age'] ?? 0);
        await prefs.setString('gender', data['gender'] ?? '');
        return {
          'name': data['name'] ?? user.email?.split('@')[0] ?? 'User',
          'age': data['age'] ?? 0,
          'gender': data['gender'] ?? 'Unknown'
        };
      }
    } catch (e) {
      print('Error fetching user details from Firestore: $e');
    }

    return {
      'name': user.email?.split('@')[0] ?? 'User',
      'age': 0,
      'gender': 'Unknown'
    };
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    if (words[0].length >= 2) {
      return words[0].substring(0, 2).toUpperCase();
    }
    return words[0][0].toUpperCase();
  }

  Future<List<Map<String, dynamic>>> _getCycleLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cycle_logs')
          .orderBy('date', descending: true)
          .limit(30)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching cycle logs: $e');
      return _getSampleCycleLogs();
    }
  }

  List<Map<String, dynamic>> _getSampleCycleLogs() {
    final startDate = DateTime(2025, 4, 1);
    return List.generate(28, (index) {
      final date = startDate.add(Duration(days: index));
      final isPeriod = index >= 0 && index < 5;
      final symptoms = isPeriod
          ? (index == 0 || index == 1
              ? ['Cramps', 'Fatigue']
              : ['Mood Swings'])
          : index == 14
              ? ['Ovulation Pain']
              : [];
      return {
        'date': Timestamp.fromDate(date),
        'isPeriod': isPeriod,
        'symptoms': symptoms,
      };
    });
  }

  Future<Map<String, dynamic>> _getHealthInsights() async {
    final logs = await _getCycleLogs();
    if (logs.isEmpty) {
      return {'avgCycleLength': 28, 'commonSymptoms': []};
    }

    final periodStarts = logs
        .asMap()
        .entries
        .where((entry) => entry.value['isPeriod'] && (entry.key == 0 || !logs[entry.key - 1]['isPeriod']))
        .map((entry) => (entry.value['date'] as Timestamp).toDate())
        .toList();
    double avgCycleLength = 28.0;
    if (periodStarts.length >= 2) {
      final durations = <double>[];
      for (int i = 1; i < periodStarts.length; i++) {
        durations.add(periodStarts[i].difference(periodStarts[i - 1]).inDays.toDouble());
      }
      avgCycleLength = durations.reduce((a, b) => a + b) / durations.length;
    }

    final symptomCounts = <String, int>{};
    for (var log in logs) {
      final symptoms = log['symptoms'] as List<dynamic>;
      for (var symptom in symptoms) {
        symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
      }
    }
    final commonSymptoms = symptomCounts.entries
        .where((entry) => entry.value > 1)
        .map((entry) => entry.key)
        .toList();

    return {
      'avgCycleLength': avgCycleLength.round(),
      'commonSymptoms': commonSymptoms,
    };
  }

  Future<List<Map<String, dynamic>>> _getNotifications() async {
    final logs = await _getCycleLogs();
    if (logs.isEmpty) {
      return [
        {'date': DateTime(2025, 5, 1), 'message': 'Period expected on May 1, 2025'},
        {'date': DateTime(2025, 5, 14), 'message': 'Ovulation predicted on May 14, 2025'},
      ];
    }

    final lastPeriodStart = logs
        .where((log) => log['isPeriod'])
        .map((log) => (log['date'] as Timestamp).toDate())
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final nextPeriod = lastPeriodStart.add(Duration(days: 28));
    final ovulation = lastPeriodStart.add(Duration(days: 14));
    return [
      {'date': nextPeriod, 'message': 'Period expected on ${DateFormat('MMM d, yyyy').format(nextPeriod)}'},
      {'date': ovulation, 'message': 'Ovulation predicted on ${DateFormat('MMM d, yyyy').format(ovulation)}'},
    ];
  }

  Future<void> _logCycleData() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save cycle data')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cycle_logs')
          .doc(selectedDate!.toIso8601String())
          .set({
        'date': Timestamp.fromDate(selectedDate!),
        'isPeriod': isPeriod,
        'symptoms': selectedSymptoms,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cycle data logged successfully')),
      );
      setState(() {
        selectedDate = null;
        isPeriod = false;
        selectedSymptoms.clear();
      });
    } catch (e) {
      print('Error logging cycle data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log cycle data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Layout(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _getUserDetails(),
        builder: (context, userSnapshot) {
          String userName = 'User';
          String initials = 'U';
          String lastSynced = 'Fetching...';
          if (userSnapshot.hasData) {
            userName = userSnapshot.data!['name'];
            initials = _getInitials(userName);
            lastSynced = DateFormat('MMM d, yyyy h:mm a').format(DateTime.now());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepPlum,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: AppColors.deepPlum),
                    onPressed: () {
                      // TODO: Implement settings action
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),

              // Profile card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: isSmallScreen ? 32 : 40,
                        backgroundColor: AppColors.blushRose,
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            color: AppColors.deepPlum,
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      Text(
                        userName,
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepPlum,
                        ),
                      ),
                      Text(
                        'Member since April 2023', // TODO: Dynamize with createdAt
                        style: TextStyle(fontSize: isSmallScreen ? 11 : 12, color: Colors.grey[500]),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      Text(
                        'Last Synced: $lastSynced',
                        style: TextStyle(fontSize: isSmallScreen ? 11 : 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      FutureBuilder<Map<String, dynamic>>(
                        future: _getHealthInsights(),
                        builder: (context, insightsSnapshot) {
                          int avgCycleLength = 28;
                          if (insightsSnapshot.hasData) {
                            avgCycleLength = insightsSnapshot.data!['avgCycleLength'];
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '$avgCycleLength',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.deepPlum,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                  Text(
                                    'Avg Cycle',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 11 : 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '5', // TODO: Compute from logs
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.deepPlum,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                  Text(
                                    'Period Days',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 11 : 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '122', // TODO: Compute from logs
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.deepPlum,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                  Text(
                                    'Insights',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 11 : 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),

              // Action buttons
              Column(
                children: [
                  _buildActionButton(
                    icon: Icons.calendar_today,
                    label: 'Cycle History',
                    backgroundColor: AppColors.softLavender,
                    onTap: () {
                      setState(() {
                        _activeSection = _activeSection == 'cycle_history' ? null : 'cycle_history';
                      });
                    },
                  ),
                  if (_activeSection == 'cycle_history') ...[
                    SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Log Cycle Data',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepPlum,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedDate == null
                                        ? 'Select Date'
                                        : DateFormat('MMM d, yyyy').format(selectedDate!),
                                    style: TextStyle(fontSize: 14, color: AppColors.deepPlum),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.calendar_today, color: AppColors.forestTeal),
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        selectedDate = picked;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            CheckboxListTile(
                              title: Text('Period', style: TextStyle(fontSize: 14)),
                              value: isPeriod,
                              onChanged: (value) {
                                setState(() {
                                  isPeriod = value ?? false;
                                });
                              },
                              activeColor: AppColors.forestTeal,
                            ),
                            Text(
                              'Symptoms',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Wrap(
                              spacing: 8,
                              children: ['Cramps', 'Fatigue', 'Mood Swings', 'Ovulation Pain'].map((symptom) {
                                return ChoiceChip(
                                  label: Text(symptom),
                                  selected: selectedSymptoms.contains(symptom),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedSymptoms.add(symptom);
                                      } else {
                                        selectedSymptoms.remove(symptom);
                                      }
                                    });
                                  },
                                  selectedColor: AppColors.blushRose,
                                  labelStyle: TextStyle(color: AppColors.deepPlum),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _logCycleData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.forestTeal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Log Data'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _getCycleLogs(),
                      builder: (context, logsSnapshot) {
                        if (!logsSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        final logs = logsSnapshot.data!;
                        if (logs.isEmpty) {
                          return Text(
                            'No cycle logs available',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          );
                        }
                        return Container(
                          height: 200,
                          child: ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              final date = (log['date'] as Timestamp).toDate();
                              final isPeriod = log['isPeriod'] as bool;
                              final symptoms = (log['symptoms'] as List<dynamic>).cast<String>();
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: ListTile(
                                  title: Text(
                                    DateFormat('MMM d, yyyy').format(date),
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    isPeriod ? 'Period' : 'Non-Period${symptoms.isNotEmpty ? ': ${symptoms.join(', ')}' : ''}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                  SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.favorite,
                    label: 'Health Insights',
                    backgroundColor: AppColors.blushRose,
                    onTap: () {
                      setState(() {
                        _activeSection = _activeSection == 'health_insights' ? null : 'health_insights';
                      });
                    },
                  ),
                  if (_activeSection == 'health_insights') ...[
                    SizedBox(height: 16),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _getHealthInsights(),
                      builder: (context, insightsSnapshot) {
                        if (!insightsSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        final insights = insightsSnapshot.data!;
                        final commonSymptoms = (insights['commonSymptoms'] as List<dynamic>).cast<String>();
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Average Cycle Length: ${insights['avgCycleLength']} days',
                                  style: TextStyle(fontSize: 14, color: AppColors.deepPlum),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Common Symptoms: ${commonSymptoms.isEmpty ? 'None' : commonSymptoms.join(', ')}',
                                  style: TextStyle(fontSize: 14, color: AppColors.deepPlum),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    backgroundColor: AppColors.forestTeal.withOpacity(0.2),
                    onTap: () {
                      setState(() {
                        _activeSection = _activeSection == 'notifications' ? null : 'notifications';
                      });
                    },
                  ),
                  if (_activeSection == 'notifications') ...[
                    SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cycle Reminders',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepPlum,
                              ),
                            ),
                            SizedBox(height: 8),
                            SwitchListTile(
                              title: Text('Enable Notifications', style: TextStyle(fontSize: 14)),
                              value: notificationsEnabled,
                              onChanged: _toggleNotifications,
                              activeColor: AppColors.forestTeal,
                            ),
                            SizedBox(height: 8),
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: _getNotifications(),
                              builder: (context, notificationsSnapshot) {
                                if (!notificationsSnapshot.hasData) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                final notifications = notificationsSnapshot.data!;
                                return Column(
                                  children: notifications.map((notification) {
                                    final date = notification['date'] as DateTime;
                                    final message = notification['message'] as String;
                                    return ListTile(
                                      leading: Icon(Icons.alarm, color: AppColors.deepPlum),
                                      title: Text(
                                        message,
                                        style: TextStyle(fontSize: 14, color: AppColors.deepPlum),
                                      ),
                                      subtitle: Text(
                                        DateFormat('MMM d, yyyy').format(date),
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.info,
                    label: 'Help & Resources',
                    backgroundColor: AppColors.deepPlum.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        _activeSection = _activeSection == 'help_resources' ? null : 'help_resources';
                      });
                    },
                  ),
                  if (_activeSection == 'help_resources') ...[
                    SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Health Resources in India',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepPlum,
                              ),
                            ),
                            SizedBox(height: 8),
                            ...[
                              'Apollo Hospitals, 21 Greams Lane, Chennai, Tamil Nadu 600006',
                              'Fortis Hospital, Sector 62, Noida, Uttar Pradesh 201301',
                              'AIIMS, Ansari Nagar, New Delhi, Delhi 110029',
                              'Max Super Speciality Hospital, Saket, New Delhi, Delhi 110017',
                              'Lilavati Hospital, Bandra West, Mumbai, Maharashtra 400050',
                            ].map((address) => ListTile(
                                  leading: Icon(Icons.location_on, color: AppColors.deepPlum),
                                  title: Text(
                                    address,
                                    style: TextStyle(fontSize: 14, color: AppColors.deepPlum),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),

              // Community Circles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Community Circles',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepPlum,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CommunityScreen()),
                      );
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: AppColors.forestTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              joinedCommunities.isEmpty
                  ? Column(
                      children: [
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Text(
                          "You haven't joined any community",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CommunityScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.forestTeal,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 24,
                              vertical: isSmallScreen ? 8 : 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Join Community',
                            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                      ],
                    )
                  : Column(
                      children: [
                        if (joinedCommunities.contains("Women's Health"))
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              leading: const Icon(Icons.group, color: AppColors.deepPlum),
                              title: Text(
                                "Women's Health",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.deepPlum,
                                ),
                              ),
                              subtitle: Text(
                                'A space to discuss wellness, health tips, and everything about your body.',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommunityDetailScreen(
                                      communityTitle: "Women's Health",
                                      communityDescription: 'A space to discuss wellness, health tips, and everything about your body.',
                                      communityImage: 'assets/images/womens_health.jpg',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (joinedCommunities.contains('PCOS Support'))
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              leading: const Icon(Icons.group, color: AppColors.deepPlum),
                              title: Text(
                                'PCOS Support',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.deepPlum,
                                ),
                              ),
                              subtitle: Text(
                                'Connect with others managing PCOS. Share your journey and advice.',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommunityDetailScreen(
                                      communityTitle: 'PCOS Support',
                                      communityDescription: 'Connect with others managing PCOS. Share your journey and advice.',
                                      communityImage: 'assets/images/pcos.jpg',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (joinedCommunities.contains('Mental Wellness'))
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              leading: const Icon(Icons.group, color: AppColors.deepPlum),
                              title: Text(
                                'Mental Wellness',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.deepPlum,
                                ),
                              ),
                              subtitle: Text(
                                'Your safe place to talk about emotional health and self-care.',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommunityDetailScreen(
                                      communityTitle: 'Mental Wellness',
                                      communityDescription: 'Your safe place to talk about emotional health and self-care.',
                                      communityImage: 'assets/images/mental_wellness.jpg',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (joinedCommunities.contains('Nutrition & Fitness'))
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              leading: const Icon(Icons.group, color: AppColors.deepPlum),
                              title: Text(
                                'Nutrition & Fitness',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.deepPlum,
                                ),
                              ),
                              subtitle: Text(
                                'Tips on eating well and moving your body mindfully through every phase.',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommunityDetailScreen(
                                      communityTitle: 'Nutrition & Fitness',
                                      communityDescription: 'Tips on eating well and moving your body mindfully through every phase.',
                                      communityImage: 'assets/images/nutrition_fitness.jpg',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
              SizedBox(height: isSmallScreen ? 16 : 24),

              // Invite a Friend button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Invite a Friend action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestTeal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 24,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Invite a Friend',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
              ),
              child: Icon(icon, size: 18, color: AppColors.deepPlum),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: AppColors.deepPlum),
            ),
          ],
        ),
      ),
    );
  }
}