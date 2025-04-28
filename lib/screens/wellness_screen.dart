import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Define colors directly to avoid dependency on AppColors
const Color deepCharcoal = Color(0xFF2F2F2F);
const Color sageGreen = Color(0xFFA8B5A2);
const Color softTeal = Color(0xFFB2DFDB);
const Color warmBeige = Color(0xFFF5E8C7);
const Color forestTeal = Color(0xFF2E7D32);

// Layout widget for consistent padding
class Layout extends StatelessWidget {
  final Widget child;

  const Layout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: child,
    );
  }
}

// WellnessCard for category items
class WellnessCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final Color borderColor;

  const WellnessCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: borderColor.withOpacity(0.2),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: deepCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
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

// VirtualWellnessRoom for breathing exercises
class VirtualWellnessRoom extends StatefulWidget {
  const VirtualWellnessRoom({super.key});

  @override
  State<VirtualWellnessRoom> createState() => _VirtualWellnessRoomState();
}

class _VirtualWellnessRoomState extends State<VirtualWellnessRoom> with SingleTickerProviderStateMixin {
  bool _showTimer = false;
  bool _showBreathing = false;
  Timer? _timer;
  int _seconds = 171;
  String _breathingPhase = 'Inhale for 4s';
  Timer? _breathingTimer;
  int _breathingSeconds = 4;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _showTimer = true;
      _showBreathing = false;
      _seconds = 171;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _timer?.cancel();
          _showTimer = false;
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _timer?.cancel();
    });
  }

  void _resetTimer() {
    setState(() {
      _timer?.cancel();
      _seconds = 171;
      _startTimer();
    });
  }

  void _startBreathing() {
    setState(() {
      _showTimer = false;
      _showBreathing = true;
      _breathingPhase = 'Inhale for 4s';
      _breathingSeconds = 4;
    });
    _breathingTimer?.cancel();
    _breathingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _breathingSeconds--;
        if (_breathingSeconds <= 0) {
          if (_breathingPhase == 'Inhale for 4s') {
            _breathingPhase = 'Hold for 4s';
            _breathingSeconds = 4;
          } else if (_breathingPhase == 'Hold for 4s') {
            _breathingPhase = 'Exhale for 4s';
            _breathingSeconds = 4;
          } else {
            _breathingPhase = 'Inhale for 4s';
            _breathingSeconds = 4;
          }
        }
      });
    });
  }

  void _showPopup(String message, Color color) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), entry.remove);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Virtual Wellness Room',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: deepCharcoal),
            ),
            const SizedBox(height: 16),
            if (_showTimer)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Text(
                      '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}',
                      style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: deepCharcoal),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _pauseTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: deepCharcoal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text('Pause', style: GoogleFonts.poppins()),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _resetTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: deepCharcoal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text('Reset', style: GoogleFonts.poppins()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (_showBreathing)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [softTeal, sageGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    Text(
                      'Breathing Space',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: deepCharcoal),
                    ),
                    const SizedBox(height: 16),
                    ScaleTransition(
                      scale: _animation,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(colors: [Colors.white, sageGreen]),
                          boxShadow: [BoxShadow(color: sageGreen.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _breathingPhase,
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: deepCharcoal),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_breathingSeconds',
                      style: GoogleFonts.poppins(fontSize: 32, color: deepCharcoal),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_showTimer) {
                    _showTimer = false;
                    _timer?.cancel();
                  } else {
                    _startTimer();
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: deepCharcoal, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3-Minute Breathing Space',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A quick 3-Minute meditation to center yourself',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startBreathing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sageGreen,
                      foregroundColor: deepCharcoal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Breathing Exercise', style: GoogleFonts.poppins(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showPopup('Finding Someone', forestTeal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: forestTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Talk to Someone', style: GoogleFonts.poppins(fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showPopup('Help is on the way', Colors.red),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning, size: 20),
                  const SizedBox(width: 8),
                  Text('SOS Mode', style: GoogleFonts.poppins(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SymptomNavigator for symptom-based solutions
class SymptomNavigator extends StatefulWidget {
  const SymptomNavigator({super.key});

  @override
  State<SymptomNavigator> createState() => _SymptomNavigatorState();
}

class _SymptomNavigatorState extends State<SymptomNavigator> {
  String? _selectedSymptom;

  final Map<String, List<Map<String, String>>> _solutions = {
    'Cramps': [
      {'emoji': '🔥', 'title': 'Heat Therapy', 'description': 'Apply a heating pad to your lower abdomen for 15-20 minutes.'},
      {'emoji': '🧘‍♀️', 'title': 'Gentle Stretching', 'description': 'Try child\'s pose or cat-cow stretches to relieve tension.'},
      {'emoji': '🍌', 'title': 'Magnesium Foods', 'description': 'Dark chocolate, bananas, and almonds can help relieve cramps.'},
    ],
    'Mood Swings': [
      {'emoji': '📓', 'title': '5-Minute Journaling', 'description': 'Write down your thoughts to process emotions.'},
      {'emoji': '🥑', 'title': 'B Vitamin Boost', 'description': 'Foods like avocados and legumes can stabilize mood.'},
      {'emoji': '👁️', 'title': 'Sensory Grounding', 'description': 'Focus on 5 things you can see, 4 touch, 3 hear, 2 smell, 1 taste.'},
    ],
    'Low Energy': [
      {'emoji': '😴', 'title': 'Power Nap', 'description': '20 minutes of rest can restore energy without grogginess.'},
      {'emoji': '🥗', 'title': 'Iron-Rich Snack', 'description': 'Try hummus, spinach, or a small piece of lean meat.'},
      {'emoji': '🚶‍♀️', 'title': 'Gentle Movement', 'description': 'A short walk can increase circulation and energy.'},
    ],
    'Bloating': [
      {'emoji': '🍵', 'title': 'Anti-Inflammatory Tea', 'description': 'Ginger or peppermint tea can reduce gas and bloating.'},
      {'emoji': '🧂', 'title': 'Avoid Salt', 'description': 'Reduce sodium intake to prevent water retention.'},
      {'emoji': '✋', 'title': 'Abdominal Massage', 'description': 'Gentle clockwise massage can help relieve gas.'},
    ],
    'Headache': [
      {'emoji': '💧', 'title': 'Hydration', 'description': 'Drink a full glass of water, as dehydration can cause headaches.'},
      {'emoji': '💆‍♀️', 'title': 'Temple Massage', 'description': 'Massage your temples in small circles for 2 minutes.'},
      {'emoji': '👁️', 'title': 'Eye Rest', 'description': 'Close your eyes and place a cool cloth over them for 10 minutes.'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a symptom to get personalized solutions:',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSymptomButton('Cramps', '🩹'),
            _buildSymptomButton('Mood Swings', '😢'),
            _buildSymptomButton('Low Energy', '⚡'),
            _buildSymptomButton('Bloating', '😷'),
            _buildSymptomButton('Headache', '🤕'),
          ],
        ),
        if (_selectedSymptom != null) ...[
          const SizedBox(height: 24),
          Text(
            'Solutions for $_selectedSymptom',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: deepCharcoal),
          ),
          const SizedBox(height: 16),
          ..._solutions[_selectedSymptom]!.map((solution) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(solution['emoji']!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            solution['title']!,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: deepCharcoal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            solution['description']!,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: sageGreen, borderRadius: BorderRadius.circular(16)),
                child: Text(
                  '$_selectedSymptom Selected',
                  style: GoogleFonts.poppins(fontSize: 14, color: deepCharcoal),
                ),
              ),
              Text(
                'Here are some solutions that might help you feel better.',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSymptomButton(String label, String emoji) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSymptom = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedSymptom == label ? sageGreen : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 14, color: deepCharcoal),
            ),
          ],
        ),
      ),
    );
  }
}

// WellnessScreen main widget
class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _wellnessCategories = [
    {
      'id': 'mindfulness',
      'items': [
        {'title': '3-Minute Breathing Space', 'description': 'A quick meditation to center yourself.', 'icon': '🧘‍♀️', 'color': softTeal},
        {'title': 'Body Scan Practice', 'description': 'Release tension with this guided relaxation technique.', 'icon': '✨', 'color': sageGreen},
        {'title': 'Affirmations', 'description': 'Positive statements to boost your confidence and mood.', 'icon': '💫', 'color': forestTeal},
      ],
    },
    {
      'id': 'nutrition',
      'items': [
        {'title': 'Follicular Phase Foods', 'description': 'Foods that support estrogen production and energy.', 'icon': '🥗', 'color': sageGreen},
        {'title': 'Magnesium-Rich Recipe', 'description': 'Help reduce cramps with this delicious smoothie.', 'icon': '🥤', 'color': forestTeal},
        {'title': 'Iron Boosters', 'description': 'Foods to prevent fatigue during your period.', 'icon': '🍲', 'color': softTeal},
      ],
    },
    {
      'id': 'movement',
      'items': [
        {'title': 'Low-Impact Cardio', 'description': '15-minute workout that\'s gentle on your joints.', 'icon': '🚶‍♀️', 'color': forestTeal},
        {'title': 'Yoga for Cramps', 'description': '10-minute sequence to ease menstrual discomfort.', 'icon': '🧘‍♀️', 'color': sageGreen},
        {'title': 'Energizing Stretch', 'description': '5-minute morning routine to wake up your body.', 'icon': '💪', 'color': softTeal},
      ],
    },
  ];

  final List<Map<String, dynamic>> _checklistItems = [
    {'task': 'Drink 8 glasses of water', 'completed': true},
    {'task': 'Walk 5000 steps', 'completed': false},
    {'task': 'Log your mood', 'completed': true},
    {'task': 'Track menstrual symptoms (if needed)', 'completed': false},
    {'task': 'Eat 2 servings of fruits', 'completed': true},
    {'task': 'Do 10-minute stretching', 'completed': false},
  ];

  int get _completedTasks => _checklistItems.where((item) => item['completed']).length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F5F0), Color(0xFFE0E8E1), Color(0xFFD1D9D4)],
          ),
        ),
        child: Layout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stay Active, Stay Strong! Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stay Active, Stay Strong!',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: deepCharcoal),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Today\'s Activity',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: deepCharcoal),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _activityItem(Icons.directions_walk, '4500', 'steps', sageGreen),
                          _activityItem(Icons.fitness_center, '20', 'min', forestTeal),
                          _activityItem(Icons.local_fire_department, '320', 'cal', deepCharcoal),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Weekly Goal Progress',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: deepCharcoal),
                      ),
                      const SizedBox(height: 12),
                      _progressItem('Steps walked: 25000 / 50000', 25000 / 50000),
                      const SizedBox(height: 12),
                      _progressItem('Workouts completed: 3 / 5', 3 / 5),
                      const SizedBox(height: 24),
                      Text(
                        'Workout Plans',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: deepCharcoal),
                      ),
                      const SizedBox(height: 12),
                      _workoutPlanCard(Icons.accessibility_new, 'Stretching routines', softTeal),
                      const SizedBox(height: 8),
                      _workoutPlanCard(Icons.self_improvement, 'Yoga for period pain', sageGreen),
                      const SizedBox(height: 8),
                      _workoutPlanCard(Icons.home, 'Home workouts (No equipment)', forestTeal),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quick Workout Logging',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: deepCharcoal),
                          ),
                          ElevatedButton(
                            onPressed: () {}, // TODO: Implement add workout functionality
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sageGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.add, size: 16),
                                const SizedBox(width: 4),
                                Text('Add Workout', style: GoogleFonts.poppins()),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'AI Recommendations',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: deepCharcoal),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: sageGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: sageGreen),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb_outline, color: sageGreen, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Low activity today, try a 10-min walk!',
                                style: GoogleFonts.poppins(fontSize: 14, color: deepCharcoal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Daily Health Checklist Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Daily Health Checklist',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: deepCharcoal),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Small steps, big changes.',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: _completedTasks / _checklistItems.length,
                                strokeWidth: 10,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation(sageGreen),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'You’ve completed',
                                  style: GoogleFonts.poppins(fontSize: 14, color: deepCharcoal),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '$_completedTasks/${_checklistItems.length}',
                                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: deepCharcoal),
                                ),
                                Text(
                                  'tasks today!',
                                  style: GoogleFonts.poppins(fontSize: 14, color: deepCharcoal),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._checklistItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: item['completed'],
                                  onChanged: (value) => setState(() => item['completed'] = value!),
                                  activeColor: sageGreen,
                                  checkColor: Colors.white,
                                ),
                                Expanded(
                                  child: Text(
                                    item['task'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: deepCharcoal,
                                      decoration: item['completed'] ? TextDecoration.lineThrough : null,
                                      decorationColor: sageGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add your own item...',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: sageGreen),
                            onPressed: () {}, // TODO: Implement add custom item functionality
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Every small effort matters',
                            style: GoogleFonts.poppins(fontSize: 14, color: sageGreen, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(width: 4),
                          const Text('✨', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Cycle-Synced Wellness Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [softTeal, sageGreen],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Cycle-Synced Wellness',
                            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: deepCharcoal),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Personalized recommendations for your follicular phase',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            labelColor: deepCharcoal,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: deepCharcoal,
                            tabs: const [
                              Tab(text: 'Mind'),
                              Tab(text: 'Nutrition'),
                              Tab(text: 'Movement'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 300,
                            child: TabBarView(
                              controller: _tabController,
                              children: _wellnessCategories.map((category) {
                                return ListView.separated(
                                  itemCount: category['items'].length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (_, index) {
                                    final item = category['items'][index];
                                    return WellnessCard(
                                      title: item['title'],
                                      description: item['description'],
                                      icon: item['icon'],
                                      borderColor: item['color'],
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Virtual Wellness Room
              const VirtualWellnessRoom(),
              const SizedBox(height: 24),

              // Symptom Navigator
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Symptom Navigator',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: deepCharcoal),
                      ),
                      const SizedBox(height: 16),
                      const SymptomNavigator(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Support Section
              Container(
                decoration: BoxDecoration(
                  color: warmBeige,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Need Support?',
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: deepCharcoal),
                        ),
                        TextButton(
                          onPressed: () {}, // TODO: Implement View All action
                          child: Text(
                            'View All',
                            style: GoogleFonts.poppins(fontSize: 14, color: forestTeal, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSupportButton(
                      '💬',
                      'Talk to a Professional',
                      'Access our network of verified experts',
                      deepCharcoal,
                      Colors.white,
                      Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(height: 12),
                    _buildSupportButton(
                      '❓',
                      'Ask Anonymous Question',
                      'Get answers from gynecologists & experts',
                      sageGreen.withOpacity(0.8),
                      deepCharcoal,
                      deepCharcoal.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: deepCharcoal),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _progressItem(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: deepCharcoal),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation(sageGreen),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _workoutPlanCard(IconData icon, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14, color: deepCharcoal),
            ),
          ),
          const Icon(Icons.chevron_right, color: deepCharcoal),
        ],
      ),
    );
  }

  Widget _buildSupportButton(String icon, String title, String description, Color bgColor, Color textColor, Color iconBgColor) {
    return InkWell(
      onTap: () {}, // TODO: Implement action
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor,
              ),
              child: Center(child: Text(icon, style: TextStyle(fontSize: 20, color: textColor))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.poppins(fontSize: 12, color: textColor.withOpacity(0.8)),
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