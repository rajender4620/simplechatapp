import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  var enteredEmail = '';
  var enteredpassword = '';
  var isLogin = true;
  var enteredUserName = '';
  File? selectedImage;
  var isAuthenticating = false;
  submit() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid || !isLogin && selectedImage == null) {
      // error msg
      return;
    }

    formKey.currentState!.save();

    try {
      setState(() {
        isAuthenticating = true;
      });
      if (isLogin) {
        await firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredpassword);
      } else {
        final userCredentials = await firebase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredpassword);

        final storegeRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');
        await storegeRef.putFile(selectedImage!);
        final imageUrl = await storegeRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': enteredUserName,
          'email': enteredEmail,
          'imageUrl': imageUrl,
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'Auth Failed')));
      }
      setState(() {
        isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset(
                    'assets/images/Speech-Chat-Icon-Transparent-PNG.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isLogin)
                              UserImagePicker(
                                pickedImage: (pickedImage) {
                                  selectedImage = pickedImage;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Email Address'),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              onSaved: (newValue) {
                                enteredEmail = newValue!;
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            if (!isLogin)
                              TextFormField(
                                onSaved: (newValue) {
                                  enteredUserName = newValue!;
                                },
                                enableSuggestions: false,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 4) {
                                    return 'Please enter atleast 4 characters';
                                  }
                                  return null;
                                },
                              ),
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Password'),
                              obscureText: false,
                              onSaved: (newValue) {
                                enteredpassword = newValue!;
                              },
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            if (!isAuthenticating)
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.deepPurple.shade50),
                                  onPressed: () {
                                    submit();
                                  },
                                  child: Text(isLogin ? 'Login' : 'Signup'))
                            else
                              const CircularProgressIndicator(),
                            if (!isAuthenticating)
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isLogin = !isLogin;
                                    });
                                  },
                                  child: Text(isLogin
                                      ? 'Create an account'
                                      : 'I already have an account.'))
                          ],
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
