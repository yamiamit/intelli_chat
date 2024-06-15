import 'package:flash_chat/screens/chat_screen.dart';
class UserProfile {
  final String name;
  final String imageUrl;
  final DateTime lastSeen;

  UserProfile({
    required this.name,
    required this.imageUrl,
    required this.lastSeen,
  });
}

final List<UserProfile> users = [
  UserProfile(
    name: 'abc',
    imageUrl: 'https://via.placeholder.com/150',
    lastSeen: DateTime.now().subtract(Duration(minutes: 5)),
  ),
  UserProfile(
    name: 'xyz',
    imageUrl: 'https://via.placeholder.com/150',
    lastSeen: DateTime.now().subtract(Duration(minutes: 5)),
  ),
];
