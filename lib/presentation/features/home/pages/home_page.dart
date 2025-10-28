import 'package:audiobooks/presentation/features/auth/widgets/sign_out_button.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [SignOutButton()],
      ),
      body: const Center(child: Text('Welcome to the Home Page!')),
    );
  }
}
