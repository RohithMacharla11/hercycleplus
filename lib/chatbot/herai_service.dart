class HerAIService {
  static String generateReply(String input) {
    final lower = input.toLowerCase();

    if (lower.trim().isEmpty || RegExp(r'^[^\w\s]+$').hasMatch(lower)) {
      return "Could you share a bit more so I can help better? 💬";
    }

    final topics = _detectTopics(lower);

    if (topics.isEmpty) {
      return "I'm here to support your women’s health journey 🌷. Let's stay focused on cycles, PCOS, mental health, and wellness!";
    }

    return _buildResponse(topics);
  }

  static List<String> _detectTopics(String text) {
    List<String> topics = [];

    if (text.contains('cycle') || text.contains('period')) topics.add('cycle');
    if (text.contains('pcos')) topics.add('pcos');
    if (text.contains('mental') || text.contains('anxiety') || text.contains('stress')) topics.add('mental health');
    if (text.contains('nutrition') || text.contains('food') || text.contains('diet')) topics.add('nutrition');
    if (text.contains('telehealth') || text.contains('appointment') || text.contains('doctor')) topics.add('telehealth');
    if (text.contains('pregnancy') || text.contains('fertility')) topics.add('pregnancy');
    if (text.contains('wellness') || text.contains('fitness') || text.contains('exercise')) topics.add('wellness');

    return topics;
  }

  static String _buildResponse(List<String> topics) {
    if (topics.contains('pcos') && topics.contains('nutrition')) {
      return "Managing PCOS with the right nutrition is crucial 🌸. A diet rich in fiber, lean proteins, and low in refined carbs can help balance hormones.";
    }
    if (topics.contains('pcos')) {
      return "PCOS symptoms may include irregular periods, acne, weight gain, and fertility challenges. Staying active and eating balanced meals can help 💖.";
    }
    if (topics.contains('cycle')) {
      return "Tracking your menstrual cycle helps predict symptoms, fertility windows, and emotional patterns 🌼. Want tips on apps for tracking?";
    }
    if (topics.contains('mental health')) {
      return "Mental health is vital 💖. Practicing mindfulness, deep breathing, and talking to supportive people can uplift your wellness.";
    }
    if (topics.contains('nutrition')) {
      return "A nutritious diet supports hormonal balance 🌱. Focus on whole foods, fruits, vegetables, and stay hydrated.";
    }
    if (topics.contains('telehealth')) {
      return "HerConnect offers telehealth services 📱. You can book consultations with expert women’s health providers easily!";
    }
    if (topics.contains('pregnancy')) {
      return "Fertility and pregnancy wellness starts with good nutrition, rest, and regular checkups 🍼. I'm here if you need advice!";
    }
    if (topics.contains('wellness')) {
      return "Daily moderate exercise, balanced eating, and self-care rituals can enhance your overall wellness 🌟.";
    }

    // fallback
    return "Feel free to ask about cycles, PCOS, mental health, or wellness 🌸.";
  }
}
