import 'package:flutter/material.dart';
import 'package:world_of_coctails_final/services/cloud/cloud_coctail.dart';

import 'package:world_of_coctails_final/utilities/dialogs/delete_dialog.dart';

typedef CoctailCallback = void Function(CloudCoctail coctail);

class CoctailsListView extends StatelessWidget {
  final Iterable<CloudCoctail> coctails;
  final CoctailCallback onDeleteCoctail;
  final CoctailCallback onTap;

  const CoctailsListView({
    Key? key,
    required this.coctails,
    required this.onDeleteCoctail,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: coctails.length,
      itemBuilder: (context, index) {
        final coctail = coctails.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(coctail);
          },
          title: Text(
            coctail.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteCoctail(coctail);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
