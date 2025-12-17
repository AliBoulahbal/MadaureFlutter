import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:madaure/services/api_service.dart';
import 'package:madaure/models/delivery.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();

  Delivery? _selectedDelivery;
  DateTime? _selectedDate;
  String? _selectedMethod;
  List<Delivery> _deliveries = [];
  bool _isLoading = false;

  final List<String> _paymentMethods = ['cash', 'check', 'bank_transfer', 'mobile_money'];

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    setState(() => _isLoading = true);
    try {
      // CORRECTION: fetchMyDeliveries() retourne List<Map<String, dynamic>>
      final deliveriesData = await apiService.fetchMyDeliveries();

      // Convertir List<Map> en List<Delivery>
      final List<Delivery> deliveries = deliveriesData.map((deliveryMap) {
        return Delivery.fromJson(deliveryMap);
      }).toList();

      setState(() => _deliveries = deliveries); // ✅ Maintenant les types correspondent
    } catch (e) {
      print('Error loading deliveries: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement des livraisons: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }


  // --- FONCTION DE SOUMISSION CORRIGÉE ---
  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate() || _selectedDelivery == null || _selectedDate == null || _selectedMethod == null) {
      return;
    }

    setState(() => _isLoading = true);

    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final String reference = _referenceController.text.trim();

    try {
      // Utilise la méthode addPayment nouvellement ajoutée à ApiService
      await apiService.addPayment(
        deliveryId: _selectedDelivery!.id,
        amount: amount,
        paymentMethod: _selectedMethod!,
        reference: reference,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement enregistré avec succès!')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('❌ Erreur d\'enregistrement du paiement: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'enregistrement du paiement : $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un Paiement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Liste déroulante des livraisons
              DropdownButtonFormField<Delivery>(
                decoration: const InputDecoration(
                  labelText: 'Livraison',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDelivery,
                items: _deliveries.map((delivery) {
                  return DropdownMenuItem<Delivery>(
                    value: delivery,
                    // Affiche la livraison: Date - École - Prix
                    child: Text('${delivery.deliveryDate} - ${delivery.schoolName} (${delivery.finalPrice} DZD)'),
                  );
                }).toList(),
                onChanged: (Delivery? newValue) {
                  setState(() => _selectedDelivery = newValue);
                },
                validator: (value) => value == null ? 'Veuillez sélectionner une livraison' : null,
              ),

              const SizedBox(height: 16),

              // Sélecteur de méthode de paiement
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Méthode de Paiement',
                  border: OutlineInputBorder(),
                ),
                value: _selectedMethod,
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method.toUpperCase().replaceAll('_', ' ')),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _selectedMethod = newValue);
                },
                validator: (value) => value == null ? 'Veuillez sélectionner une méthode' : null,
              ),

              const SizedBox(height: 16),

              // Champ Montant
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant (DZD)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer un montant';
                  if (double.tryParse(value) == null) return 'Veuillez entrer un montant valide';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Référence (optionnel)
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Référence (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // Bouton de soumission
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Enregistrer le Paiement'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}