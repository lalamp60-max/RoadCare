import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: Home()));
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Button")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            debugPrint("Button Pressed");
          },
          child: const Text("Click Me"),
        ),
      ),
    );
  }
}
