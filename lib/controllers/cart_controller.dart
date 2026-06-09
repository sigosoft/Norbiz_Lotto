import 'package:get/get.dart';
import '../models/ticket_model.dart';
import 'auth_controller.dart';

class CartController extends GetxController {
  var cartTickets = <TicketModel>[].obs;

  double get subtotal =>
      cartTickets.fold(0.0, (sum, ticket) => sum + ticket.betAmount);
  double get serviceFee => cartTickets.isEmpty ? 0.0 : 1.00; // Flat fee
  double get total => subtotal + serviceFee;

  void addTicket(String gameName, String numbers, double amount) {
    String id =
        '#NZL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Check if ticket already exists in cart, then update or add new
    cartTickets.add(
      TicketModel(
        id: id,
        gameName: gameName,
        numbers: numbers,
        date: 'MAR 11, 2026 • 2:00 PM', // Match Figma mock dates
        betAmount: amount,
        status: TicketStatus.pending,
      ),
    );
  }

  void removeTicket(int index) {
    if (index >= 0 && index < cartTickets.length) {
      cartTickets.removeAt(index);
    }
  }

  void clearCart() {
    cartTickets.clear();
  }

  bool checkout() {
    if (cartTickets.isEmpty) return false;

    // Deduct amount
    final authController = Get.find<AuthController>();
    authController.userWalletBalance.value -= total;

    return true;
  }
}
