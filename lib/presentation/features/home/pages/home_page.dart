import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page'),
      actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              
            },
          ),
        ],),
      body: const Center(child: Text('Welcome to the Home Page!')),
    );
  }
}