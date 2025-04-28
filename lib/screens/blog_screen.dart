import 'package:flutter/material.dart';

// Blog Post Model
class BlogPost {
  final String title;
  final String imageUrl;
  final String shortDescription;
  final String fullContent;

  BlogPost({
    required this.title,
    required this.imageUrl,
    required this.shortDescription,
    required this.fullContent,
  });
}

// Updated Blog Posts with Local Assets
final List<BlogPost> blogPosts = [
  BlogPost(
    title: "Understanding Your Menstrual Cycle",
    imageUrl: "assets/images/blog-1.png",
    shortDescription: "Learn the phases of your menstrual cycle and how they impact your body and mood.",
    fullContent: "The menstrual cycle is a natural process that occurs in the female reproductive system, typically lasting about 28 days, though it can vary. It consists of four main phases: the menstrual phase, follicular phase, ovulation, and luteal phase. During the menstrual phase, the uterine lining sheds, leading to menstruation. The follicular phase involves the growth of follicles in the ovaries, preparing an egg for release. Ovulation occurs mid-cycle, where a mature egg is released, ready for fertilization. The luteal phase follows, preparing the body for potential pregnancy, but if no fertilization occurs, the cycle restarts. Understanding these phases can help you manage symptoms like mood swings, cramps, and fatigue, empowering you to take charge of your health.",
  ),
  BlogPost(
    title: "Nutrition Tips for Hormonal Balance",
    imageUrl: "assets/images/blog-2.png",
    shortDescription: "Discover foods that support hormonal health and simple dietary changes.",
    fullContent: "Maintaining hormonal balance is key to overall well-being, especially for women navigating their menstrual cycles. Incorporating nutrient-rich foods can make a big difference. Start with healthy fats like avocados, nuts, and olive oil, which support hormone production. Leafy greens such as spinach and kale provide magnesium, helping reduce stress hormones like cortisol. Protein sources like eggs, fish, and legumes stabilize blood sugar, preventing hormonal spikes. Avoid processed sugars and caffeine, which can exacerbate hormonal imbalances. Additionally, staying hydrated and getting enough sleep are crucial. Small, consistent dietary changes can help you feel your best throughout your cycle.",
  ),
  BlogPost(
    title: "Managing PCOS: A Holistic Approach",
    imageUrl: "assets/images/blog-3.png",
    shortDescription: "Explore lifestyle changes and support for managing PCOS effectively.",
    fullContent: "Polycystic Ovary Syndrome (PCOS) affects many women, causing irregular periods, weight gain, and hormonal imbalances. A holistic approach can help manage symptoms effectively. Start with a balanced diet rich in whole foods—focus on low-glycemic-index foods like vegetables, whole grains, and lean proteins to manage insulin levels, which are often elevated in PCOS. Regular exercise, such as yoga or strength training, can improve insulin sensitivity and reduce stress. Stress management techniques like meditation or journaling are also beneficial, as stress can worsen symptoms. Additionally, consider consulting a healthcare provider for medical options like metformin or hormonal treatments, and connect with a supportive community to share experiences and tips.",
  ),
];

// Blog Screen
class BlogScreen extends StatelessWidget {
  const BlogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simple Blog"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: blogPosts.length,
        itemBuilder: (context, index) {
          return BlogPostCard(post: blogPosts[index]);
        },
      ),
    );
  }
}

// Blog Post Card
class BlogPostCard extends StatelessWidget {
  final BlogPost post;

  const BlogPostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clickable Image
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => BlogDetailDialog(post: post),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  post.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              post.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            // Short Description
            Text(
              post.shortDescription,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Blog Detail Dialog
class BlogDetailDialog extends StatelessWidget {
  final BlogPost post;

  const BlogDetailDialog({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                post.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  post.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Full Content
              Text(
                post.fullContent,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              // Close Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}