import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: AppColors.blushRose,
        foregroundColor: AppColors.deepPlum,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/hero.jpg'),
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  ),
                  color: AppColors.blushRose.withOpacity(0.2),
                ),
                child: Column(
                  children: [
                    Text(
                      'HerCycle+',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: isSmallScreen ? 28 : 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepPlum,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Empowering women to take control of their menstrual health with personalized tracking, insights, and a supportive community.',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        color: AppColors.deepPlum,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Mission
              Text(
                'Our Mission',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: isSmallScreen ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepPlum,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'At HerCycle+, we believe every woman deserves access to tools and knowledge to understand her body. Our mission is to provide a safe, inclusive platform for menstrual health tracking, education, and community support, fostering wellness and empowerment.',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Features
              Text(
                'Our Features',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: isSmallScreen ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepPlum,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  FeatureCard(
                    image: 'assets/images/feature_cycle.jpg',
                    title: 'Cycle Tracking',
                    description: 'Track your menstrual cycle with ease and get personalized predictions.',
                    isSmallScreen: isSmallScreen,
                  ),
                  FeatureCard(
                    image: 'assets/images/feature_insights.jpg',
                    title: 'Health Insights',
                    description: 'Gain insights into your health with data-driven analytics.',
                    isSmallScreen: isSmallScreen,
                  ),
                  FeatureCard(
                    image: 'assets/images/feature_community.jpg',
                    title: 'Community Circles',
                    description: 'Join supportive communities like PCOS Support and Mental Wellness.',
                    isSmallScreen: isSmallScreen,
                  ),
                  FeatureCard(
                    image: 'assets/images/feature_blogs.jpg',
                    title: 'Educational Blogs',
                    description: 'Read expert articles on women’s health and wellness.',
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Team
              Text(
                'Our Team',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: isSmallScreen ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepPlum,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  TeamMemberCard(
                    image: 'assets/images/team1.jpg',
                    name: 'Rohith Macharla',
                    role: 'Lead Developer',
                    isSmallScreen: isSmallScreen,
                  ),
                  TeamMemberCard(
                    image: 'assets/images/team2.jpg',
                    name: 'Jakku HarahaVardhan',
                    role: 'Lead Developer',
                    isSmallScreen: isSmallScreen,
                  ),
                  TeamMemberCard(
                    image: 'assets/images/team3.jpg',
                    name: 'Shiva Chaitanya',
                    role: 'Lead Developer',
                    isSmallScreen: isSmallScreen,
                  ),
                  TeamMemberCard(
                    image: 'assets/images/team1.jpg',
                    name: 'Srinitha',
                    role: 'Lead Developer',
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final bool isSmallScreen;

  const FeatureCard({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: isSmallScreen ? double.infinity : 250,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                image,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: AppColors.deepPlum,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamMemberCard extends StatelessWidget {
  final String image;
  final String name;
  final String role;
  final bool isSmallScreen;

  const TeamMemberCard({
    Key? key,
    required this.image,
    required this.name,
    required this.role,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: isSmallScreen ? double.infinity : 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: isSmallScreen ? 40 : 50,
              backgroundImage: AssetImage(image),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: AppColors.deepPlum,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              role,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}