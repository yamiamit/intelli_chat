import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const id = 'ChatScreen';
  final String username;
  ChatScreen(this.username);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messagecontroller = TextEditingController();
  late final User userprofile;
  late String messagetext;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  late User loggedinuser;
  void getcurrentuser() {
    try {
      final user = _auth
          .currentUser; // this method itself is a async so we cannot change
      if (user != null) {
        loggedinuser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void _scrolltobottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getcurrentuser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              }),
        ],
        title: Hero(
          tag: 'name',
          child: Text(widget.username),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                List<MessageBubble> messagebubbles = [];
                if (snapshot.hasData) {
                  final messages = snapshot.data?.docs;

                  for (var message in messages!) {
                    final messageText = message.get('text');
                    final messageSender = message.get('sender');
                    final messageId = message.id;
                    final currentUser = loggedinuser.email;
                    final messagebubble = MessageBubble(
                        text: messageText,
                        sender: messageSender,
                        messageId: messageId,
                        isMe: currentUser == messageSender);
                    messagebubbles.add(messagebubble);
                  }
                }
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrolltobottom());
                return Expanded(
                  child: ListView(
                    children: messagebubbles,
                    controller: _scrollController,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messagecontroller,
                      onChanged: (value) {
                        messagetext = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messagecontroller.clear();
                      _firestore.collection('messages').add({
                        'timestamp': FieldValue.serverTimestamp(),
                        'text': messagetext,
                        'sender': loggedinuser.email,
                      }).then((_) {
                        _scrolltobottom();
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _firestore = FirebaseFirestore.instance;
void editMessage(String messageId, String newText) {
  _firestore.collection('messages').doc(messageId).update({
    'text': newText,
  });
}

void deleteMessage(String messageId) {
  _firestore.collection('messages').doc(messageId).delete();
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final String messageId; // Add messageId
  final bool isMe;

  MessageBubble(
      {required this.text,
      required this.sender,
      required this.messageId,
      required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start, // ternary operator
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Material(
            elevation: 5,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                        fontSize: 15,
                        color: isMe ? Colors.white : Colors.black),
                  ),
                  if (isMe)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'Edit') {
                          // Show dialog to edit message
                          showDialog(
                            context: context,
                            builder: (context) {
                              TextEditingController controller =
                                  TextEditingController(text: text);
                              return AlertDialog(
                                title: Text('Edit Message'),
                                content: TextField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                      hintText: "Edit your message"),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      editMessage(messageId, controller.text);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (value == 'Delete') {
                          deleteMessage(messageId);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'Edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'Delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
