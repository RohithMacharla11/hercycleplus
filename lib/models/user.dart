import 'package:flutter/foundation.dart';
import '../enums/symptom.dart'; // Assuming Symptom enum is in a separate file

class User with ChangeNotifier {
  String _selectedFlow = '';
  final List<Symptom> _selectedSymptoms = [];

  // Cart management
  final Map<String, int> _cart = {};
  final Map<String, double> _itemPrices = {
    'Stayfree Secure Pads': 189.0,
    'Ibuprofen (Pain Relief)': 120.0,
    'Sofy Antibacterial Pads': 250.0,
    'Heat Patch (Cramps)': 150.0,
    'Stayfree Overnight Pads': 199.0,
    'Menstrual Cup (Medium)': 300.0,
    'Whisper Ultra Pads': 212.0,
  };

  // Getters for flow and symptoms
  String get selectedFlow => _selectedFlow;
  List<Symptom> get selectedSymptoms => List<Symptom>.unmodifiable(_selectedSymptoms);

  // Getters for cart
  Map<String, int> get cartItems => Map<String, int>.unmodifiable(_cart);

  double get cartTotal {
    double total = 0.0;
    _cart.forEach((item, quantity) {
      final price = _itemPrices[item] ?? 0.0;
      total += price * (quantity > 0 ? quantity : 0);
    });
    return total;
  }

  // Set flow intensity
  void setFlow(String? flow) {
    _selectedFlow = flow?.trim() ?? '';
    notifyListeners();
  }

  // Toggle symptoms using Symptom enum (non-nullable)
  void toggleSymptom(Symptom symptom) {
    if (_selectedSymptoms.contains(symptom)) {
      _selectedSymptoms.remove(symptom);
    } else {
      _selectedSymptoms.add(symptom);
    }
    notifyListeners();
  }

  // Clear symptoms
  void clearSymptoms() {
    _selectedSymptoms.clear();
    notifyListeners();
  }

  // Add item to cart
  void addToCart(String? item) {
    if (item == null || !_itemPrices.containsKey(item)) return;
    _cart[item] = (_cart[item] ?? 0) + 1;
    notifyListeners();
  }

  // Remove item from cart
  void removeFromCart(String? item) {
    if (item == null || !_cart.containsKey(item)) return;
    if (_cart[item]! > 0) {
      _cart[item] = _cart[item]! - 1;
      if (_cart[item] == 0) {
        _cart.remove(item);
      }
      notifyListeners();
    }
  }

  // Clear cart (e.g., after checkout)
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
  
}
