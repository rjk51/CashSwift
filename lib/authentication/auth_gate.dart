import 'package:cashswift/pages/onboarding.dart';
import 'package:cashswift/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const SplashPage();
            }
            //if the user is logged in
            if (snapshot.hasData) {
              return const SplashPage();
            }
            return const OnBoardingPage();
          }),
    );
  }
}
