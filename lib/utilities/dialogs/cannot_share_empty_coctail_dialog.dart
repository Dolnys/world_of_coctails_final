import 'package:flutter/material.dart';
import 'package:world_of_coctails_final/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyCoctailDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty coctail!',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
