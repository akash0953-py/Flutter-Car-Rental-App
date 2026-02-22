import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent_x/models/booking_model.dart';


class BookingManager {
  // Singleton pattern
  static final BookingManager _instance = BookingManager._internal();
  factory BookingManager() => _instance;
  BookingManager._internal();

  // In-memory list of bookings
  final List<Booking> _bookings = [];

  // Key for shared preferences
  static const String _bookingsKey = 'user_bookings';

  // Get all bookings
  List<Booking> get bookings => List.unmodifiable(_bookings);

  // Add a new booking
  Future<void> addBooking(Booking booking) async {
    _bookings.insert(0, booking); // Add at the beginning (newest first)
    await _saveToStorage();
  }

  // Remove a booking
  Future<void> removeBooking(String bookingId) async {
    _bookings.removeWhere((booking) => booking.id == bookingId);
    await _saveToStorage();
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final booking = _bookings[index];
      _bookings[index] = Booking(
        id: booking.id,
        car: booking.car,
        pickupDate: booking.pickupDate,
        dropDate: booking.dropDate,
        totalDays: booking.totalDays,
        totalPrice: booking.totalPrice,
        bookingDate: booking.bookingDate,
        status: newStatus,
      );
      await _saveToStorage();
    }
  }

  // Get booking by ID
  Booking? getBookingById(String bookingId) {
    try {
      return _bookings.firstWhere((b) => b.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  // Clear all bookings
  Future<void> clearAllBookings() async {
    _bookings.clear();
    await _saveToStorage();
  }

  // Save bookings to persistent storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = _bookings.map((b) => b.toJson()).toList();
      await prefs.setString(_bookingsKey, jsonEncode(bookingsJson));
    } catch (e) {
      print('Error saving bookings: $e');
    }
  }

  // Load bookings from persistent storage
  Future<void> loadBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsString = prefs.getString(_bookingsKey);

      if (bookingsString != null) {
        final List<dynamic> bookingsJson = jsonDecode(bookingsString);
        _bookings.clear();
        _bookings.addAll(
          bookingsJson.map((json) => Booking.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      print('Error loading bookings: $e');
    }
  }

  // Get bookings by status
  List<Booking> getBookingsByStatus(String status) {
    return _bookings.where((b) => b.status == status).toList();
  }

  // Get upcoming bookings (pickup date in future)
  List<Booking> getUpcomingBookings() {
    final now = DateTime.now();
    return _bookings.where((b) => b.pickupDate.isAfter(now)).toList();
  }

  // Get active bookings (currently ongoing)
  List<Booking> getActiveBookings() {
    final now = DateTime.now();
    return _bookings.where((b) =>
    b.pickupDate.isBefore(now) && b.dropDate.isAfter(now)
    ).toList();
  }

  // Get past bookings
  List<Booking> getPastBookings() {
    final now = DateTime.now();
    return _bookings.where((b) => b.dropDate.isBefore(now)).toList();
  }
}