import 'package:rent_x/models/car.dart';

class Booking {
  final String id;
  final Car car;
  final DateTime pickupDate;
  final DateTime dropDate;
  final int totalDays;
  final double totalPrice;
  final DateTime bookingDate;
  final String status; // 'confirmed', 'active', 'completed', 'cancelled'

  Booking({
    required this.id,
    required this.car,
    required this.pickupDate,
    required this.dropDate,
    required this.totalDays,
    required this.totalPrice,
    required this.bookingDate,
    this.status = 'confirmed',
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car': {
        'id': car.id,
        'name': car.name,
        'brand': car.brand,
        'price': car.price,
        'rating': car.rating,
        'type': car.type,
        'image': car.image,
        'transmission': car.transmission,
        'seats': car.seats,
        'fuel': car.fuel,
      },
      'pickupDate': pickupDate.toIso8601String(),
      'dropDate': dropDate.toIso8601String(),
      'totalDays': totalDays,
      'totalPrice': totalPrice,
      'bookingDate': bookingDate.toIso8601String(),
      'status': status,
    };
  }

  // Create from JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    final carJson = json['car'];

    return Booking(
      id: json['id'],
      car: Car(
        id: carJson['id'],
        name: carJson['name'],
        brand: carJson['brand'],
        price: carJson['price'],
        rating: carJson['rating'].toString(),
        type: carJson['type'],
        image: carJson['image'],
        transmission: carJson['transmission'],
        seats: carJson['seats'].toString(),
        fuel: carJson['fuel'],
      ),
      pickupDate: DateTime.parse(json['pickupDate']),
      dropDate: DateTime.parse(json['dropDate']),
      totalDays: json['totalDays'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
      bookingDate: DateTime.parse(json['bookingDate']),
      status: json['status'],
    );
  }

}