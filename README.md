# ✋🤖 Sign Language Translator

A real-time sign language translation tool that uses computer vision and machine learning to convert hand gestures into readable text. Designed to bridge the communication gap between the hearing and the Deaf or Hard of Hearing communities.

Currently supports 6 Polish Sign Language gestures, including:

- **Dzień**
- **Dobry**
- **Kocham**
- **Ciebie**
- **Do**
- **Widziec**

---

## 🌟 Features

- 🔍 **Sign Language Recognition** — Detects and identifies hand gestures using a trained model.
- 🕒 **Real-Time Translation** — Converts gestures into text on the fly using your webcam or phone camera.
- 💬 **Predefined Gestures** — Currently supports 6 Polish signs: _Dzień_, _Dobry_, _Kocham_, _Ciebie_, _Do_, _Widziec_.
- 🌍 **Expandable Architecture** — Easily train the system on new signs or different sign languages.
- 🧠 **Machine Learning Powered** — Leverages modern deep learning techniques for accurate gesture recognition.
- 💻 **User-Friendly Interface** — Lightweight, intuitive, and easy to use.

---

## 📦 Installation

```bash
git clone https://github.com/your-username/sign-language-translator.git
cd sign-language-translator
```
## 🚀 Getting Started
### 1. Start the Server (Backend)
Make sure you’re in the main project directory, then run:

```bash
python server.py
```
✅ Your server should now be running on port 5000.
⚠️ Make sure your PC and mobile device are on the same Wi-Fi network.

### 2. Run the Flutter App (Frontend)
Navigate to the Flutter app folder (e.g. signapp) and run:

```bash
flutter run
```

Before running the app, edit the initializeEverything() function in your Flutter code and replace the IP with your local machine IP (the one running server.py):

```dart
socket = socket_io.io(
  'http://<YOUR-IP>:5000', // Example: 'http://192.168.0.105:5000'
  socket_io.OptionBuilder()
    .setTransports(['websocket'])
    .enableAutoConnect()
    .build()
);
```
🧠 You can find your IP using ipconfig (Windows) or ifconfig (macOS/Linux).

### 3. (Optional) Switch Camera
By default, the app uses the back camera.

To switch to the front camera, change this line in _initializeCamera():

```dart
cameras![1] // back camera
```
to:

```dart
cameras![0] // front camera
```
### 4. (Optional) Image Rotation Fix for Front Camera
If you switched to the front camera, update the image rotation in server.py. Inside the image function, change:

```python
pimg = pimg.rotate(90, expand=True)
```
to:

```python
pimg = pimg.rotate(-90, expand=True)
```
This ensures the image is rotated correctly before being passed to the model.
