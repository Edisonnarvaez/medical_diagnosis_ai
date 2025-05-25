import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteDiagnosisRepository {
  final Databases db = Databases(Client()
    ..setEndpoint(dotenv.env['APPWRITE_ENDPOINT']!)
    ..setProject(dotenv.env['APPWRITE_PROJECT_ID']!));
  final String databaseId = dotenv.env['APPWRITE_DATABASE_ID']!;
  final String collectionId = dotenv.env['APPWRITE_DIAGNOSIS_COLLECTION_ID']!;

  Future<void> saveDiagnosis(String userId, Map<String, dynamic> data) async {
    await db.createDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: ID.unique(),
      data: data,
    );
  }

  Future<List<Map<String, dynamic>>> getDiagnoses(String userId) async {
    final docs = await db.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [Query.equal('userId', userId)],
    );
    return docs.documents.map((doc) => doc.data).toList();
  }
}