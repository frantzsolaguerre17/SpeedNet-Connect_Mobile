import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app.config.dart';

class ApiService {
static Future<Map<String, dynamic>> inscrireUtilisateur({
required String nom,
required String telephone,
required String email,
required String motDePasse,
}) async {
final response = await http.post(
Uri.parse('${AppConfig.apiBaseUrl}/users/register'),
headers: {'Content-Type': 'application/json'},
body: jsonEncode({
'full_name': nom,
'phone': telephone,
'email': email,
'password': motDePasse,
}),
);

final dynamic donnees = jsonDecode(response.body);

if (response.statusCode < 200 ||
response.statusCode >= 300) {
final detail =
donnees is Map ? donnees['detail'] : null;
throw Exception(
detail?.toString() ?? 'Impossible de créer le compte.',
);
}

if (donnees is! Map) {
throw Exception('Réponse invalide du serveur.');
}

return Map<String, dynamic>.from(donnees);
}

static Future<Map<String, dynamic>> connecterUtilisateur({
required String telephone,
required String motDePasse,
}) async {
final response = await http.post(
Uri.parse('${AppConfig.apiBaseUrl}/users/login'),
headers: {'Content-Type': 'application/json'},
body: jsonEncode({
'phone': telephone,
'password': motDePasse,
}),
);

final dynamic donnees = jsonDecode(response.body);

if (response.statusCode < 200 ||
response.statusCode >= 300) {
final detail =
donnees is Map ? donnees['detail'] : null;
throw Exception(
detail?.toString() ??
'Numéro de téléphone ou mot de passe incorrect.',
);
}

if (donnees is! Map) {
throw Exception('Réponse invalide du serveur.');
}

final resultat = Map<String, dynamic>.from(donnees);

if (resultat['user'] == null ||
resultat['access_token'] == null) {
throw Exception('Réponse de connexion invalide.');
}

return resultat;
}
}
