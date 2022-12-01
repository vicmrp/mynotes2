import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes2/constants/routes.dart';
import 'package:mynotes2/firebase_options.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes2/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Register')),
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
            await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            );

            final email = _email.text;
            final password = _password.text;

            try {
              final userCredential =
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
              
              devtools.log(userCredential.toString());

              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();              
              if (!mounted) return;
              Navigator.of(context).pushNamed(varifyEmailRoute);
            } on FirebaseAuthException catch (e) {
              if (e.code == 'weak-password') {
                if (!mounted) return;
                await showErrorDialog(
                  context,
                  'Weak Password',
                );
                devtools.log('Weak password');
              } else if (e.code == 'email-already-in-use') {
                if (!mounted) return;
                await showErrorDialog(
                  context,
                  'Email already in use',
                );
                devtools.log(e.code);
              } else if (e.code == 'invalid-email') {
                if (!mounted) return;
                await showErrorDialog(
                  context,
                  'Invalid email',
                );
              } else {
                if (!mounted) return;
                await showErrorDialog(
                  context,
                  "Error ${e.code}",
                );
                devtools.log(e.code);
              }
            } catch (e) {
              if (!mounted) return;
              await showErrorDialog(
                context,
                e.toString(),
              );
              devtools.log(e.toString());
            }
          },
          child: const Text('Register'),
        ),
        TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text("Already registered? Login here!"))
      ]),
    );
  }
}
