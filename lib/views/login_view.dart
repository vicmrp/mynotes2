import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes2/constants/routes.dart';
import 'package:mynotes2/firebase_options.dart';
import 'dart:developer' as devtools show log;

import '../utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(children: [
        TextField(
          controller: _email,
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'Enter your email here'),
        ),
        TextField(
          controller: _password,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          decoration:
              const InputDecoration(hintText: 'Enter your password here'),
        ),
        TextButton(
          onPressed: () async {
            Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            );

            final email = _email.text;
            final password = _password.text;

            try {
              final navigator = Navigator.of(context);
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: email,
                password: password,
              );

              final user = FirebaseAuth.instance.currentUser;
              if (user?.emailVerified ?? false) {
                // user's email is verified
                navigator.pushNamedAndRemoveUntil(notesRoute, (route) => false);
              } else {
                // user's email is NOT verified
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  varifyEmailRoute,
                  (route) => false,
                );
              } 
            } on FirebaseAuthException catch (e) {
              if (e.code == 'user-not-found') {
                devtools.log('User not found');
                await showErrorDialog(
                  context,
                  'User not found',
                );
              } else if (e.code == 'wrong-password') {
                await showErrorDialog(
                  context,
                  'Wrong Password',
                );
              } else if (e.code == 'invalid-email') {
                await showErrorDialog(
                  context,
                  'Invalid email',
                );
              } else {
                devtools.log("Error: ${e.code.toString()}");
                await showErrorDialog(
                  context,
                  'Error: ${e.code.toString()}',
                );
              }
            } catch (e) {
              await showErrorDialog(
                context,
                e.toString(),
              );
            }
          },
          child: const Text('Login'),
        ),
        TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text('Not registered yet? Register here!'))
      ]),
    );
  }
}
