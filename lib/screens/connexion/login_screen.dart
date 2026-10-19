import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../screens/connexion/logout_screen.dart';
import '../dashboard_screen.dart';

class ConnexionScreen extends StatefulWidget {
const ConnexionScreen({super.key});

@override
State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
final _formKey = GlobalKey<FormState>();
final _telephoneController = TextEditingController();
final _motDePasseController = TextEditingController();

bool _chargement = false;
bool _afficherMotDePasse = false;

@override
void dispose() {
_telephoneController.dispose();
_motDePasseController.dispose();
super.dispose();
}

Future<void> _connecter() async {
if (!_formKey.currentState!.validate()) return;

setState(() => _chargement = true);

try {
final resultat = await ApiService.connecterUtilisateur(
telephone: _telephoneController.text.trim(),
motDePasse: _motDePasseController.text,
);

final utilisateur = Map<String, dynamic>.from(
resultat['user'] as Map,
);

if (!mounted) return;

if (utilisateur['role'] != 'user') {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Cette application est réservée aux clients.',
),
),
);
return;
}

Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (_) => DashboardScreen(utilisateur: utilisateur),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
e.toString().replaceFirst('Exception: ', ''),
),
backgroundColor: Colors.red,
),
);
} finally {
if (mounted) {
setState(() => _chargement = false);
}
}
}

@override
Widget build(BuildContext context) {
const bleu = Color(0xFF1565C0);

return Scaffold(
backgroundColor: const Color(0xFFF5F7FB),
body: SafeArea(
child: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: Form(
key: _formKey,
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
const Icon(
Icons.wifi_rounded,
size: 76,
color: bleu,
),
const SizedBox(height: 12),
const Text(
'SpeedNetConnect',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
color: bleu,
),
),
const SizedBox(height: 8),
const Text(
'Connectez-vous à votre compte',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 16,
color: Colors.black54,
),
),
const SizedBox(height: 36),

TextFormField(
controller: _telephoneController,
keyboardType: TextInputType.phone,
decoration: InputDecoration(
labelText: 'Numéro de téléphone',
prefixIcon: const Icon(Icons.phone_outlined),
filled: true,
fillColor: Colors.white,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'Saisissez votre numéro de téléphone.';
}
return null;
},
),
const SizedBox(height: 18),

TextFormField(
controller: _motDePasseController,
obscureText: !_afficherMotDePasse,
decoration: InputDecoration(
labelText: 'Mot de passe',
prefixIcon: const Icon(Icons.lock_outline),
suffixIcon: IconButton(
icon: Icon(
_afficherMotDePasse
? Icons.visibility_off
    : Icons.visibility,
),
onPressed: () {
setState(() {
_afficherMotDePasse = !_afficherMotDePasse;
});
},
),
filled: true,
fillColor: Colors.white,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
),
),
validator: (value) {
if (value == null || value.isEmpty) {
return 'Saisissez votre mot de passe.';
}
return null;
},
),
const SizedBox(height: 26),

SizedBox(
height: 52,
child: ElevatedButton(
onPressed: _chargement ? null : _connecter,
style: ElevatedButton.styleFrom(
backgroundColor: bleu,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
child: _chargement
? const CircularProgressIndicator(
color: Colors.white,
)
    : const Text(
'Se connecter',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
),
),
const SizedBox(height: 18),

TextButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const InscriptionScreen(),
),
);
},
child: const Text(
'Pas encore de compte ? Créer un compte',
),
),
],
),
),
),
),
),
);
}
}
