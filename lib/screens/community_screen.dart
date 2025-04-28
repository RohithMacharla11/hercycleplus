import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'community_detail_screen.dart';

class Community {
  final String title;
  final String description;
  final String imageUrl;

  Community({required this.title, required this.description, required this.imageUrl});
}

class CommunityScreen extends StatefulWidget {
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<Community> communities = [
    Community(
      title: 'Women\'s Health',
      description: 'A space to discuss wellness, health tips, and everything about your body.',
      imageUrl: 'assets/images',
    ),
    Community(
      title: 'PCOS Support',
      description: 'Connect with others managing PCOS. Share your journey and advice.',
      imageUrl: 'assets/images/pcos.jpg',
    ),
    Community(
      title: 'Mental Wellness',
      description: 'Your safe place to talk about emotional health and self-care.',
      imageUrl: 'assets/images/mental_wellness.jpg',
    ),
    Community(
      title: 'Nutrition & Fitness',
      description: 'Tips on eating well and moving your body mindfully through every phase.',
      imageUrl: 'assets/images/nutrition_fitness.jpg',
    ),
  ];

  Set<String> joinedCommunities = {};

  @override
  void initState() {
    super.initState();
    _loadJoinedCommunities();
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

  Future<void> _saveJoinedCommunities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('joined_communities', joinedCommunities.toList());
  }

  void _onJoinOrNavigate(Community community) async {
    if (joinedCommunities.contains(community.title)) {
      _navigateToDetail(community);
    } else {
      setState(() {
        joinedCommunities.add(community.title);
      });
      await _saveJoinedCommunities();

      final prefs = await SharedPreferences.getInstance();
      int currentMembers = prefs.getInt('${community.title}_members') ?? 0;
      await prefs.setInt('${community.title}_members', currentMembers + 1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You joined ${community.title}!')),
      );
    }
  }

  void _navigateToDetail(Community community) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityDetailScreen(
          communityTitle: community.title,
          communityDescription: community.description,
          communityImage: community.imageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Community'),
        backgroundColor: Colors.pink.shade100,
      ),
      body: ListView.builder(
        itemCount: communities.length,
        itemBuilder: (context, index) {
          final community = communities[index];
          final isJoined = joinedCommunities.contains(community.title);

          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _navigateToDetail(community),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                    child: Image.asset(
                      community.imageUrl,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        community.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _onJoinOrNavigate(community),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isJoined ? Colors.green : Colors.pink.shade200,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(isJoined ? 'View Community' : 'Join Now'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
