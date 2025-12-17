import 'package:flutter/material.dart';
import 'package:madaure/main.dart';
import 'package:madaure/screens/auth_wrapper.dart';
import 'package:madaure/models/user.dart'; // Import du modèle User
import 'add_delivery_screen.dart';
import 'add_school_screen.dart';
import 'add_payment_screen.dart';

class DistributorDashboardScreen extends StatefulWidget {
  const DistributorDashboardScreen({super.key});

  @override
  State<DistributorDashboardScreen> createState() => _DistributorDashboardScreenState();
}

class _DistributorDashboardScreenState extends State<DistributorDashboardScreen> {
  Map<String, dynamic>? _dashboardData;
  User? _currentUser; // Stockage de l'utilisateur réel
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Charger le profil utilisateur depuis le serveur
      final userData = await apiService.fetchUserProfile();
      if (userData != null) {
        _currentUser = User.fromJson(userData);
      }

      // 2. Charger les statistiques réelles
      final data = await apiService.fetchDistributorDashboard();

      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur de connexion au serveur. Vérifiez votre réseau.";
        _isLoading = false;
      });
      print('❌ Dashboard load error: $e');
    }
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await apiService.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthWrapper()),
                      (route) => false,
                );
              }
            },
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Madaure Distribution'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDashboardData),
          IconButton(icon: const Icon(Icons.logout), onPressed: _onLogout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 24),
              const Text('Vos Statistiques', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildStatGrid(),
              const SizedBox(height: 24),
              const Text('Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildActionCards(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.blue)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, ${_currentUser?.name ?? "Distributeur"}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Wilaya : ${_currentUser?.wilaya ?? "Non assignée"}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    final stats = _dashboardData?['stats'] ?? {};
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.3,
      children: [
        _statCard('Livrées', '${stats['total_deliveries'] ?? 0}', Icons.local_shipping, Colors.blue),
        _statCard('Total DA', '${stats['total_delivered_amount'] ?? 0}', Icons.payments, Colors.green),
        _statCard('Payé', '${stats['total_paid'] ?? 0}', Icons.check_circle, Colors.teal),
        _statCard('Restant', '${stats['remaining'] ?? 0}', Icons.warning, Colors.orange),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards() {
    return Column(
      children: [
        _actionTile('Ajouter une École', Icons.school, Colors.purple, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSchoolScreen()));
        }),
        _actionTile('Enregistrer un Paiement', Icons.account_balance_wallet, Colors.teal, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPaymentScreen()));
        }),
      ],
    );
  }

  Widget _actionTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage!),
          ElevatedButton(onPressed: _loadDashboardData, child: const Text('Réessayer')),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDeliveryScreen())),
      label: const Text('Nouvelle Livraison'),
      icon: const Icon(Icons.add),
    );
  }
}