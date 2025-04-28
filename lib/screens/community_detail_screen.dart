import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityDetailScreen extends StatefulWidget {
  final String communityTitle;
  final String communityDescription;
  final String communityImage;

  const CommunityDetailScreen({
    required this.communityTitle,
    required this.communityDescription,
    required this.communityImage,
  });

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  List<String> posts = [];
  TextEditingController _postController = TextEditingController();
  int members = 0;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadMembers();
  }

  Future<void> _loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedPosts = prefs.getStringList('${widget.communityTitle}_posts');
    if (savedPosts != null) {
      setState(() {
        posts = savedPosts;
      });
    }
  }

  Future<void> _loadMembers() async {
    final prefs = await SharedPreferences.getInstance();
    int memberCount = prefs.getInt('${widget.communityTitle}_members') ?? 1;
    setState(() {
      members = memberCount;
    });
  }

  Future<void> _addPost(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      posts.add(text.trim());
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('${widget.communityTitle}_posts', posts);

    _postController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.communityTitle),
        backgroundColor: Colors.pink.shade100,
      ),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            child: Image.asset(
              widget.communityImage,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.communityDescription,
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 10),
                Text('Members: $members',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 20),
                TextField(
                  controller: _postController,
                  decoration: InputDecoration(
                    labelText: 'Share something...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _addPost(_postController.text),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.message),
                  title: Text(posts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
