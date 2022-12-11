import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:world_of_coctails_final/services/auth/auth_service.dart';
import 'package:world_of_coctails_final/services/cloud/cloud_coctail.dart';
import 'package:world_of_coctails_final/services/cloud/firebase_cloud_storage.dart';
import 'package:world_of_coctails_final/utilities/dialogs/cannot_share_empty_coctail_dialog.dart';

import 'package:world_of_coctails_final/utilities/generics/get_arguments.dart';

class CreateUptadeCoctailView extends StatefulWidget {
  const CreateUptadeCoctailView({super.key});

  @override
  State<CreateUptadeCoctailView> createState() =>
      _CreateUptadeCoctailViewState();
}

class _CreateUptadeCoctailViewState extends State<CreateUptadeCoctailView> {
  CloudCoctail? _coctail;
  late final FirebaseCloudStorage _coctailsService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _coctailsService = FirebaseCloudStorage();
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
      documentId: coctail.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudCoctail> createOrGetExistingCoctail(BuildContext context) async {
    final widgetCoctail = context.getArgument<CloudCoctail>();

    if (widgetCoctail != null) {
      _coctail = widgetCoctail;
      _textController.text = widgetCoctail.text;
      return widgetCoctail;
    }

    final existingCoctail = _coctail;
    if (existingCoctail != null) {
      return existingCoctail;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newCoctail =
        await _coctailsService.createNewCoctail(ownerUserId: userId);
    _coctail = newCoctail;
    return newCoctail;
  }

  void _deleteCoctailIfTextIsEmpty() {
    final coctail = _coctail;
    if (_textController.text.isEmpty && coctail != null) {
      _coctailsService.deleteCoctail(documentId: coctail.documentId);
    }
  }

  void _saveCoctailIfTextNotEmpty() async {
    final coctail = _coctail;
    final text = _textController.text;
    if (coctail != null && text.isNotEmpty) {
      await _coctailsService.updateCoctail(
        documentId: coctail.documentId,
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
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_coctail == null || text.isEmpty) {
                await showCannotShareEmptyCoctailDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingCoctail(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
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
