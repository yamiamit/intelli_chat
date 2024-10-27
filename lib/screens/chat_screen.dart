import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';

class ChatScreen extends StatefulWidget {
  static const id = 'ChatScreen';
  final String username;
  ChatScreen(this.username);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  late User loggedInUser;
  late String messageText;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final SmartReply _smartReply = SmartReply();
  List<MessageBubble> messageBubbles = [];

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<SmartReplySuggestionResult> suggestReplies() async {
    if (messageBubbles.isEmpty) {
      print('I m sorry');
      return SmartReplySuggestionResult(
        status: SmartReplySuggestionResultStatus.noReply,
        suggestions: [],
      );
    }
     final messages = await messageBubbles;
    // Add messages to the conversation for Smart Reply
    for (var message in messages) {
      final userId = message.isMe ? 'localUser' : 'remoteUser';
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      if (message.isMe) {
        _smartReply.addMessageToConversationFromLocalUser(message.text, timestamp);
      } else {
        _smartReply.addMessageToConversationFromRemoteUser(
          message.text,
          timestamp,
          userId,
        );
      }
    }

    final result = await _smartReply.suggestReplies();

    try{
      result.status == SmartReplySuggestionResultStatus.success;
      print('suggestions = ${result.suggestions}');
    } catch(e)
    {
      print('something went wrong');
    }
    return result;
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
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

                if (snapshot.hasData) {
                  final messages = snapshot.data?.docs;

                  for (var message in messages!) {
                    final messageText = message.get('text');
                    final messageSender = message.get('sender');
                    final messageId = message.id;
                    final currentUser = loggedInUser.email;

                    final messageBubble = MessageBubble(
                      text: messageText,
                      sender: messageSender,
                      messageId: messageId,
                      isMe: currentUser == messageSender,
                    );
                    messageBubbles.add(messageBubble);
                  }
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return Expanded(
                  child: ListView(
                    controller: _scrollController,
                    children: messageBubbles,
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
                      controller: messageController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageController.clear();
                      suggestReplies();
                      _firestore.collection('messages').add({
                        'timestamp': FieldValue.serverTimestamp(),
                        'text': messageText,
                        'sender': loggedInUser.email,
                      }).then((_) {
                        _scrollToBottom();
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



void editMessage(String messageId, String newText) {
  FirebaseFirestore.instance.collection('messages').doc(messageId).update({
    'text': newText,
  });
}

void deleteMessage(String messageId) {
  FirebaseFirestore.instance.collection('messages').doc(messageId).delete();
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final String messageId;
  final bool isMe;

  MessageBubble({
    required this.text,
    required this.sender,
    required this.messageId,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
              bottomRight: Radius.circular(30),
            )
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
                      color: isMe ? Colors.white : Colors.black,
                    ),
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
