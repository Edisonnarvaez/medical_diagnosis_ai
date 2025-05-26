import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserProfileRepository {
  final Databases db = Databases(Client()
    ..setEndpoint(dotenv.env['APPWRITE_ENDPOINT']!)
    ..setProject(dotenv.env['APPWRITE_PROJECT_ID']!));
  final String databaseId = dotenv.env['APPWRITE_DATABASE_ID']!;
  final String collectionId = dotenv.env['APPWRITE_PROFILES_COLLECTION_ID']!;

  Future<void> saveProfile(String userId, Map<String, dynamic> data) async {
    try {
      await db.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: userId,
        data: data,
      );
    } on AppwriteException catch (e) {
      if (e.code == 409) {
        await db.updateDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: userId,
          data: data,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final doc = await db.getDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: userId,
      );
      return doc.data;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isProfileComplete(String userId) async {
    final profile = await getProfile(userId);
    if (profile == null) return false;
    // Ajusta los campos requeridos según tu lógica
    return (profile['name'] ?? '').toString().isNotEmpty &&
           (profile['age'] ?? '').toString().isNotEmpty &&
           (profile['gender'] ?? '').toString().isNotEmpty &&
           (profile['weight'] ?? '').toString().isNotEmpty &&
           (profile['height'] ?? '').toString().isNotEmpty;
  }
}