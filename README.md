# 🚧 RoadCare – Road Damage Reporting System

A Flutter-based cross-platform application designed to help users report road damages, track complaint status, and support administrators in managing road maintenance reports.

RoadCare provides a simple and user-friendly platform for reporting road problems such as potholes, cracks, and damaged road surfaces through a mobile or web interface.

---

## 📖 Project Documentation

📄 **[Click here to view the Complete RoadCare Project Documentation (PDF)](./RoadCare.pdf)**

> The complete project report is included in this repository. Click the link above to open the PDF documentation directly on GitHub.

*Note: If your PDF has a different filename or is inside another folder, update the link with its exact relative path.*

---

## ✨ Features

### 👤 User Module
- User Registration and Login
- User Dashboard
- Report Road Damage
- Upload Road Damage Images
- Capture or select images
- GPS-based location details
- Select damage severity
- View My Reports
- Track Report Status
- View Report History
- In-app Notifications
- Submit Feedback
- Manage User Profile
- Application Settings

### 🛠️ Administrator Module
- Admin Login
- Admin Dashboard
- View and Manage Reports
- Search and Filter Reports
- View Report Details
- View Uploaded Images
- View Location Details
- Update Report Status
- Track Status History
- Status Analytics
- Severity Analytics
- Manage Feedback
- Archive and Unarchive Reports

---

## 🖥️ Application Screens

The application contains the following screens:

1. Splash Screen
2. Login Screen
3. Registration Screen
4. User Dashboard
5. Create Road Damage Report
6. Image Selection and Preview
7. Location and Map View
8. My Reports
9. Report Details
10. Status History
11. Notifications
12. Feedback
13. User Profile
14. Settings
15. Admin Login
16. Admin Dashboard
17. Search and Filter Reports
18. Report Status Analytics
19. Report Severity Analytics
20. Admin Report Details
21. Feedback Management
22. Archived Reports

---

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform UI development |
| Dart | Application programming language |
| SQLite | Local database storage |
| Android | Mobile application platform |
| Chrome | Web application platform |
| VS Code | Development environment |

---

## 🗄️ Database Design

RoadCare uses SQLite for local data storage.

The database contains the following main tables:

- `users` – Stores user and administrator information.
- `reports` – Stores road damage report details.
- `report_images` – Stores report image information.
- `status_history` – Maintains report status changes.
- `notifications` – Stores in-app notifications.
- `feedback` – Stores user feedback.

---

## 🔄 Application Workflow

1. The user opens the RoadCare application.
2. The user registers or logs in.
3. The user reaches the dashboard.
4. The user creates a road damage report.
5. The user enters report details, selects severity, adds images, and provides location information.
6. The report is saved in the local database.
7. The user can view submitted reports and track their status.
8. The administrator logs in to manage submitted reports.
9. The administrator reviews reports and updates their status.
10. Users can view the latest report status and history.

---

## 📱 Platform Support

RoadCare is designed to run on:

- **Android:** Mobile application interface.
- **Chrome:** Web application interface.

The interface is designed to adapt to different screen sizes.

---

## 🚀 Getting Started

### Prerequisites

Install the following tools:

- Flutter SDK
- Dart SDK
- Visual Studio Code
- Flutter and Dart VS Code extensions
- Android Studio / Android SDK (for Android execution)
- Google Chrome (for web execution)

### Clone the Repository

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
```

### Navigate to the Project Folder

```bash
cd RoadCare
```

### Install Dependencies

```bash
flutter pub get
```

### Check Flutter Setup

```bash
flutter doctor
```

### Run on Android

Connect an Android device or start an emulator.

```bash
flutter devices
flutter run
```

### Run on Chrome

```bash
flutter run -d chrome
```

---

## 🧪 Testing and Analysis

The following Flutter commands can be used during development:

```bash
flutter analyze
```

```bash
flutter test
```

```bash
flutter doctor
```

These commands help check project configuration, analyze Dart code, and execute available tests.

---

## 📂 Project Structure

```text
RoadCare/
│
├── lib/
│   ├── database/
│   ├── models/
│   ├── repositories/
│   ├── screens/
│   ├── services/
│   └── main.dart
│
├── assets/
├── screenshots/
├── test/
├── android/
├── web/
├── pubspec.yaml
├── pubspec.lock
├── README.md
└── RoadCare_Project_Report.pdf
```

*The structure above is a representative overview. Folder names should match the actual repository.*

---

## 🎯 Project Objectives

- To provide an easy way to report road damages.
- To make road damage information easier to manage.
- To allow users to track their submitted reports.
- To provide administrators with report management tools.
- To develop a cross-platform application using Flutter and Dart.
- To maintain application data using a local SQLite database.

---

## 🔮 Future Enhancements

- Cloud-based data synchronization.
- Real-time report updates.
- Integration with government road maintenance departments.
- Advanced map-based damage visualization.
- Push notifications.
- Advanced analytics and reporting.

---

## 📚 References

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Google Maps Help](https://support.google.com/maps/)

---

## 👩‍💻 Project Information

**Project Name:** RoadCare – Road Damage Reporting System  
**Technology:** Flutter and Dart  
**Database:** SQLite  
**Platforms:** Android and Web (Chrome)  
**Project Type:** Academic / Flutter Lab Project

---

## ❤️ Acknowledgement

RoadCare was developed as an academic Flutter project to demonstrate cross-platform application development, user interface design, database management, navigation, and application workflows using Flutter and Dart.

**Made with Flutter & Dart.**
