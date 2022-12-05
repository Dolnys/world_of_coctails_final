import 'package:flutter/material.dart';
import 'package:world_of_coctails_final/constants/routes.dart';
import 'package:world_of_coctails_final/enums/menu_action.dart';
import 'package:world_of_coctails_final/services/auth/auth_service.dart';
import 'package:world_of_coctails_final/utilities/dialogs/logout_dialog.dart';
import 'package:world_of_coctails_final/views/coctails/coctails_list_view.dart';

import '../../services/crud/coctails_service.dart';

class CoctailsView extends StatefulWidget {
  const CoctailsView({Key? key}) : super(key: key);
  @override
  _CoctailsViewState createState() => _CoctailsViewState();
}

class _CoctailsViewState extends State<CoctailsView> {
  late final CoctailsService _coctailsService;
  String get userEmail => AuthService.firebase().currentUser!.email;
  @override
  void initState() {
    _coctailsService = CoctailsService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Coctails'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(CreateOrUptadeCoctailRoute);
            },
            icon: const Icon(Icons.add),
          ),
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
                  child: Text('Log out'),
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
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allCoctails =
                            snapshot.data as List<DatabaseCoctail>;
                        return CoctailsListView(
                          coctails: allCoctails,
                          onDeleteCoctail: (coctail) async {
                            await _coctailsService.deleteCoctail(
                                id: coctail.id);
                          },
                          onTap: (coctail) {
                            Navigator.of(context).pushNamed(
                              CreateOrUptadeCoctailRoute,
                              arguments: coctail,
                            );
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
