import 'package:flutter/material.dart';
import 'package:world_of_coctails_final/services/auth/auth_service.dart';
import 'package:world_of_coctails_final/services/crud/coctails_service.dart';

class NewCoctailView extends StatefulWidget {
  const NewCoctailView({super.key});

  @override
  State<NewCoctailView> createState() => _NewCoctailViewState();
}

class _NewCoctailViewState extends State<NewCoctailView> {
  DatabaseCoctail? _coctail;
  late final CoctailsService _coctailsService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _coctailsService = CoctailsService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final coctail = _coctail;
    if (coctail == null) {
      return;
    }
    final text = _textController.text;
    await _coctailsService.updateCoctail(
      coctail: coctail,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseCoctail> createNewCoctail() async {
    final existingCoctail = _coctail;
    if (existingCoctail != null) {
      return existingCoctail;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _coctailsService.getUser(email: email);
    return await _coctailsService.createCoctail(owner: owner);
  }

  void _deleteCoctailIfTextIsEmpty() {
    final coctail = _coctail;
    if (_textController.text.isEmpty && coctail != null) {
      _coctailsService.deleteCoctail(id: coctail.id);
    }
  }

  void _saveCoctailIfTextNotEmpty() async {
    final coctail = _coctail;
    final text = _textController.text;
    if (coctail != null && text.isNotEmpty) {
      await _coctailsService.updateCoctail(
        coctail: coctail,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteCoctailIfTextIsEmpty();
    _saveCoctailIfTextNotEmpty();
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Coctail'),
      ),
      body: FutureBuilder(
        future: createNewCoctail(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _coctail = snapshot.data as DatabaseCoctail?;
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: 'Start describing your coctail...'),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
