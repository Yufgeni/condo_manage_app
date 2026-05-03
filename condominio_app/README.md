# FILE: /condominio_app/condominio_app/README.md CONTENTS
# Condominio App

## Description
Condominio App is a Flutter application designed for managing a condominium with three user profiles: Administrator, Resident, and Guard. The app provides functionalities tailored to each user type, ensuring efficient management and communication within the community.

## Features
- **Administrator Profile**: 
  - Access to all modules.
  - Manage residents and guards.
  - View and manage payment history.

- **Resident Profile**: 
  - View payment history.
  - Access information about the guard on duty.
  - Update personal profile information.

- **Guard Profile**: 
  - Upload images with brief descriptions.
  - Update personal profile information.

## Project Structure
```
condominio_app
├── android
├── ios
├── lib
│   ├── main.dart
│   ├── app.dart
│   ├── core
│   │   ├── constants
│   │   │   └── app_constants.dart
│   │   ├── themes
│   │   │   └── app_theme.dart
│   │   └── utils
│   │       └── validators.dart
│   ├── data
│   │   ├── models
│   │   │   ├── user_model.dart
│   │   │   ├── resident_model.dart
│   │   │   ├── guard_model.dart
│   │   │   └── payment_model.dart
│   │   ├── providers
│   │   │   ├── auth_provider.dart
│   │   │   ├── resident_provider.dart
│   │   │   └── guard_provider.dart
│   │   └── services
│   │       ├── auth_service.dart
│   │       ├── payment_service.dart
│   │       └── image_service.dart
│   └── presentation
│       ├── screens
│       │   ├── auth
│       │   │   └── login_screen.dart
│       │   ├── admin
│       │   │   ├── admin_dashboard.dart
│       │   │   ├── residents_screen.dart
│       │   │   ├── guards_screen.dart
│       │   │   └── payments_screen.dart
│       │   ├── resident
│       │   │   ├── resident_dashboard.dart
│       │   │   ├── payment_history_screen.dart
│       │   │   ├── guard_on_duty_screen.dart
│       │   │   └── resident_profile_screen.dart
│       │   └── guard
│       │       ├── guard_dashboard.dart
│       │       └── guard_upload_screen.dart
│       ├── widgets
│       │   ├── common
│       │   │   ├── custom_button.dart
│       │   │   ├── custom_text_field.dart
│       │   │   └── image_picker_widget.dart
│       │   ├── admin
│       │   │   └── admin_drawer.dart
│       │   ├── resident
│       │   │   └── payment_card.dart
│       │   └── guard
│       │       └── upload_card.dart
│       └── routes
│           └── app_routes.dart
├── assets
│   ├── fonts
│   │   ├── CustomFont.ttf
│   │   └── CustomFont-Bold.ttf
│   └── images
├── test
│   └── widget_test.dart
├── pubspec.yaml
└── README.md
```

## Setup Instructions
1. Clone the repository:
   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```
   cd condominio_app
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the application:
   ```
   flutter run
   ```

## Usage
- Use the login screen to access the application.
- Depending on the user profile, navigate through the respective dashboards and functionalities.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.