import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cashswift/pages/auth.dart'; // Replace with your authentication screen file

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      foregroundColor: Theme.of(context).colorScheme.tertiary,
      backgroundColor: Theme.of(context).colorScheme.background,
      title: Row(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final imageUrl = userData['imageUrl'] as String?;

                return CircleAvatar(
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl) as ImageProvider
                      : const AssetImage('assets/logo.png'),
                );
              }
            },
          ),
          const SizedBox(width: 8), // Adjust spacing between avatar and text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final username = userData['username'] as String;
                    final upiId = userData['upiId'] as String;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          upiId,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AuthScreen()), // Replace YourAuthenticationScreen() with your actual authentication screen
              (route) => false,
            );
          },
          icon: Icon(
            Icons.exit_to_app,
            color: Theme.of(context).colorScheme.primary,
          ),
        )
      ],
    );
  }
}
