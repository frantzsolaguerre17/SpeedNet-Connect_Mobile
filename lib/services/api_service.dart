import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app.config.dart';

class ApiService {

  static Future<Map<String, dynamic>> inscrireUtilisateur({
    required String nom,
    required String telephone,
    required String motDePasse,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': nom,
        'phone': telephone,
        'password': motDePasse,
      }),
    );

    final dynamic donnees = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = donnees is Map ? donnees['detail'] : null;
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


static Future<Map<String, dynamic>> obtenirMonPortefeuille({
  required String accessToken,
}) async {
  final response = await http.get(
    Uri.parse('${AppConfig.apiBaseUrl}/users/me/wallet'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  final dynamic donnees = jsonDecode(response.body);

  if (response.statusCode < 200 || response.statusCode >= 300) {
    final detail = donnees is Map ? donnees['detail'] : null;
    throw Exception(
      detail?.toString() ?? 'Impossible de récupérer le solde.',
    );
  }

  if (donnees is! Map) {
    throw Exception('Réponse du portefeuille invalide.');
  }

  return Map<String, dynamic>.from(donnees);
}



static Future<List<Map<String, dynamic>>> obtenirForfaits() async {
  final response = await http.get(
    Uri.parse('${AppConfig.apiBaseUrl}/wifi/plans'),
    headers: {'Content-Type': 'application/json'},
  );

  final dynamic donnees = jsonDecode(response.body);

  if (response.statusCode < 200 || response.statusCode >= 300) {
    final detail = donnees is Map ? donnees['detail'] : null;
    throw Exception(
      detail?.toString() ?? 'Impossible de charger les forfaits.',
    );
  }

  if (donnees is! List) {
    throw Exception('La réponse des forfaits est invalide.');
  }

  return donnees
      .map((element) => Map<String, dynamic>.from(element as Map))
      .toList();
}

static Future<Map<String, dynamic>> acheterForfait({
  required String accessToken,
  required int planId,
}) async {
  final response = await http.post(
    Uri.parse('${AppConfig.apiBaseUrl}/wifi/wifi/purchase'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'plan_id': planId}),
  );

  final dynamic donnees = jsonDecode(response.body);

  if (response.statusCode < 200 || response.statusCode >= 300) {
    final detail = donnees is Map ? donnees['detail'] : null;
    throw Exception(
      detail?.toString() ?? 'Impossible d’effectuer l’achat.',
    );
  }

  if (donnees is! Map) {
    throw Exception('La réponse de l’achat est invalide.');
  }

  return Map<String, dynamic>.from(donnees);
}



static Future<List<Map<String, dynamic>>> obtenirMesCodesAchetes({
  required String accessToken,
}) async {
  final response = await http.get(
    Uri.parse('${AppConfig.apiBaseUrl}/wifi/my-codes'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  final resultat = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(
      (resultat as List).map(
            (element) => Map<String, dynamic>.from(element),
      ),
    );
  }

  final detail = resultat is Map ? resultat['detail'] : null;

  throw Exception(
    detail?.toString() ?? 'Impossible de charger tes codes achetés.',
  );
}



static Future<List<Map<String, dynamic>>> obtenirMesTransactions({
  required String accessToken,
}) async {
  final response = await http.get(
    Uri.parse('${AppConfig.apiBaseUrl}/users/me/transactions'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  final dynamic donnees = jsonDecode(response.body);

  if (response.statusCode < 200 || response.statusCode >= 300) {
    final detail = donnees is Map ? donnees['detail'] : null;
    throw Exception(
      detail?.toString() ?? 'Impossible de charger les transactions.',
    );
  }

  if (donnees is! List) {
    throw Exception('La réponse des transactions est invalide.');
  }

  return donnees
      .map((element) => Map<String, dynamic>.from(element as Map))
      .toList();
}




  static Future<Map<String, dynamic>> transfererArgent({
    required String accessToken,
    required String phone,
    required String amount,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/users/me/transfer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'phone': phone.trim(),
        'amount': amount.trim().replaceAll(',', '.'),
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data is Map
          ? data['detail']?.toString() ?? 'Échec du transfert.'
          : 'Échec du transfert.';

      throw Exception(message);
    }

    return Map<String, dynamic>.from(data as Map);
  }


}




