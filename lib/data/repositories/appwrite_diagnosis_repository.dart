import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:typed_data';

// Inicializa tu cliente Appwrite
final client = Client()
  ..setEndpoint(dotenv.env['APPWRITE_ENDPOINT']!)
  ..setProject(dotenv.env['APPWRITE_PROJECT_ID']!);

final storage = Storage(client);

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

Future<String> uploadProfileImage(File imageFile, String userId) async {
  final result = await storage.createFile(
    bucketId: dotenv.env['TU_BUCKET_ID']!,
    fileId: ID.unique(),
    file: InputFile.fromPath(path: imageFile.path),
  );
  final url = client.endPoint +
      '/storage/buckets/${dotenv.env['TU_BUCKET_ID']}/files/${result.$id}/view?project=${dotenv.env['APPWRITE_PROJECT_ID']}&mode=admin';
  return url;
}

Future<String> uploadProfileImageWeb(Uint8List bytes, String filename, String userId) async {
  final result = await storage.createFile(
    bucketId: dotenv.env['TU_BUCKET_ID']!,
    fileId: ID.unique(),
    file: InputFile.fromBytes(bytes: bytes, filename: filename),
  );
  final url = client.endPoint +
      '/storage/buckets/${dotenv.env['TU_BUCKET_ID']}/files/${result.$id}/view?project=${dotenv.env['APPWRITE_PROJECT_ID']}&mode=admin';
  return url;
}