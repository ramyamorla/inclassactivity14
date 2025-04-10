import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('Background message: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());//
}

class MessagingTutorial extends StatelessWidget {
  const MessagingTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          color: Color(0xFF075E54), // WhatsApp dark green color
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ), dialogTheme: DialogThemeData(backgroundColor: Colors.grey[800]),
      ),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? title;
  const MyHomePage({super.key, this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? fcmToken;
  String notificationText = "No notifications received yet.";
  String notificationType = "";

  @override
  void initState() {
    super.initState();

    // Initialize Firebase Messaging
    messaging = FirebaseMessaging.instance;

    // Retrieve and display the FCM token
    _getFCMToken();

    // Subscribe to a topic (optional, you can customize it as per your needs)
    messaging.subscribeToTopic("messaging");

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received");
      _handleMessage(message);
    });

    // Listen for messages when the app is in the background or terminated and opened by clicking on a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message clicked!");
      _handleMessage(message);
    });
  }

  // Method to retrieve and display the FCM token
  void _getFCMToken() async {
    fcmToken = await messaging.getToken();
    print("FCM Token: $fcmToken");

    // Display the token on the screen
    setState(() {});
  }

  // Method to handle incoming notifications
  void _handleMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    // Check the custom data field for notification type
    notificationType =
        data['notification_type'] ?? "regular"; // Default is "regular"

    String notificationContent = notification?.body ?? "No content";

    // Display notification based on type
    if (notificationType == "important") {
      // For important notifications, show a red-colored dialog
      _showImportantNotification(
          notification?.title ?? "Important", notificationContent);
    } else {
      // For regular notifications, show a standard dialog
      _showRegularNotification(
          notification?.title ?? "Notification", notificationContent);
    }

    setState(() {
      notificationText =
          "Type: $notificationType\nContent: $notificationContent";
    });
  }

  // Method to show regular notification
  void _showRegularNotification(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(content, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              child: const Text("Ok", style: TextStyle(color: Colors.tealAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to show important notification
  void _showImportantNotification(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.redAccent[700],
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            content,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text(
                "Ok",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "FCM Token:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.tealAccent,
                fontSize: 16,
              ),
            ),
            SelectableText(
              fcmToken ?? "Fetching token...",
              style: TextStyle(color: Colors.tealAccent[100], fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text(
              "Latest Notification:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.tealAccent,
                fontSize: 16,
              ),
            ),
            Text(
              notificationText,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
