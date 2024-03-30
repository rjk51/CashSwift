import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Money added successfully!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(), 
            // Optionally show a loading indicator
          ],
        ),
      ),
    );
  }
}