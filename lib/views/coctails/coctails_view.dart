import 'package:flutter/material.dart';
import 'package:world_of_coctails_final/constants/routes.dart';
import 'package:world_of_coctails_final/enums/menu_action.dart';
import 'package:world_of_coctails_final/services/auth/auth_service.dart';
import 'package:world_of_coctails_final/services/auth/block/auth_block.dart';
import 'package:world_of_coctails_final/services/auth/block/auth_event.dart';
import 'package:world_of_coctails_final/services/cloud/cloud_coctail.dart';
import 'package:world_of_coctails_final/services/cloud/firebase_cloud_storage.dart';
import 'package:world_of_coctails_final/utilities/dialogs/logout_dialog.dart';
import 'package:world_of_coctails_final/views/coctails/coctails_list_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

class CoctailsView extends StatefulWidget {
  const CoctailsView({Key? key}) : super(key: key);
  @override
  _CoctailsViewState createState() => _CoctailsViewState();
}

class _CoctailsViewState extends State<CoctailsView> {
  late final FirebaseCloudStorage _coctailsService;
  String get userId => AuthService.firebase().currentUser!.id;
  @override
  void initState() {
    _coctailsService = FirebaseCloudStorage();
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
              Navigator.of(context).pushNamed(createOrUptadeCoctailRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
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
      body: StreamBuilder(
        stream: _coctailsService.allCoctails(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allCoctails = snapshot.data as Iterable<CloudCoctail>;
                return CoctailsListView(
                  coctails: allCoctails,
                  onDeleteCoctail: (coctail) async {
                    await _coctailsService.deleteCoctail(
                        documentId: coctail.documentId);
                  },
                  onTap: (coctail) {
                    Navigator.of(context).pushNamed(
                      createOrUptadeCoctailRoute,
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
      ),
    );
  }
}
