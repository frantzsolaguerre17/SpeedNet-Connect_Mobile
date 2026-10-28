
import 'package:flutter/material.dart';
import 'package:speednetconnect_mobile/screens/transfert_screen.dart';
import '../services/api_service.dart';
import '../screens/connexion/login_screen.dart';

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
  List<Map<String, dynamic>> _transactions = [];
  bool _chargementTransactions = false;
  String? _erreurTransactions;

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

  Future<void> _chargerTransactions() async {
    setState(() {
      _chargementTransactions = true;
      _erreurTransactions = null;
    });

    try {
      final resultat = await ApiService.obtenirMesTransactions(
        accessToken: widget.accessToken,
      );

      if (!mounted) return;

      setState(() {
        _transactions = resultat;
        _chargementTransactions = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erreurTransactions = e.toString();
        _chargementTransactions = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _construireAccueil(),       // 0
      _construireServices(),      // 1
      _construirePageMesCodes(),  // 2
      _construireTransfert(),     // 3
      _construireHistorique(),    // 4
      _construireProfil(),        // 5
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
         /* IconButton(
            tooltip: 'Notifications',
            onPressed: () => _message('Aucune nouvelle notification.'),
            icon: const Icon(Icons.notifications_none),
          ),*/
          IconButton(
            tooltip: 'Profil',
            onPressed: () {
              setState(() {
                _indexSelectionne = 5;
              });
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
        selectedIndex: _indexSelectionne < 5 ? _indexSelectionne : 0,
        onDestinationSelected: (index) {
          setState(() => _indexSelectionne = index);

          if (index == 1) {
            _chargerForfaits();
          } else if (index == 2) {
            _chargerMesCodes();
          } else if (index == 3) {
            _chargerSolde();
          }else if(index == 4){
            _chargerTransactions();
          }else if (index == 5) {
            _chargerSolde();
            _chargerTransactions();
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
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: 'Mes codes',
          ),
          NavigationDestination(
            icon: Icon(Icons.send_outlined),
            selectedIcon: Icon(Icons.send),
            label: 'Transfert',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Historique',
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
          'Bonjour, $nomUtilisateur',
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


    // Première ligne : Forfaits et Transfert
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
    icone: Icons.send_outlined,
    titre: 'Transfert d’argent',
    description: 'Envoyer à un client',
    action: () {
    Navigator.of(context).push(
    MaterialPageRoute(
    builder: (_) => TransfertScreen(
    accessToken: widget.accessToken,
    onTransfertReussi: () {
    _chargerSolde();
    _chargerTransactions();
    },
    ),
    ),
    );
    },
    ),
    ),
    ],
    ),

    const SizedBox(height: 12),

    // Deuxième ligne : Codes et Historique
    Row(
    children: [
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
    const SizedBox(width: 12),
    Expanded(
    child: _carteAction(
    icone: Icons.history,
    titre: 'Historique',
    description: 'Transactions',
    action: () {
    setState(() => _indexSelectionne = 3);
    _chargerTransactions();
    },
    ),
    ),
    ],
    ),

    const SizedBox(height: 12),

    // Assistance sur toute la largeur
    InkWell(
    onTap: () => _message(
    'Contactez le service client SpeedNetConnect.',
    ),
    borderRadius: BorderRadius.circular(16),
    child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
    color: const Color(0xFFE6ECF5),
    ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.14),
          blurRadius: 18,
          spreadRadius: 1,
          offset: const Offset(0, 6),
        ),
      ],
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
    Icons.support_agent,
    color: bleu,
    size: 28,
    ),
    ),
    const SizedBox(width: 14),
    const Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Assistance',
    style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 15,
    color: bleuFonce,
    ),
    ),
    SizedBox(height: 4),
    Text(
    'Besoin d’aide ? Contactez-nous.',
    style: TextStyle(
    color: Colors.black54,
    fontSize: 12,
    ),
    ),
    ],
    ),
    ),
    const Icon(
    Icons.arrow_forward_ios,
    color: bleu,
    size: 16,
    ),
    ],
    ),
    ),
    ),

    const SizedBox(height: 22),

        const SizedBox(height: 22),
      ],
    );
  }


  Widget _construireTransfert() {
    return TransfertScreen(
      accessToken: widget.accessToken,
      onTransfertReussi: () {
        _chargerSolde();
        _chargerTransactions();
      },
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
                            nom.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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




  Widget _construirePageMesCodes() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Mes codes Wi-Fi',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: bleuFonce,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Retrouvez ici tous vos codes d’accès achetés.',
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
        const SizedBox(height: 16),

        if (_chargementCodes)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_erreurCodes != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 42,
                  color: Colors.red,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Impossible de charger vos codes.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _erreurCodes!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                TextButton.icon(
                  onPressed: _chargerMesCodes,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
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
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 52,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Aucun code acheté',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: bleuFonce,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Vos codes Wi-Fi apparaîtront ici après un achat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            )
          else
            ...List.generate(
              _mesCodes.length,
                  (index) => _construireCarteCode(index),
            ),
      ],
    );
  }

  Widget _construireCarteCode(int index) {
    final code = _mesCodes[index];
    final estDernierAchat = index == 0;

    final dateAchat = code['purchased_at']?.toString()
        ?? code['created_at']?.toString()
        ?? code['sold_at']?.toString()
        ?? '';

    final dateFormatee = dateAchat.isEmpty
        ? null
        : DateTime.tryParse(dateAchat)?.toLocal();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: estDernierAchat
              ? const Color(0xFFB9D2F8)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: estDernierAchat
                ? const Color(0xFF2563EB).withValues(alpha: 0.90)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: estDernierAchat ? 18 : 10,
            spreadRadius: estDernierAchat ? 2 : 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (estDernierAchat)
              Container(
                width: 4,
                color: const Color(0xFF2563EB),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            code['plan_name']?.toString() ?? 'Forfait Wi-Fi',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                        ),
                        if (estDernierAchat)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: estDernierAchat
                                  ? Border.all(
                                color: const Color(0xFF2563EB),
                                width: 2,
                              )
                                  : null,
                            ),
                            child: const Text(
                              'LE PLUS RÉCENT',
                              style: TextStyle(
                                color: Color(0xFF1D4ED8),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE8EDF5)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.wifi_rounded,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Votre code d’accès',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                code['code']?.toString() ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: Color(0xFF172B4D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Montant payé',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            '${code['amount'] ?? '0'} ${code['currency'] ?? 'HTG'}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: Color(0xFF172B4D),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (dateFormatee != null) ...[
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFE8EDF5)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date et heure d’achat',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${dateFormatee.day.toString().padLeft(2, '0')}/'
                                      '${dateFormatee.month.toString().padLeft(2, '0')}/'
                                      '${dateFormatee.year} à '
                                      '${dateFormatee.hour.toString().padLeft(2, '0')}:'
                                      '${dateFormatee.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: Color(0xFF172B4D),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // PAGE HISTORIQUE

  Widget _construireHistorique() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Historique des transactions',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: bleuFonce,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Retrouvez ici vos recharges et vos achats de forfaits Wi-Fi.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
            _chargementTransactions ? null : _chargerTransactions,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualiser les transactions'),
          ),
        ),
        const SizedBox(height: 12),

        if (_chargementTransactions)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_erreurTransactions != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  _erreurTransactions!,
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: _chargerTransactions,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          )
        else if (_transactions.isEmpty)
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
                    Icons.receipt_long_outlined,
                    size: 56,
                    color: Colors.black26,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Aucune transaction',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: bleuFonce,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Vos recharges et achats apparaîtront ici.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            )
          else
            ..._transactions.map((transaction) {
              final type = transaction['type']?.toString() ?? '';
              final estRecharge = type == 'recharge';

              final description =
                  transaction['description']?.toString() ??
                      (estRecharge ? 'Recharge du portefeuille' : 'Achat Wi-Fi');

              final montant =
                  transaction['amount']?.toString() ?? '0';

              final devise =
                  transaction['currency']?.toString() ?? 'HTG';

              final date = transaction['date']?.toString() ?? '';

              final dateLisible = date.isEmpty
                  ? ''
                  : date.replaceFirst('T', ' ');

              final icone = estRecharge
                  ? Icons.account_balance_wallet_outlined
                  : Icons.wifi;

              final couleur = estRecharge
                  ? Colors.green
                  : bleu;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE6ECF5),
                  ),
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
                            color: estRecharge
                                ? const Color(0xFFE6F6EC)
                                : const Color(0xFFE8F0FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icone, color: couleur),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: bleuFonce,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                estRecharge
                                    ? 'Recharge administrative'
                                    : 'Achat de forfait Wi-Fi',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          estRecharge
                              ? Icons.check_circle
                              : Icons.wifi,
                          color: couleur,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      '${estRecharge ? '+' : '-'}$montant $devise',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: couleur,
                      ),
                    ),
                    if (dateLisible.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Date : $dateLisible',
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (estRecharge &&
                        transaction['balance_after'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Solde après recharge : '
                            '${transaction['balance_after']} $devise',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
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
          border: Border.all(
            color: const Color(0xFFE6ECF5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1455C0).withValues(alpha: 0.22),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
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


  Future<void> _deconnexion() async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (!mounted || confirmer != true) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const ConnexionScreen(),
      ),
          (route) => false,
    );
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
    _chargerTransactions();
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
