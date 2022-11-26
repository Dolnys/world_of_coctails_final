import 'package:flutter/material.dart';

class NewCoctailView extends StatefulWidget {
  const NewCoctailView({super.key});

  @override
  State<NewCoctailView> createState() => _NewCoctailViewState();
}

class _NewCoctailViewState extends State<NewCoctailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Coctail'),
      ),
      body: const Text('Insert your coctail here'),
    );
  }
}
