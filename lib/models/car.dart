class Car {
  final String id;
  final String name;
  final String brand;
  final String price;
  final String rating;
  final String type;
  final String image;
  final String transmission;
  final String seats;
  final String fuel;
  bool isFavorite;

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.rating,
    required this.type,
    required this.image,
    required this.transmission,
    required this.seats,
    required this.fuel,
    this.isFavorite = false,
  });
}