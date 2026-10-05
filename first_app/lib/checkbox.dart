import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: CheckBoxDemo()));

class CheckBoxDemo extends StatefulWidget {
  const CheckBoxDemo({super.key});

  @override
  State<CheckBoxDemo> createState() => _CheckBoxDemoState();
}

class _CheckBoxDemoState extends State<CheckBoxDemo> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checkbox")),
      body: Center(
        child: Checkbox(
          value: value,
          onChanged: (v) {
            setState(() {
              value = v!;
            });
          },
        ),
      ),
    );
  }
}
