import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteConfig {
  static Client getClient() {
    final endpoint = dotenv.env['APPWRITE_ENDPOINT']!;
    final projectId = dotenv.env['APPWRITE_PROJECT_ID']!;
    return Client().setEndpoint(endpoint).setProject(projectId);
  }
}
