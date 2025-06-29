<div align="center">

  <h1>Intelli Chat</h1>
  <p><strong>A real-time messaging application that allows users to communicate with each other, 
featuring functionalities akin to WhatsApp, such as read status, last seen, and the capability to 
generate intelligent responses based on prior messages. This app aims to provide a seamless 
and interactive messaging experience for its users.</strong></p>
  
  <!-- Clickable Badges with Icons -->
  <p>
    <a href="https://flutter.dev" target="_blank">
      <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
    </a>
    <a href="https://firebase.google.com" target="_blank">
      <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
    </a>
    <a href="https://pub.dev/packages/google_ml_kit" target="_blank">
  <img src="https://img.shields.io/badge/Flutter_ML_Kit-FF6F00?style=for-the-badge&logo=google&logoColor=white" alt="Flutter ML Kit">
    </a>
  </p>
</div>

---

## 📑 Table of Contents

- [🚀 Features](#-features)
- [🧑‍💻 Tech Stack](#-tech-stack)
- [🛠️ Setup Instructions](#️-setup-instructions)
- [📐 Methodology](#-methodology)

---

## 🚀 Features

### ✅ Google Sign-In Authentication
- Seamless login using Google account — no need for mobile number or manual signup.

### 💌 Real-Time Messaging (Powered by Firebase)
- Instantly send and receive messages with reliable real-time sync.

### 👥 Add Users via Email
- Connect with users directly using their email addresses — simple and efficient.

### 👤 User Profiles
- Profile photo
- About/Bio
- Last seen status
- Account creation date

### 🗑️ ✏️ Message Delete & Edit
-Delete messages for everyone or yourself.
-Edit sent messages anytime.

### 🧠 Smart Reply Suggestions (On-Device ML)
-Powered by ML Kit + TensorFlow Lite.
-Generates context-aware quick reply suggestions directly on the device, ensuring privacy.

---

## 🧑‍💻 Tech Stack

| Layer | Technology / Service |
| :--- | :--- |
| **Frontend** | Flutter (Android + iOS) |
| **Backend & Database** | Firebase Firestore |

---

## 🛠️ Setup Instructions

### 📱 Frontend (Flutter)

1.  Clone the repo
     ```
     git clone https://github.com/yamiamit/intelli_chat
     ```
    
2.  **(Optional but Recommended)** Clean the build:
    ```
    flutter clean
    ```
3.  Run the app using one of the following methods:

    #### ▶️ Using VS Code (`launch.json`)
    Create or edit `.vscode/launch.json` with the following configuration:
    ```
    {
      "version": "0.2.0",
      "configurations": [
        {
          "name": "Flutter",
          "request": "launch",
          "type": "dart",
          "program": "lib/main.dart",
        }
      ]
    }
    ```

    #### 🛠️ Using Android Studio
    ```
    flutter run
    ```

    #### 💻 Using the Terminal
    ```
    flutter run 
    ```

---

## 📐 Methodology

- **Real time chatting**: Instantly send and receive messages with reliable real-time sync.
- **Firebase for Real-time Needs**: Leveraging Firebase for its real-time database capabilities and robust authentication services.
- **Smart Reply suggestion**: Generates context-aware quick reply suggestions directly on the device, ensuring privacy.

---













