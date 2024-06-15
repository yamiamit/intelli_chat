import 'package:flutter/material.dart';
import 'package:flash_chat/components/user_profile_data.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flash_chat/screens/welcome_screen.dart';

void main() {
  runApp(UserInteractionListApp());
}

class UserInteractionListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserInteractionListScreen(),
    );
  }
}

class UserInteractionListScreen extends StatefulWidget {
  @override
  State<UserInteractionListScreen> createState() =>
      _UserInteractionListScreenState();
}

class _UserInteractionListScreenState extends State<UserInteractionListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF39A39A),
        title: Text('intelli_chat'),
        actions: [
          IconButton(
              onPressed: () async {
                FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                setState(() {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()));
                });
              },
              icon: Icon(Icons.close))
        ],
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return UserTile(userProfile: users[index]);
        },
      ),
    );
  }
}

class UserTile extends StatefulWidget {
  final UserProfile userProfile;

  UserTile({required this.userProfile});

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(widget.userProfile.name)));
        });
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.userProfile.imageUrl),
        ),
        title: Hero(
          tag: 'name',
          child: Text(widget.userProfile.name),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last seen: ${timeAgo(widget.userProfile.lastSeen)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String timeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 1) {
      return 'just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minutes ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hours ago';
    } else {
      return '${duration.inDays} days ago';
    }
  }
}
