
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TransfertScreen extends StatefulWidget {
  final String accessToken;
  final VoidCallback onTransfertReussi;

  const TransfertScreen({
    super.key,
    required this.accessToken,
    required this.onTransfertReussi,
  });

  @override
  State<TransfertScreen> createState() => _TransfertScreenState();
}

class _TransfertScreenState extends State<TransfertScreen> {
  static const Color bleu = Color(0xFF1455C0);
  static const Color bleuFonce = Color(0xFF103B82);

  final _formKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  final _montantController = TextEditingController();

  bool _envoiEnCours = false;

  @override
  void dispose() {
    _telephoneController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _transferer() async {
    if (!_formKey.currentState!.validate() || _envoiEnCours) {
      return;
    }

    final confirmer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmer le transfert'),
        content: Text(
          'Envoyer ${_montantController.text.trim()} HTG au numéro '
              '${_telephoneController.text.trim()} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmer != true || !mounted) return;

    setState(() => _envoiEnCours = true);

    try {
      final resultat = await ApiService.transfererArgent(
        accessToken: widget.accessToken,
        phone: _telephoneController.text.trim(),
        amount: _montantController.text.trim(),
      );

      if (!mounted) return;

      widget.onTransfertReussi();

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
          title: const Text('Transfert réussi'),
          content: Text(
            '${resultat['message'] ?? 'Transfert effectué avec succès.'}\n\n'
                'Destinataire : ${resultat['recipient_phone'] ?? _telephoneController.text}\n'
                'Montant : ${resultat['amount'] ?? _montantController.text} '
                '${resultat['currency'] ?? 'HTG'}\n'
                'Nouveau solde : ${resultat['balance'] ?? ''} '
                '${resultat['currency'] ?? 'HTG'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      _telephoneController.clear();
      _montantController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _envoiEnCours = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: bleu,
        foregroundColor: Colors.white,
        title: const Text(
          'Transfert d’argent',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 38,
                ),
                SizedBox(height: 14),
                Text(
                  'Envoyez de l’argent à un autre client',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Vérifiez le numéro et le montant avant de confirmer.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Numéro du destinataire',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Ex. : numéro du client',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Saisissez le numéro du destinataire.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Montant à envoyer (HTG)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _montantController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ex. : 250.00',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    suffixText: 'HTG',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    final montant = DecimalParser.parse(value);

                    if (montant == null || montant <= 0) {
                      return 'Saisissez un montant supérieur à zéro.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _envoiEnCours ? null : _transferer,
                    icon: _envoiEnCours
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.send),
                    label: Text(
                      _envoiEnCours
                          ? 'Transfert en cours...'
                          : 'Confirmer le transfert',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bleu,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DecimalParser {
  static double? parse(String? value) {
    if (value == null) return null;
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }
}
