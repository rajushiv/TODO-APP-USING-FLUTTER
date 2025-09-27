import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {  // ⬅️ Should be StatefulWidget
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();  // ⬅️ Return state
}

class MyHomePageState extends State<MyHomePage> {  // ⬅️ Correct generic type
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.purple[200] ,
    );
  }
}
