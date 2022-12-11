import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:world_of_coctails_final/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudCoctail {
  final String documentId;
  final String ownerUserId;
  final String text;

  const CloudCoctail({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  CloudCoctail.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String? ?? '<empty coctail>';
}
