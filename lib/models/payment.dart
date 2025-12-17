import 'package:intl/intl.dart'; // Pour DateFormat
import 'package:madaure//services/api_service.dart';
import 'package:madaure/models/school.dart'; // ou delivery.dart selon l'écran
class Payment {
  final int id;
  final double amount;
  final String paymentDate;
  final String method;
  final String? referenceNumber;

  Payment({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.method,
    this.referenceNumber,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      paymentDate: json['payment_date'] as String,
      method: json['method'] as String,
      referenceNumber: json['reference_number'] as String?,
    );
  }
}