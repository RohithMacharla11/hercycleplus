import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MoodButton extends StatefulWidget {
  final String mood;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  const MoodButton({
    Key? key,
    required this.mood,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  _MoodButtonState createState() => _MoodButtonState();
}

class _MoodButtonState extends State<MoodButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          ScaleTransition(
            scale: widget.isSelected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
            child: Icon(widget.icon, color: AppColors.deepPlum, size: 40),
          ),
          const SizedBox(height: 8),
          Text(
            widget.mood,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}