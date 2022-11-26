import 'package:flutter/material.dart';
import 'package:world_of_coctails_final/services/auth/auth_service.dart';
import 'package:world_of_coctails_final/services/crud/coctails_service.dart';

import '../constants/routes.dart';
import '../enums/menu_action.dart';
import '../utilities/show_error_dialog.dart';

class CoctailsView extends StatefulWidget {
  const CoctailsView({Key? key}) : super(key: key);

  @override
  _CoctailsViewState createState() => _CoctailsViewState();
}

class _CoctailsViewState extends State<CoctailsView> {
  late final CoctailsService _coctailsService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _coctailsService = CoctailsService();
    super.initState();
  }

  @override
  void dispose() {
    _coctailsService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('world of coctials'),
          actions: [
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      await AuthService.firebase().logOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                      );
                    }
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text('logout'),
                  ),
                ];
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: _coctailsService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _coctailsService.allCoctails,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Text('waiting for all coctails...');
                      default:
                        return const CircularProgressIndicator();
                    }
                  },
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
