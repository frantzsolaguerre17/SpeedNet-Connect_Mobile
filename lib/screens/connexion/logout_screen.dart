import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class InscriptionScreen extends StatefulWidget {
const InscriptionScreen({super.key});

@override
State<InscriptionScreen> createState() =>
_InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
final _formKey = GlobalKey<FormState>();
final _nomController = TextEditingController();
final _telephoneController = TextEditingController();
final _emailController = TextEditingController();
final _motDePasseController = TextEditingController();

bool _chargement = false;
bool _afficherMotDePasse = false;

@override
void dispose() {
_nomController.dispose();
_telephoneController.dispose();
_emailController.dispose();
_motDePasseController.dispose();
super.dispose();
}

Future<void> _inscrire() async {
if (!_formKey.currentState!.validate()) return;

setState(() => _chargement = true);

try {
await ApiService.inscrireUtilisateur(
nom: _nomController.text.trim(),
telephone: _telephoneController.text.trim(),
email: _emailController.text.trim(),
motDePasse: _motDePasseController.text,
);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Compte créé avec succès ! Connectez-vous.'),
backgroundColor: Colors.green,
),
);

Navigator.pop(context);
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
appBar: AppBar(
title: const Text('Créer un compte'),
backgroundColor: bleu,
foregroundColor: Colors.white,
),
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
Icons.person_add_alt_1_rounded,
size: 70,
color: bleu,
),
const SizedBox(height: 12),
const Text(
'Rejoignez SpeedNetConnect',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 23,
fontWeight: FontWeight.bold,
color: bleu,
),
),
const SizedBox(height: 28),

TextFormField(
controller: _nomController,
textCapitalization: TextCapitalization.words,
decoration: _decoration(
'Nom complet',
Icons.person_outline,
),
validator: (value) =>
value == null || value.trim().isEmpty
? 'Saisissez votre nom complet.'
    : null,
),
const SizedBox(height: 16),

TextFormField(
controller: _telephoneController,
keyboardType: TextInputType.phone,
decoration: _decoration(
'Numéro de téléphone',
Icons.phone_outlined,
),
validator: (value) =>
value == null || value.trim().isEmpty
? 'Saisissez votre numéro de téléphone.'
    : null,
),
const SizedBox(height: 16),

TextFormField(
controller: _emailController,
keyboardType: TextInputType.emailAddress,
decoration: _decoration(
'Adresse e-mail',
Icons.email_outlined,
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'Saisissez votre adresse e-mail.';
}
if (!value.contains('@') ||
!value.contains('.')) {
return 'Adresse e-mail invalide.';
}
return null;
},
),
const SizedBox(height: 16),

TextFormField(
controller: _motDePasseController,
obscureText: !_afficherMotDePasse,
decoration: _decoration(
'Mot de passe',
Icons.lock_outline,
).copyWith(
suffixIcon: IconButton(
icon: Icon(
_afficherMotDePasse
? Icons.visibility_off
    : Icons.visibility,
),
onPressed: () {
setState(() {
_afficherMotDePasse =
!_afficherMotDePasse;
});
},
),
),
validator: (value) {
if (value == null || value.length < 8) {
return '8 caractères minimum.';
}
return null;
},
),
const SizedBox(height: 24),

SizedBox(
height: 52,
child: ElevatedButton(
onPressed: _chargement ? null : _inscrire,
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
'Créer mon compte',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
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

InputDecoration _decoration(String label, IconData icone) {
return InputDecoration(
labelText: label,
prefixIcon: Icon(icone),
filled: true,
fillColor: Colors.white,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
),
);
}
}
