
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> utilisateur;

  const DashboardScreen({
    super.key,
    required this.utilisateur,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _indexSelectionne = 0;

  static const Color bleu = Color(0xFF1455C0);
  static const Color bleuFonce = Color(0xFF103B82);
  static const Color fond = Color(0xFFF4F7FC);

  Map<String, dynamic> get utilisateur => widget.utilisateur;

  String get nomUtilisateur {
    final nom = utilisateur['full_name'] ??
        utilisateur['name'] ??
        'Utilisateur';
    return nom.toString();
  }

  String get soldeFormate {
    final valeur = utilisateur['balance'] ??
        utilisateur['solde'] ??
        utilisateur['balance_htg'] ??
        0;

    final montant = valeur is num
        ? valeur.toDouble()
        : double.tryParse(valeur.toString()) ?? 0;

    return montant.toStringAsFixed(2);
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
                        Text(
                          '$soldeFormate HTG',
                          style: const TextStyle(
                            color: bleuFonce,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                action: () => _message(
                  'Vos codes Wi-Fi apparaîtront ici lorsqu’ils seront disponibles.',
                ),
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
        const SizedBox(height: 20),

        _carteForfait(
          nom: 'Forfait 1 heure',
          details: 'Idéal pour une connexion rapide',
          prix: 'À configurer',
          icone: Icons.schedule,
        ),
        _carteForfait(
          nom: 'Forfait 1 journée',
          details: 'Pour naviguer toute la journée',
          prix: 'À configurer',
          icone: Icons.wb_sunny_outlined,
        ),
        _carteForfait(
          nom: 'Forfait 1 semaine',
          details: 'Pour une utilisation prolongée',
          prix: 'À configurer',
          icone: Icons.calendar_month,
        ),
        const SizedBox(height: 10),
        const Text(
          'Les prix et la durée doivent être reliés aux forfaits configurés par votre serveur.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // PAGE HISTORIQUE
  Widget _construireHistorique() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          'Historique des transactions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: bleuFonce,
          ),
        ),
        SizedBox(height: 18),
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 70,
                  color: Colors.black26,
                ),
                SizedBox(height: 12),
                Text(
                  'Aucune transaction affichée.',
                  style: TextStyle(color: Colors.black54),
                ),
                SizedBox(height: 6),
                Text(
                  'Les données apparaîtront lorsque l’historique sera connecté à l’API.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
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
}
