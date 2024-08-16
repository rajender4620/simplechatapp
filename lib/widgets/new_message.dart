import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void submitMessage() async {
    final enteredMesasge = messageController.text;

    if (enteredMesasge.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    messageController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMesasge,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'userName': userData.data()!['username'] ?? '',
      'userImage': userData.data()!['imageUrl'] ?? ''
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(children: [
        Expanded(
            child: TextField(
          controller: messageController,
          textCapitalization: TextCapitalization.sentences,
          autocorrect: true,
          enableSuggestions: true,
          decoration: const InputDecoration(labelText: 'Send a message...'),
        )),
        IconButton(
            onPressed: () {
              submitMessage();
            },
            color: Colors.deepPurple,
            icon: const Icon(Icons.send))
      ]),
    );
  }
}
