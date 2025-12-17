// Modèle pour les statistiques du Tableau de Bord
class DistributorStats {
  final int totalDeliveries;
  final double totalDeliveredAmount;
  final double totalPaid;
  final double remaining;
  final int monthlyDeliveries;
  final double monthlyAmount;
  final int schoolsServed;

  DistributorStats({
    required this.totalDeliveries,
    required this.totalDeliveredAmount,
    required this.totalPaid,
    required this.remaining,
    required this.monthlyDeliveries,
    required this.monthlyAmount,
    required this.schoolsServed,
  });

  factory DistributorStats.fromJson(Map<String, dynamic> json) {
    // Utiliser double.tryParse ou convertir à double si l'API renvoie des montants comme Strings
    return DistributorStats(
      totalDeliveries: json['total_deliveries'] as int,
      totalDeliveredAmount: double.tryParse(json['total_delivered_amount'].toString()) ?? 0.0,
      totalPaid: double.tryParse(json['total_paid'].toString()) ?? 0.0,
      remaining: double.tryParse(json['remaining'].toString()) ?? 0.0,
      monthlyDeliveries: json['monthly_deliveries'] as int,
      monthlyAmount: double.tryParse(json['monthly_amount'].toString()) ?? 0.0,
      schoolsServed: json['schools_served'] as int,
    );
  }
}