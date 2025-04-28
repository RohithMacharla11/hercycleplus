# 🌸 HerCycle+ Connect

HerCycle+ Connect is a revolutionary women’s health companion app designed for women aged 15–45. It seamlessly integrates cycle tracking, fertility insights, mental wellness, sexual health support, and expert teleconsultations into a single, AI-powered platform. 

Say goodbye to fragmented care—HerCycle+ Connect empowers women to take control of their physical, emotional, and reproductive wellbeing with confidence and ease.

---

# 📋 Table of Contents

- [About the App](#-about-the-app)
- [Key Features](#-key-features)
- [Screenshots](#-screenshots)
- [Getting Started](#-getting-started)
- [Technology Stack](#-technology-stack)
- [Development Challenges](#-development-challenges)
- [Future Roadmap](#-future-roadmap)
- [Contributing](#-contributing)
- [Team](#-team)
- [Demo](#-demo)
- [License](#-license)

---

# 🌟 About the App

HerCycle+ Connect addresses the challenge of fragmented women's health apps by offering a **unified, intelligent platform**. Unlike standalone period trackers or wellness tools, it provides a **holistic experience tailored to each user's health journey**.

- **Purpose**: Empower women with personalized health insights and a supportive community.
- **Target Audience**: Women aged 15–45 seeking comprehensive health management.
- **Core Values**: Privacy, compassion, and empowerment.

> _"A safe space where women feel heard, understood, and empowered to manage their body, mind, and wellbeing holistically."_

---

# ✅ Key Features

## Core Features

- **AI-Powered Cycle & Fertility Tracker**: Predicts periods, ovulation, PMS, and pain likelihood (including PCOS cases). Syncs with Fitbit and Oura Ring. 🗓️
- **Symptom-to-Solution Navigator**: Log symptoms and receive tailored wellness suggestions. 💡
- **Virtual Wellness Room**: Guided meditations, breathwork, and journaling for mental health. 🧘‍♀️
- **Cycle-Syncing Health Hub**: Personalized nutrition, workout, and sleep plans based on your cycle. 🍗🏋️‍♀️
- **Anonymous Expert Q&A**: Ask sensitive questions anonymously to experts (OB-GYNs, therapists, nutritionists). ❓
- **Community Circles**: Join groups like "PCOS Warriors" and "Fertility Friends" for sharing and support. 👥
- **SOS Mode**: Emergency alerts for severe pain or emotional crises. ⚠️

## Bonus Features

- **Red Alert AI**: Predicts cramps or hormonal shifts and suggests preparation steps. ⚠️
- **Cycle-Linked Smart Calendar**: Suggests optimal days for different activities based on hormonal cycles. 🗓️
- **Period Product Marketplace**: Shop eco-friendly products curated to your needs. 🛒

---

## 📸 Screenshots

Explore the intuitive UI of HerCycle+ Connect:

### Logo
| HerCycle+ Connect Logo |
|:----------------------:|
| <img src="./assets/logo.png" width="300" alt="HerCycle+ Connect Logo"> |

### App Screens
| Home Screen Top | Home Screen Bottom | Cycle Screen Top | Cycle Screen Bottom |
|:---------------:|:------------------:|:----------------:|:-------------------:|
| <img src="./screenshots/Home_TOP.jpg" width="200" alt="Home Screen Top"> | <img src="./screenshots/Home_Bottom.jpg" width="200" alt="Home Screen Bottom"> | <img src="./screenshots/Cycle_Top.jpg" width="200" alt="Cycle Screen Top"> | <img src="./screenshots/Cycle_Bottom.jpg" width="200" alt="Cycle Screen Bottom"> |

| Wellness Screen Top | Wellness Screen Bottom | ChatBot Screen | Community Screen |
|:-------------------:|:----------------------:|:--------------:|:----------------:|
| <img src="./screenshots/wellness_timer.jpg" width="200" alt="Wellness Screen Top"> | <img src="./screenshots/Wellness_recomendation.jpg" width="200" alt="Wellness Screen Bottom"> | <img src="./screenshots/AI.jpg" width="200" alt="ChatBot Screen"> | <img src="./screenshots/Community.jpg" width="200" alt="Community Screen"> |

| Shop Screen | Shop Screen Bottom | Profile Screen Top | Profile Screen Bottom |
|:-----------:|:------------------:|:------------------:|:---------------------:|
| <img src="./screenshots/Shop.jpg" width="200" alt="Shop Screen"> | <img src="./screenshots/Home_Bottom.jpg" width="200" alt="Shop Screen Bottom"> | <img src="./screenshots/profileTop.jpg" width="200" alt="Profile Screen Top"> | <img src="./screenshots/profile_Bottom.jpg" width="200" alt="Profile Screen Bottom"> |
---

# 🚀 Getting Started

Follow these steps to set up and run HerCycle+ Connect locally:

## Prerequisites

- **Flutter**: 3.0.0+ (Check with `flutter doctor`)
- **Dart**: Included with Flutter
- **Firebase Account**: For Authentication, Firestore, Cloud Messaging
- **IDE**: VS Code or Android Studio
- **Git**: For cloning
- **Optional**: Fitbit/Oura Ring API keys

## Installation Steps

```bash
git clone https://github.com/Harshavardhanjakku/HerCycleConnect.git
cd HerCycleConnect
flutter pub get
```

### Configure Firebase

- Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
- Add Android/iOS apps and download:
  - `google-services.json` → `android/app/`
  - `GoogleService-Info.plist` → `ios/Runner/`
- Enable services:
  - Authentication (Email/Password, Google Sign-In)
  - Firestore
  - Cloud Functions
  - Cloud Messaging

### Set Up Assets

- Place images inside the `images/` folder:
  - `womens_health.jpg`
  - `pocs.jpg`
  - `mental_wellness.jpg`
  - `nutrition_fitness.jpg`

- Verify in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - images/womens_health.jpg
    - images/pocs.jpg
    - images/mental_wellness.jpg
    - images/nutrition_fitness.jpg
```

### Run the App

- **Windows**:

```bash
flutter run -d windows
```

- **Android/iOS**:

```bash
flutter run -d emulator
```

---

# 🛠️ Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Authentication, Firestore, Functions, Messaging)
- **Wearable Integration**: Fitbit API, Oura Ring API
- **AI/NLP**: Custom Cloud Functions
- **Key Packages**:
  - `firebase_auth`
  - `cloud_firestore`
  - `firebase_messaging`
  - `workmanager`

---

# 🧺 Development Challenges

| Challenge                  | Solution                                    |
|-----------------------------|---------------------------------------------|
| Battery Efficiency         | Used `WorkManager` for selective sync      |
| API Integration             | Centralized API handler                    |
| Emotionally Sensitive UX   | Cycle-aware, color-dynamic UI               |
| Chatbot Accuracy            | NLU filters + fallback to human experts    |

---

# 🌍 Future Roadmap

- **Advanced AI**: Smarter cycle prediction and condition detection (e.g., PCOS, Endometriosis).
- **Wearable Expansion**: Support for Apple Watch, Garmin, and others.
- **Telehealth**: Video consultations, prescription delivery.
- **Globalization**: Multilingual support (Spanish, Hindi, French).
- **Community**: AI-driven recommendations for circles and moderation.
- **Mental Health**: Emotional AI journal and guided tracks.
- **Security**: HIPAA-compliant encryption and scalable backend architecture.

---

# 🤝 Contributing

We welcome contributions! 🌟

1. Fork the repository.
2. Create your feature branch: 

```bash
git checkout -b feature/YourFeature
```

3. Commit your changes:

```bash
git commit -m "Add YourFeature"
```

4. Push to the branch:

```bash
git push origin feature/YourFeature
```

5. Open a pull request.

See `CONTRIBUTING.md` for more details.

---

# 👥 Team

| Name | Email | GitHub Profile |
|:-----|:------|:---------------|
| Macharla Rohith | macharlarohith111@gmail.com | [RohithMacharla11](https://github.com/RohithMacharla11) |
| Vangala Shiva Chaithanya | vangalashivachaithanya@gmail.com | [Shiva-vangala](https://github.com/Shiva-vangala) |
| Jakku Harshavardhan | jakkuharshavardhan2004@gmail.com | [Harshavardhanjakku](https://github.com/Harshavardhanjakku) |
| Mulagundla Srinitha | mulagundlasrinitha@gmail.com | [MulagundlaSrinitha](https://github.com/MulagundlaSrinitha) |


# 📜 License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

# 🌟 Empowering women, one cycle at a time. 🌟
