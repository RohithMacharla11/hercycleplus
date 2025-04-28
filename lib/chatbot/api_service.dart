import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiKey = 'AIzaSyC3FtlNO5dTI9oYu11JlWsx0Ftia0TqPvM'; // Replace with your key
  static const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey';

  static Future<String> sendMessage(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": userMessage}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final reply = decoded['candidates'][0]['content']['parts'][0]['text'];
        return reply;
      } else {
        return "Oops, there was an error. Please try again.";
      }
    } catch (e) {
      return "Error occurred: $e";
    }
  }
}
