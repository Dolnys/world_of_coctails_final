import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:world_of_coctails_final/services/cloud/cloud_coctail.dart';
import 'package:world_of_coctails_final/services/cloud/cloud_storage_constants.dart';
import 'package:world_of_coctails_final/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final coctails = FirebaseFirestore.instance.collection('coctails');

  Future<void> deleteCoctail({required String documentId}) async {
    try {
      await coctails.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteCoctailException();
    }
  }

  Future<void> updateCoctail({
    required String documentId,
    required String text,
  }) async {
    try {
      await coctails.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateCoctailException();
    }
  }

  Stream<Iterable<CloudCoctail>> allCoctails({required String ownerUserId}) =>
      coctails.snapshots().map((event) => event.docs
          .map((doc) => CloudCoctail.fromSnapshot(doc))
          .where((coctail) => coctail.ownerUserId == ownerUserId));

  Future<Iterable<CloudCoctail>> getCoctails(
      {required String ownerUserId}) async {
    try {
      return await coctails
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) {
                return CloudCoctail(
                  documentId: doc.id,
                  ownerUserId: doc.data()[ownerUserIdFieldName] as String,
                  text: doc.data()[textFieldName] as String,
                );
              },
            ),
          );
    } catch (e) {
      throw CouldNotGetAllCoctailsException();
    }
  }

  void createNewCoctail({required String ownerUserId}) async {
    await coctails.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
