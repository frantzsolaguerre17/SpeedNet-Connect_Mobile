
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> utilisateur;
  final String accessToken;

  const DashboardScreen({
    super.key,
    required this.utilisateur,
    required this.accessToken,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _indexSelectionne = 0;

  static const Color bleu = Color(0xFF1455C0);
  static const Color bleuFonce = Color(0xFF103B82);
  static const Color fond = Color(0xFFF4F7FC);
  bool _chargementSolde = true;
  String? _erreurSolde;
  double? _solde;
  String _devise = 'HTG';
  Map<String, dynamic> get utilisateur => widget.utilisateur;
  List<Map<String, dynamic>> _forfaits = [];
  bool _chargementForfaits = true;
  String? _erreurForfaits;
  bool _achatEnCours = false;
  List<Map<String, dynamic>> _mesCodes = [];
  bool _chargementCodes = false;
  String? _erreurCodes;

  String get nomUtilisateur {
    final nom = utilisateur['full_name'] ??
        utilisateur['name'] ??
        'Utilisateur';
    return nom.toString();
  }

  String get soldeFormate {
    if (_chargementSolde) return 'Chargement...';
    if (_erreurSolde != null || _solde == null) {
      return 'Indisponible';
    }
    return _solde!.toStringAsFixed(2);
  }



  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _construireAccueil(),
      _construireServices(),
      _construireHistorique(),
      _construireProfil(),
    ];

    return Scaffold(
      backgroundColor: fond,

      // Première barre supérieure
      appBar: AppBar(
        backgroundColor: bleu,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.wifi, size: 28),
            const SizedBox(width: 9),
            const Text(
              'SpeedNetConnect',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _message('Aucune nouvelle notification.'),
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            tooltip: 'Profil',
            onPressed: () {
              setState(() => _indexSelectionne = 3);
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),

      // Deuxième barre sous l'AppBar principale
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: bleu,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: bleu,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Solde de votre compte',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$soldeFormate $_devise',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Actualiser le solde',
                              onPressed: _chargementSolde
                                  ? null
                                  : () {
                                setState(() {
                                  _chargementSolde = true;
                                  _erreurSolde = null;
                                });
                                _chargerSolde();
                              },
                              icon: _chargementSolde
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Icon(
                                Icons.refresh,
                                color: Color(0xFF1455C0),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Recharger',
                    onPressed: _recharger,
                    style: IconButton.styleFrom(
                      backgroundColor: bleu,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),

          // Contenu des onglets
          Expanded(
            child: IndexedStack(
              index: _indexSelectionne,
              children: pages,
            ),
          ),
        ],
      ),

      // Navigation inférieure
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexSelectionne,
        onDestinationSelected: (index) {
          setState(() => _indexSelectionne = index);

          if (index == 1) {
            _chargerForfaits();
          } else if (index == 2) {
            _chargerMesCodes();
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDCE8FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.wifi_outlined),
            selectedIcon: Icon(Icons.wifi),
            label: 'Forfaits',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Historique',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // PAGE ACCUEIL
  Widget _construireAccueil() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Bonjour, $nomUtilisateur 👋',
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: bleuFonce,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Restez connecté avec SpeedNetConnect.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 22),

        // Carte promotionnelle
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [bleu, bleuFonce],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Internet partout,\nplus simplement !',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Choisissez votre forfait Wi-Fi.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.wifi,
                size: 64,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Text(
          'Accès rapide',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: bleuFonce,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _carteAction(
                icone: Icons.wifi,
                titre: 'Forfaits Wi-Fi',
                description: 'Voir les offres',
                action: () {
                  setState(() => _indexSelectionne = 1);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _carteAction(
                icone: Icons.confirmation_number_outlined,
                titre: 'Mes codes',
                description: 'Codes Wi-Fi',
                action: () {
                  setState(() => _indexSelectionne = 2);
                  _chargerMesCodes();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _carteAction(
                icone: Icons.history,
                titre: 'Historique',
                description: 'Transactions',
                action: () {
                  setState(() => _indexSelectionne = 2);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _carteAction(
                icone: Icons.support_agent,
                titre: 'Assistance',
                description: 'Besoin d’aide ?',
                action: () => _message(
                  'Contactez le service client SpeedNetConnect.',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  // PAGE FORFAITS

  Widget _construireServices() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Forfaits Wi-Fi',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: bleuFonce,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choisissez un forfait pour vous connecter.',
          style: TextStyle(color: Colors.black54),
        ),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _chargementForfaits
                ? null
                : _actualiserDonnees,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualiser les forfaits'),
          ),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 20),

        if (_chargementForfaits)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_erreurForfaits != null)
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.wifi_off,
                  size: 42,
                  color: Colors.black38,
                ),
                const SizedBox(height: 10),
                const Text('Impossible de charger les forfaits.'),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _chargementForfaits = true;
                      _erreurForfaits = null;
                    });
                    _chargerForfaits();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          )
        else if (_forfaits.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Aucun forfait disponible pour le moment.'),
              ),
            )
          else
            ..._forfaits.map((forfait) {
              final id = int.tryParse('${forfait['id']}');
              final nom = forfait['name']?.toString() ?? 'Forfait Wi-Fi';
              final duree = forfait['duration_hours'];
              final prix = forfait['price']?.toString() ?? '0';
              final devise = forfait['currency']?.toString() ?? 'HTG';
              final description =
                  forfait['description']?.toString().trim() ?? '';
              final stock = int.tryParse(
                '${forfait['codes_available'] ?? 0}',
              ) ??
                  0;
              String dureeFormatee;
              final heures = int.tryParse('$duree') ?? 0;

              if (heures > 0 && heures % 24 == 0) {
                dureeFormatee = '${heures ~/ 24} jour(s)';
              } else {
                dureeFormatee = '$heures heure(s)';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE6ECF5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.wifi,
                        color: bleu,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nom,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            description.isEmpty
                                ? 'Durée : $dureeFormatee'
                                : description,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '$prix $devise',
                            style: const TextStyle(
                              color: bleu,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                           /* children: [
                              Icon(
                                stock > 0 ? Icons.check_circle_outline : Icons.info_outline,
                                size: 16,
                                color: stock > 0 ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                stock > 0
                                    ? '$stock code(s) disponible(s)'
                                    : 'Rupture de stock',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: stock > 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],*/
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: id == null || _achatEnCours || stock <= 0
                                  ? null
                                  : () => _acheter(id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bleu,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                _achatEnCours ? 'Patientez...' : 'Acheter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
      ],
    );
  }


  // PAGE HISTORIQUE
  Widget _construireHistorique() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Mes codes achetés',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: bleuFonce,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Retrouvez ici les codes Wi-Fi que vous avez achetés.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _chargementCodes ? null : _chargerMesCodes,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualiser mes codes'),
          ),
        ),
        const SizedBox(height: 12),

        if (_chargementCodes)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_erreurCodes != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 36),
                const SizedBox(height: 8),
                Text(
                  _erreurCodes!,
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: _chargerMesCodes,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          )
        else if (_mesCodes.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6ECF5)),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 56,
                    color: Colors.black26,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Aucun code acheté',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: bleuFonce,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tes codes apparaîtront ici après un achat réussi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            )
          else
            ..._mesCodes.map((element) {
              final nom =
                  element['plan_name']?.toString() ?? 'Forfait Wi-Fi';
              final code = element['code']?.toString() ?? '';
              final montant = element['amount']?.toString() ?? '0';
              final devise = element['currency']?.toString() ?? 'HTG';
              final date = element['purchased_at']?.toString() ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE6ECF5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.wifi, color: bleu),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            nom,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: bleuFonce,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Ton code Wi-Fi',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            code,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: bleu,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Copier le code',
                          onPressed: code.isEmpty
                              ? null
                              : () {
                            // La copie sera ajoutée à l'étape suivante.
                            _message('Code : $code');
                          },
                          icon: const Icon(Icons.copy, color: bleu),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Montant : $montant $devise',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Acheté le : ${date.replaceFirst('T', ' ')}',
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
      ],
    );
  }

  // PAGE PROFIL
  Widget _construireProfil() {
    final telephone = utilisateur['phone']?.toString() ?? 'Non renseigné';
    final email = utilisateur['email']?.toString() ?? 'Non renseigné';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 42,
            backgroundColor: Color(0xFFDCE8FF),
            child: Icon(
              Icons.person,
              size: 48,
              color: bleu,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            nomUtilisateur,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: bleuFonce,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _ligneProfil(Icons.person_outline, 'Nom complet', nomUtilisateur),
        _ligneProfil(Icons.phone_outlined, 'Téléphone', telephone),
        _ligneProfil(Icons.email_outlined, 'E-mail', email),
        _ligneProfil(
          Icons.account_balance_wallet_outlined,
          'Solde',
          '$soldeFormate HTG',
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _deconnexion,
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // CARTE D'ACTION
  Widget _carteAction({
    required IconData icone,
    required String titre,
    required String description,
    required VoidCallback action,
  }) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 135),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6ECF5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: bleu, size: 30),
            const SizedBox(height: 12),
            Text(
              titre,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: bleuFonce,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CARTE FORFAIT
  Widget _carteForfait({
    required String nom,
    required String details,
    required String prix,
    required IconData icone,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6ECF5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: bleu, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  details,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  prix,
                  style: const TextStyle(
                    color: bleu,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: bleu),
        ],
      ),
    );
  }

  Widget _ligneProfil(IconData icone, String titre, String valeur) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icone, color: bleu),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valeur,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _recharger() {
    _message(
      'La recharge n’est pas encore connectée au système de paiement.',
    );
  }

  void _deconnexion() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texte)),
    );
  }


  @override
  void initState() {
    super.initState();
    _chargerSolde();
    _chargerForfaits();
    _chargerMesCodes();

  }

  Future<void> _chargerSolde() async {
    try {
      final portefeuille = await ApiService.obtenirMonPortefeuille(
        accessToken: widget.accessToken,
      );

      final valeur = portefeuille['balance'];
      final montant = valeur is num
          ? valeur.toDouble()
          : double.tryParse(valeur.toString());

      if (montant == null) {
        throw Exception('Solde invalide.');
      }

      if (!mounted) return;

      setState(() {
        _solde = montant;
        _devise = portefeuille['currency']?.toString() ?? 'HTG';
        _erreurSolde = null;
        _chargementSolde = false;
      });
    } catch (e) {
      debugPrint('ERREUR PORTFEUILLE : $e');

      if (!mounted) return;

      setState(() {
        _erreurSolde = e.toString();
        _chargementSolde = false;
      });
    }
  }


  Future<void> _actualiserDonnees() async {
    await Future.wait([
      _chargerForfaits(),
      _chargerMesCodes(),
      _chargerSolde(),
    ]);

    if (!mounted) return;

    _message('Données actualisées.');
  }



  Future<void> _chargerForfaits() async {
    try {
      final forfaits = await ApiService.obtenirForfaits();

      if (!mounted) return;

      setState(() {
        _forfaits = forfaits;
        _erreurForfaits = null;
        _chargementForfaits = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erreurForfaits = e.toString();
        _chargementForfaits = false;
      });
    }
  }

  Future<void> _chargerMesCodes() async {
    setState(() {
      _chargementCodes = true;
      _erreurCodes = null;
    });

    try {
      final codes = await ApiService.obtenirMesCodesAchetes(
        accessToken: widget.accessToken,
      );

      if (!mounted) return;

      setState(() {
        _mesCodes = codes;
        _chargementCodes = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erreurCodes = e.toString().replaceFirst('Exception: ', '');
        _chargementCodes = false;
      });
    }
  }

  Future<void> _acheter(int planId) async {
    if (_achatEnCours) return;

    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l’achat'),
        content: const Text(
          'Le montant sera déduit de votre portefeuille. '
              'Voulez-vous continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmer != true || !mounted) return;

    setState(() => _achatEnCours = true);

    try {
      final resultat = await ApiService.acheterForfait(
        accessToken: widget.accessToken,
        planId: planId,
      );

      await _chargerSolde();
      await _chargerForfaits();
      await _chargerMesCodes();

      if (!mounted) return;

      final code = resultat['code']?.toString() ?? '';
      final nom = resultat['plan_name']?.toString() ?? 'Forfait Wi-Fi';

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Achat réussi !'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nom),
              const SizedBox(height: 12),
              const Text('Votre code Wi-Fi :'),
              const SizedBox(height: 6),
              SelectableText(
                code.isEmpty ? 'Code non retourné par le serveur' : code,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1455C0),
                ),
              ),
              const SizedBox(height: 8),
              Text('Montant : ${resultat['amount'] ?? ''} HTG'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _message(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _achatEnCours = false);
      }
    }
  }

}
