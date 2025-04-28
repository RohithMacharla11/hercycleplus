import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';
import '../enums/symptom.dart';
import 'dart:developer' as developer;

enum FlowIntensity { none, light, medium, heavy }

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

class CycleScreen extends StatefulWidget {
  const CycleScreen({Key? key}) : super(key: key);

  @override
  _CycleScreenState createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  late DateTime _selectedDate;
  late List<Symptom> _selectedSymptoms;
  late FlowIntensity _flowIntensity;
  late bool _isRedAlertEnabled;
  late bool isSmallScreen; // Define at class level

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedSymptoms = [];
    _flowIntensity = FlowIntensity.medium;
    _isRedAlertEnabled = true;
    _loadCycleData();
  }

  Future<void> _loadCycleData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = Provider.of<User>(context, listen: false);

      final List<String>? savedSymptoms = prefs.getStringList('selected_symptoms');
      if (savedSymptoms != null && savedSymptoms.isNotEmpty) {
        final loadedSymptoms = savedSymptoms.map((name) {
          try {
            return Symptom.values.firstWhere(
              (symptom) => symptom.name == name,
              orElse: () => Symptom.cramps,
            );
          } catch (e) {
            developer.log('Error mapping symptom: $name, error: $e', name: 'CycleScreen');
            return Symptom.cramps;
          }
        }).toList();
        setState(() {
          _selectedSymptoms = loadedSymptoms;
        });
        user.clearSymptoms();
        for (var symptom in loadedSymptoms) {
          user.toggleSymptom(symptom);
        }
      } else {
        developer.log('No saved symptoms found', name: 'CycleScreen');
      }

      final String? savedFlow = prefs.getString('flow_intensity');
      if (savedFlow != null && savedFlow.isNotEmpty) {
        try {
          final loadedFlow = FlowIntensity.values.firstWhere(
            (flow) => flow.name == savedFlow,
            orElse: () => FlowIntensity.medium,
          );
          setState(() {
            _flowIntensity = loadedFlow;
          });
          user.setFlow(loadedFlow.name);
        } catch (e) {
          developer.log('Error mapping flow intensity: $savedFlow, error: $e', name: 'CycleScreen');
          setState(() {
            _flowIntensity = FlowIntensity.medium;
          });
          user.setFlow(FlowIntensity.medium.name);
        }
      } else {
        developer.log('No saved flow intensity found', name: 'CycleScreen');
      }

      final bool? savedRedAlert = prefs.getBool('red_alert_enabled');
      if (savedRedAlert != null) {
        setState(() {
          _isRedAlertEnabled = savedRedAlert;
        });
      } else {
        developer.log('No saved Red Alert state found', name: 'CycleScreen');
      }
    } catch (e) {
      developer.log('Error loading cycle data: $e', name: 'CycleScreen');
      setState(() {
        _selectedSymptoms = [];
        _flowIntensity = FlowIntensity.medium;
        _isRedAlertEnabled = true;
      });
    }
  }

  Future<void> _saveCycleData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> symptomNames = _selectedSymptoms.map((symptom) => symptom.name).toList();
      await prefs.setStringList('selected_symptoms', symptomNames);
      await prefs.setString('flow_intensity', _flowIntensity.name);
      await prefs.setBool('red_alert_enabled', _isRedAlertEnabled);
      developer.log('Saved cycle data: symptoms=$symptomNames, flow=${_flowIntensity.name}, redAlert=$_isRedAlertEnabled', name: 'CycleScreen');
    } catch (e) {
      developer.log('Error saving cycle data: $e', name: 'CycleScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save cycle data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    });
  }

  void _toggleSymptom(Symptom symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
    });
    final user = Provider.of<User>(context, listen: false);
    user.toggleSymptom(symptom);
    _saveCycleData();
  }

  void _toggleRedAlert() {
    setState(() {
      _isRedAlertEnabled = !_isRedAlertEnabled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isRedAlertEnabled ? 'Red Alert Enabled' : 'Red Alert Disabled'),
        duration: const Duration(seconds: 2),
        backgroundColor: _isRedAlertEnabled ? AppColors.blushRose : Colors.grey[600],
      ),
    );
    _saveCycleData();
  }

  void _saveData() {
    final user = Provider.of<User>(context, listen: false);
    user.setFlow(_flowIntensity.name);
    user.clearSymptoms();
    _selectedSymptoms.forEach((symptom) {
      user.toggleSymptom(symptom);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your cycle data has been saved'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.deepPlum,
      ),
    );
    _saveCycleData();
  }

  Map<String, String> _getCycleStage(int day) {
    if (day <= 5) {
      return {'stage': 'Menstrual', 'emoji': '🩸', 'color': Colors.red.value.toString()};
    } else if (day <= 13) {
      return {'stage': 'Follicular', 'emoji': '🌸', 'color': Colors.pink.value.toString()};
    } else if (day <= 16) {
      return {'stage': 'Ovulation', 'emoji': '🥚', 'color': Colors.blue.value.toString()};
    } else {
      return {'stage': 'Luteal', 'emoji': '🌙', 'color': Colors.purple.value.toString()};
    }
  }

  Widget _buildCalendarCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      color: AppColors.pearlWhite,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: isSmallScreen ? 16 : 18, color: AppColors.deepPlum),
                  onPressed: _previousMonth,
                ),
                Text(
                  '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepPlum,
                      ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, size: isSmallScreen ? 16 : 18, color: AppColors.deepPlum),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Su', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey[700])),
                Text('Mo', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey[700])),
                Text('Tu', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey[700])),
                Text('We', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey[700])),
                Text('Th', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey[700])),
                Text('Fr', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey[700])),
                Text('Sa', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 12),
            _buildCalendar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    const daysInWeek = 7;
    final totalCells = ((lastDayOfMonth.day + firstWeekday) / daysInWeek).ceil() * daysInWeek;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1.0,
      children: List.generate(totalCells, (index) {
        final dayIndex = index - firstWeekday;
        if (dayIndex < 0 || dayIndex >= lastDayOfMonth.day) {
          return const SizedBox.shrink();
        }
        final day = dayIndex + 1;
        final date = DateTime(_selectedDate.year, _selectedDate.month, day);
        final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
        final cycleStage = _getCycleStage(day);
        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isToday ? AppColors.blushRose.withOpacity(0.3) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.blushRose.withOpacity(0.2)),
            ),
            padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0), // Now accessible
            margin: const EdgeInsets.all(2.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    color: isToday ? AppColors.deepPlum : Colors.grey[800],
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: isSmallScreen ? 12 : 14, // Now accessible
                  ),
                ),
                Text(
                  cycleStage['emoji']!,
                  style: TextStyle(fontSize: isSmallScreen ? 10 : 12), // Now accessible
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFlowSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      color: AppColors.pearlWhite,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Period Flow',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepPlum,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: FlowIntensity.values.map((intensity) {
                final dropCount = {
                  FlowIntensity.none: 1,
                  FlowIntensity.light: 2,
                  FlowIntensity.medium: 3,
                  FlowIntensity.heavy: 4,
                }[intensity]!;
                return GestureDetector(
                  onTap: () {
                    setState(() => _flowIntensity = intensity);
                    final user = Provider.of<User>(context, listen: false);
                    user.setFlow(intensity.name);
                    _saveCycleData();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 12, vertical: isSmallScreen ? 8 : 10),
                    decoration: BoxDecoration(
                      color: _flowIntensity == intensity ? AppColors.blushRose : AppColors.pearlWhite,
                      border: Border.all(color: AppColors.blushRose),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blushRose.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(dropCount, (_) => Icon(Icons.water_drop, size: isSmallScreen ? 16 : 18, color: AppColors.deepPlum)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          intensity.name.capitalize,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w500,
                            color: _flowIntensity == intensity ? AppColors.deepPlum : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      color: AppColors.pearlWhite,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track Your Symptoms',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepPlum,
                  ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isSmallScreen ? 3 : 4,
              crossAxisSpacing: isSmallScreen ? 8 : 10,
              mainAxisSpacing: isSmallScreen ? 8 : 10,
              childAspectRatio: isSmallScreen ? 2.0 : 2.5,
              children: Symptom.values.map((symptom) {
                final isSelected = _selectedSymptoms.contains(symptom);
                return GestureDetector(
                  onTap: () => _toggleSymptom(symptom),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.blushRose : AppColors.pearlWhite,
                      border: Border.all(color: AppColors.blushRose),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blushRose.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getSymptomIcon(symptom),
                          size: isSmallScreen ? 16 : 18,
                          color: isSelected ? AppColors.deepPlum : Colors.grey[700],
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            symptom.name.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}').trim().capitalize,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: isSelected ? AppColors.deepPlum : Colors.grey[700],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_selectedSymptoms.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: isSmallScreen ? 12 : 16),
                child: Text(
                  'Selected: ${_selectedSymptoms.map((s) => s.name.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}').trim().capitalize).join(', ')}',
                  style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: AppColors.deepPlum, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getSymptomIcon(Symptom symptom) {
    switch (symptom) {
      case Symptom.cramps:
        return Icons.sick;
      case Symptom.headache:
        return Icons.face;
      case Symptom.bloating:
        return Icons.bubble_chart;
      case Symptom.fatigue:
        return Icons.bedtime;
      case Symptom.acne:
        return Icons.face_retouching_natural;
      case Symptom.backPain:
        return Icons.person;
      case Symptom.breastTenderness:
        return Icons.favorite;
      case Symptom.nausea:
        return Icons.sick;
      default:
        return Icons.help;
    }
  }

  Widget _buildInsightsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      color: AppColors.pearlWhite,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Cycle Insights',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepPlum,
                  ),
            ),
            const SizedBox(height: 20),
            _buildInsightItem('FOLLICULAR PHASE', 'Your estrogen levels are rising, boosting energy and mood.'),
            SizedBox(height: isSmallScreen ? 12 : 16),
            _buildInsightItem('UPCOMING OVULATION', 'Ovulation predicted in 2 days. Expect increased energy and libido.'),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.blushRose, AppColors.blushRose.withOpacity(0.5)]),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12.0),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'RED ALERT: PMS SYMPTOMS PREDICTED\nBased on past cycles, expect mood changes and fatigue in 5-7 days.',
                      style: TextStyle(color: Colors.red[900], fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            _buildInsightItem('WEARABLE INSIGHTS', 'Sleep quality improved by 15% this week. Maintain your bedtime routine.'),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepPlum, fontSize: isSmallScreen ? 14 : 16),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: TextStyle(color: Colors.grey[800], fontSize: isSmallScreen ? 12 : 14),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _saveData,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepPlum,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 24 : 32, vertical: isSmallScreen ? 10 : 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 6,
        ),
        child: Text(
          'SAVE TODAY\'S LOG',
          style: TextStyle(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isSmallScreen = MediaQuery.of(context).size.width < 600; // Compute once in build

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cycle Tracking',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: isSmallScreen ? 20 : 24,
            color: AppColors.deepPlum,
          ),
        ),
        backgroundColor: AppColors.blushRose,
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: _toggleRedAlert,
              child: Row(
                children: [
                  Icon(
                    Icons.notifications,
                    color: _isRedAlertEnabled ? AppColors.deepPlum : Colors.grey[600],
                    size: isSmallScreen ? 20 : 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Red Alert ${_isRedAlertEnabled ? 'ON' : 'OFF'}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w500,
                      color: _isRedAlertEnabled ? AppColors.deepPlum : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Layout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarCard(context),
            const SizedBox(height: 24),
            _buildFlowSection(),
            const SizedBox(height: 24),
            _buildSymptomsSection(),
            const SizedBox(height: 24),
            _buildInsightsSection(),
            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String get capitalize {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}