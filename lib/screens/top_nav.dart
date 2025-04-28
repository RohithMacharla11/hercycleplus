import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'community_screen.dart';
import 'about_us_screen.dart'; // Import detailed AboutUsScreen
import 'contact_us_screen.dart'; // Import detailed ContactUsScreen
import 'blog_screen.dart'; // Import BlogScreen

// Top Navigation Bar Widget
class TopNav extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<int>? onTabSelected; // Callback to update the selected tab

  const TopNav({Key? key, this.onTabSelected}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blushRose,
            ),
            child: const Text(
              'H+',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.deepPlum,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'HerCycle+',
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.deepPlum,
            ),
          ),
        ],
      ),
      actions: [
        if (!isSmallScreen) ...[
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlogScreen()),
              );
            },
            child: const Text(
              'Blogs',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 16,
                color: AppColors.deepPlum,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsScreen()),
              );
            },
            child: const Text(
              'About Us',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 16,
                color: AppColors.deepPlum,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactUsScreen()),
              );
            },
            child: const Text(
              'Contact Us',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 16,
                color: AppColors.deepPlum,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.notifications,
                color: AppColors.deepPlum,
                size: 24,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications tapped')),
                );
              },
            );
          },
        ),
        const SizedBox(width: 8),
        // Profile Button with Dynamic Initials
        FutureBuilder<Map<String, dynamic>>(
          future: _getUserDetails(),
          builder: (context, snapshot) {
            String initials = 'U';
            if (snapshot.hasData) {
              initials = _getInitials(snapshot.data!['name']);
            }
            return GestureDetector(
              onTap: () {
                // Call the callback to switch to the Profile tab (index 4)
                onTabSelected?.call(4); // Profile tab index
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blushRose,
                ),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepPlum,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
      ],
      leading: isSmallScreen
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: AppColors.deepPlum,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Drawer for small screens
class TopNavDrawer extends StatelessWidget {
  const TopNavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.blushRose,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Text(
                    'H+',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepPlum,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'HerCycle+',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepPlum,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text(
              'Blogs',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 16,
                color: AppColors.deepPlum,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlogScreen()),
              );
            },
          ),
          ListTile(
            title: const Text(
              'About Us',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 16,
                color: AppColors.deepPlum,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Contact Us',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 16,
                color: AppColors.deepPlum,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactUsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}