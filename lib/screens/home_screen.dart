import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/mood_button.dart';
import '../widgets/recommendation_card.dart';
import '../chatbot/chat_screen.dart';
import 'community_screen.dart';

// Placeholder Layout widget
class Layout extends StatelessWidget {
  final Widget child;

  const Layout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: child,
    );
  }
}

// WellnessCard widget
class WellnessCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final Color borderColor;

  const WellnessCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [borderColor.withOpacity(0.1), borderColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: borderColor.withOpacity(0.3),
              ),
              child: Center(child: Text(icon, style: TextStyle(fontSize: 20))),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepPlum,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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

// CyclePhaseIndicator widget
class CyclePhaseIndicator extends StatelessWidget {
  final String currentPhase;

  const CyclePhaseIndicator({Key? key, required this.currentPhase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final phases = [
      {'name': 'Menstrual', 'progress': 0.0},
      {'name': 'Follicular', 'progress': 0.25},
      {'name': 'Ovulation', 'progress': 0.5},
      {'name': 'Luteal', 'progress': 1.0},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: phases.map((phase) {
            final isActive = phase['name'] == currentPhase;
            return Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.blushRose : Colors.grey[300],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  phase['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isActive ? AppColors.deepPlum : Colors.grey[500],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        Container(
          height: 2,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: (phases.firstWhere((phase) => phase['name'] == currentPhase)['progress'] as double),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.blushRose, AppColors.softLavender],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// MoodSelector widget
class MoodSelector extends StatefulWidget {
  final Function(String?) onMoodSelected;

  const MoodSelector({Key? key, required this.onMoodSelected}) : super(key: key);

  @override
  _MoodSelectorState createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> with SingleTickerProviderStateMixin {
  String? _selectedMood;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moods = [
      {'name': 'happy', 'emoji': '😊'},
      {'name': 'calm', 'emoji': '😌'},
      {'name': 'tired', 'emoji': '😴'},
      {'name': 'stressed', 'emoji': '😓'},
      {'name': 'sad', 'emoji': '😢'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'How are you feeling today?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.deepPlum,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: moods.map((mood) {
            final isSelected = _selectedMood == mood['name'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMood = mood['name'] as String;
                  widget.onMoodSelected(_selectedMood);
                });
                _animationController.forward(from: 0);
              },
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isSelected ? 1.1 : 1.0,
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppColors.blushRose : Colors.grey[100],
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.blushRose.withOpacity(0.5),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              mood['emoji'] as String,
                              style: TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          (mood['name'] as String).capitalize(),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.deepPlum,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// HomeScreen widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedMood;

  List<Map<String, dynamic>> getRecommendations(String? mood) {
    final Map<String, List<Map<String, dynamic>>> moodRecommendations = {
      'happy': [
        {
          'title': 'Energy-Boosting Walk',
          'description': 'A 20-minute brisk walk to keep your energy high.',
          'icon': '🚶‍♀️',
          'color': AppColors.forestTeal,
        },
        {
          'title': 'Dance Break',
          'description': 'Put on your favorite song and dance for 5 minutes!',
          'icon': '💃',
          'color': AppColors.blushRose,
        },
        {
          'title': 'Hydration Boost',
          'description': 'Drink a glass of infused water with lemon and mint.',
          'icon': '💧',
          'color': AppColors.softLavender,
        },
      ],
      'calm': [
        {
          'title': '5-Minute Meditation',
          'description': 'Deep breathing to maintain your calm state.',
          'icon': '🧘‍♀️',
          'color': AppColors.softLavender,
        },
        {
          'title': 'Nature Sounds',
          'description': 'Listen to calming nature sounds for 10 minutes.',
          'icon': '🌿',
          'color': AppColors.forestTeal,
        },
        {
          'title': 'Herbal Tea',
          'description': 'Sip on chamomile tea to relax.',
          'icon': '🍵',
          'color': AppColors.blushRose,
        },
      ],
      'tired': [
        {
          'title': 'Power Nap',
          'description': 'Take a 20-minute nap to recharge.',
          'icon': '😴',
          'color': AppColors.blushRose,
        },
        {
          'title': 'Gentle Stretching',
          'description': 'Do a 10-minute stretch to wake up your body.',
          'icon': '🧘‍♀️',
          'color': AppColors.softLavender,
        },
        {
          'title': 'Iron-Rich Snack',
          'description': 'Eat spinach or hummus to boost energy.',
          'icon': '🥗',
          'color': AppColors.forestTeal,
        },
      ],
      'stressed': [
        {
          'title': 'Breathing Exercise',
          'description': 'Inhale for 4s, hold for 4s, exhale for 4s.',
          'icon': '🌬️',
          'color': AppColors.softLavender,
        },
        {
          'title': 'Journaling',
          'description': 'Write down your thoughts for 5 minutes.',
          'icon': '📓',
          'color': AppColors.blushRose,
        },
        {
          'title': 'Aromatherapy',
          'description': 'Use lavender essential oil to relax.',
          'icon': '🕯️',
          'color': AppColors.forestTeal,
        },
      ],
      'sad': [
        {
          'title': 'Mood-Lifting Music',
          'description': 'Listen to uplifting music for 10 minutes.',
          'icon': '🎶',
          'color': AppColors.forestTeal,
        },
        {
          'title': 'Connect with a Friend',
          'description': 'Call or message someone who makes you smile.',
          'icon': '📞',
          'color': AppColors.blushRose,
        },
        {
          'title': 'Self-Care Ritual',
          'description': 'Take a warm bath with your favorite scents.',
          'icon': '🛁',
          'color': AppColors.softLavender,
        },
      ],
    };

    return moodRecommendations[mood] ?? [
      {
        'title': 'Follicular Phase Nutrition',
        'description': 'Try incorporating leafy greens and fermented foods to support estrogen metabolism.',
        'icon': '🥗',
        'color': AppColors.forestTeal,
      },
      {
        'title': 'Gentle Movement',
        'description': 'Your energy is rising! Try a light cardio workout or yoga flow today.',
        'icon': '🧘‍♀️',
        'color': AppColors.blushRose,
      },
      {
        'title': '3-Minute Meditation',
        'description': 'Take a moment to breathe and center yourself with this quick practice.',
        'icon': '🌿',
        'color': AppColors.softLavender,
      },
    ];
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

  @override
  Widget build(BuildContext context) {
    const int cycleDay = 14;
    const String cyclePhase = 'Follicular';
    final DateTime currentDate = DateTime.now();
    final DateTime nextPeriod = currentDate.add(Duration(days: 14));
    final int daysUntilNextPeriod = nextPeriod.difference(currentDate).inDays;

    final List<Map<String, dynamic>> wellnessRecommendations = getRecommendations(_selectedMood);

    return Layout(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _getUserDetails(),
        builder: (context, snapshot) {
          String userName = 'User';
          if (snapshot.hasData) {
            userName = snapshot.data!['name'];
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.softLavender.withOpacity(0.3), AppColors.blushRose.withOpacity(0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Welcome, $userName',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepPlum,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your cycle day: $cycleDay',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Cycle',
                            style: TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepPlum,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.softLavender,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Follicular Phase',
                              style: TextStyle(fontSize: 12, color: AppColors.deepPlum),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      CyclePhaseIndicator(currentPhase: cyclePhase),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: AppColors.deepPlum),
                              SizedBox(width: 8),
                              Text(
                                'Next period in $daysUntilNextPeriod days',
                                style: TextStyle(fontSize: 14, color: AppColors.deepPlum),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Implement Log Today action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blushRose,
                              foregroundColor: AppColors.deepPlum,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            child: Text('Log Today', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: MoodSelector(
                    onMoodSelected: (mood) {
                      setState(() {
                        _selectedMood = mood;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'For You Today',
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepPlum,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement View All action
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.forestTeal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: wellnessRecommendations.map((recommendation) {
                      return WellnessCard(
                        title: recommendation['title'],
                        description: recommendation['description'],
                        icon: recommendation['icon'],
                        borderColor: recommendation['color'],
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.blushRose, AppColors.blushRose.withOpacity(0.2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blushRose.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.chat_bubble, size: 28, color: AppColors.deepPlum),
                            const SizedBox(height: 6),
                            const Text(
                              'Ask Question',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.deepPlum,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CommunityScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.softLavender, AppColors.softLavender.withOpacity(0.3)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.softLavender.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.group, size: 28, color: AppColors.deepPlum),
                            const SizedBox(height: 6),
                            const Text(
                              'Join Community',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.deepPlum,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}