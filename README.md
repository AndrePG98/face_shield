<h1 style="display: flex; align-items: center;">
  Face Shield
  <img src="assets/images/icon.png" alt="Face Shield Logo" width="50" style="margin-left: 10px;"/>
</h1>
Face Shield is a Flutter mobile application that leverages advanced face recognition technology for secure user authentication and identity confirmation. The app offers a seamless and passwordless login experience by utilizing users' faces as their unique identification.

## Features

### Face Recognition Authentication

Face Shield allows users to log in to the app by simply presenting their faces to the camera. The app uses the Google ML Kit Face Detection plugin to detect and recognize faces in real-time. When a user attempts to log in, the app matches their face against the registered user database for authentication.

### Face Registration with Proof of Life

New users can sign up by registering their faces through the SignUpCameraWidget. During the face registration process, the app utilizes the CameraProcessor to capture the user's face and the FaceProcessor to perform proof-of-life tests. These tests include verifying if the user is smiling, looking left or right, and blinking. This ensures that the user's face is not a static image or a photo but a live, present face.

### Identity Confirmation

The SignUpCameraWidget's proof-of-life tests also play a crucial role in identity confirmation. By verifying that the user's face is real and dynamic, the app prevents unauthorized users from registering fake or fraudulent identities. This adds an extra layer of security and trust to the user registration process.

### User Management and Admin Access

The app has a route called ListUsersPage that allows administrators to view the list of registered users and their corresponding face data. This feature is useful for monitoring and managing user accounts, and it provides administrators with valuable insights into the user database.

## How it Works

### Face Detection

The app uses the Google ML Kit Face Detection plugin to perform real-time face detection. The LogInCameraWidget and SignUpCameraWidget utilize the CameraProcessor to access the device's cameras and the FaceProcessor to process the camera images for face detection.

### Face Recognition

When a user attempts to log in, the app captures their face using the LogInCameraWidget. The FaceProcessor processes the captured image and detects the user's face. It then compares the detected face with the registered user database to authenticate the user.

### Proof of Life Testing

During the sign-up process, the SignUpCameraWidget uses the FaceProcessor to perform various proof-of-life tests on the user's face. These tests include checking for a smile, looking left or right, and blinking. If the user passes these tests, their face data is registered in the database, ensuring the authenticity of their identity.

## Getting Started

### Prerequisites

Before running the app, make sure you have the following installed:

- Flutter SDK
- Dart SDK
- Android SDK or Xcode (for iOS development)
- Firebase account (for authentication and database)

### Installation

1. Clone the repository: git clone https://github.com/PhonyZ0n3/face_shield.git
2. Navigate to the project directory: cd face_shield
3. Install dependencies: flutter pub get
4. Run the app: flutter run

## Authors

- [PhonyZ0n3](https://github.com/PhonyZ0n3)
- [GoncaloLemos](https://github.com/GoncaloLemos)
- [Tiago-Goncalves98](https://github.com/Tiago-Goncalves98)
- [riicardobelo](https://github.com/riicardobelo)

## License

Face Shield is released under the [MIT License](LICENSE). Feel free to use, modify, and distribute the code. Attribution is appreciated but not required.**

