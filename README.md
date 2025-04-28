HerCycle+ Connect

HerCycle+ Connect is a unified women’s health companion app designed for women aged 15 to 45. It integrates cycle tracking, fertility insights, mental wellness, sexual health support, and expert teleconsultations into one intelligent, AI-powered platform. The app addresses the problem of fragmented care by offering a seamless, personalized health experience, empowering women to manage their physical, emotional, and reproductive wellbeing with confidence.
Table of Contents

Introduction
Features
Screenshots
Setup Instructions
Technology Stack
Development Challenges
Future Enhancements
Contributing
Team
Demo
License

Introduction
Despite the availability of period trackers, wellness apps, and forums, no single platform provides a holistic, integrated approach to women’s health. HerCycle+ Connect fills this gap by offering a unified ecosystem that combines:

Cycle & Fertility Tracking: AI-powered predictions for periods, ovulation, and symptoms, even for conditions like PCOS.
Mental Wellness: Guided meditations, emotional journaling, and mental health support.
Sexual Health: Anonymous Q&A with experts and safe community spaces.
Personalized Insights: Nutrition, workouts, and sleep recommendations tailored to your menstrual cycle phase.
Expert Access: Direct consultations with OB-GYNs, therapists, and nutritionists.

Our vision is to create a safe, supportive space where women feel heard, understood, and empowered to manage their health holistically.
Features
Core Features

AI-Powered Cycle & Fertility TrackerPredicts periods, ovulation, PMS intensity, and pain likelihood, with support for PCOS. Syncs with wearables like Fitbit and Oura Ring.
Symptom-to-Solution NavigatorLog symptoms (cramps, bloating, mood swings) and receive tailored wellness tips (yoga, nutrition, hydration).
Virtual Wellness RoomAccess 3–5 minute guided meditations, breathwork, journaling, and mental health resources.
Cycle-Syncing Health HubPersonalized nutrition, workout, hydration, and sleep recommendations based on your cycle phase.
Anonymous Expert Q&AAsk sensitive questions to verified OB-GYNs, therapists, and nutritionists, with chatbot support for instant answers.
Community CirclesSafe, moderated spaces like “PCOS Warriors,” “First Period Support,” and “Fertility Friends” for sharing and support.
SOS ModeEmergency alerts for severe period pain or emotional crises, notifying saved contacts or connecting to mental health resources.

Bonus Features

Red Alert AIPredicts upcoming cramps or hormonal shifts, reminding users to prepare (e.g., heat pads, hydration).
Cycle-Linked Smart CalendarSuggests optimal days for workouts, socializing, rest, or focus based on hormone levels.
Period Product MarketplacePersonalized recommendations and shopping for eco-friendly pads, cups, and tampons.

Screenshots
Below are screenshots showcasing key features of HerCycle+ Connect:








App Logo
Cycle Tracker Screen










Community Circle Screen
Virtual Wellness Room Screen









Feature Badge


Note: Replace the placeholder screenshot paths (screenshots/cycle_tracker.png, etc.) with actual images after uploading them to your repository.
Setup Instructions
Follow these steps to set up and run HerCycle+ Connect locally.
Prerequisites

Flutter: Version 3.0.0 or higher (run flutter doctor to verify).
Dart: Included with Flutter.
Firebase Account: For authentication, Firestore, and Cloud Messaging.
IDE: VS Code or Android Studio recommended.
Git: For cloning the repository.
Wearable APIs: Optional, for Fitbit/Oura Ring integration (API keys required).

Steps

Clone the Repository:
git clone https://github.com/Harshavardhanjakku/HerCycleConnect.git
cd HerCycleConnect


Install Dependencies:
flutter pub get


Set Up Firebase:

Create a Firebase project at console.firebase.google.com.
Add an Android and/or iOS app to your Firebase project.
Download the google-services.json (Android) or GoogleService-Info.plist (iOS) and place them in:
Android: android/app/
iOS: ios/Runner/


Enable Firebase Authentication (Email/Password, Google Sign-In).
Set up Firestore Database and Cloud Functions.
Configure Firebase Cloud Messaging for notifications.


Configure Assets:

Place the following image files in the images/ folder:
womens_health.jpg
pocs.jpg
mental_wellness.jpg
nutrition_fitness.jpg


Verify the pubspec.yaml includes:flutter:
  assets:
    - images/womens_health.jpg
    - images/pocs.jpg
    - images/mental_wellness.jpg
    - images/nutrition_fitness.jpg


If images are in assets/images/, update paths in pubspec.yaml and code files (community_screen.dart, community_detail_screen.dart) accordingly.


Move Project (Optional):

If the project is in a OneDrive folder, move it to a non-synced directory to avoid build issues:move "C:\Users\Rohith Macharla\OneDrive\Desktop\Project\HerCycleConnect" "C:\Users\Rohith Macharla\Desktop\HerCycleConnect"




Run the App:

For Windows:flutter run -d windows


For Android/iOS emulator:flutter run -d emulator





Troubleshooting

Asset Error: If you see No file or variants found for asset: images/womens_health.jpg:
Confirm the images exist in images/.
Check pubspec.yaml for correct paths and indentation.
Run flutter clean and flutter pub get.


NuGet/MSBuild Errors:
Install NuGet: Download from nuget.org and add to PATH.
Verify Visual Studio Build Tools 2019+ with C++ Desktop Development workload.


Firebase Issues:
Ensure google-services.json/GoogleService-Info.plist is correctly placed.
Check Firebase console for enabled services.



Technology Stack

Frontend: Flutter (Dart) for cross-platform UI/UX.
Backend: Firebase (Authentication, Firestore, Cloud Functions, Cloud Messaging).
Wearable Integration: Fitbit and Oura Ring APIs for health metrics.
AI/NLP: Custom Cloud Functions for cycle predictions and chatbot.
Packages:
firebase_auth
cloud_firestore
firebase_messaging
workmanager (for background sync)
Others for UI and API handling.



Development Challenges

Battery Efficiency:
Problem: Real-time sync drained battery.
Solution: Used WorkManager for selective background sync and optimized Firebase listeners.


API Integration:
Problem: Complex authentication for Fitbit/Oura Ring APIs.
Solution: Centralized API handler to standardize calls and error handling.


Emotionally Sensitive UX:
Problem: Creating a non-clinical, welcoming UI.
Solution: Cycle-aware UI with dynamic colors and beta testing for feedback.


Chatbot Accuracy:
Problem: Handling vague or off-topic questions.
Solution: NLU filters and fallback to human experts.



Future Enhancements

Advanced AI: Smarter recommendations and early detection of conditions like PCOS.
Wearable Expansion: Support for Apple Watch, Garmin, etc.
Telehealth: Video consultations and prescription delivery.
Globalization: Multilingual support (Spanish, Hindi, French).
Community: AI-driven circle recommendations and moderator tools.
Mental Health: Emotional AI journal and specialized tracks (grief, burnout).
Security: HIPAA-compliant encryption and scalable serverless backend.

Contributing
We welcome contributions! To contribute:

Fork the repository.
Create a feature branch (git checkout -b feature/YourFeature).
Commit changes (git commit -m "Add YourFeature").
Push to the branch (git push origin feature/YourFeature).
Open a Pull Request.

Please follow our Code of Conduct and report issues via Issues.
Team



Name
Email
GitHub Profile



Vangala Shiva Chaithanya
vangalashivachaithanya@gmail.com
Shiva-vangala


Macharla Rohith
macharlarohith111@gmail.com
RohithMacharla11


Jakku Harshavardhan
jakkuharshavardhan2004@gmail.com
Harshavardhanjakku


Mulagundla Srinitha
mulagundlasrinitha@gmail.com
MulagundlaSrinitha


Demo
Watch a short demo of HerCycle+ Connect:Demo Video
License
This project is licensed under the MIT License - see the LICENSE file for details.
