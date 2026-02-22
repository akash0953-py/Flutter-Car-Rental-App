import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rent_x/managers/booking_manager.dart';
import 'package:rent_x/models/booking_model.dart';


class BookingScreen extends StatefulWidget {
  final dynamic car; // Can accept either Car model

  const BookingScreen({Key? key, required this.car}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _pickupDate;
  DateTime? _dropDate;

  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final BookingManager _bookingManager = BookingManager();

  // UPI Payment details - replace with your actual UPI ID
  final String _upiId = '';
  final String _upiName = 'Car Rental Service';

  int get _totalDays {
    if (_pickupDate == null || _dropDate == null) return 0;
    return _dropDate!.difference(_pickupDate!).inDays + 1;
  }

  double get _totalPrice {
    final pricePerDay = double.parse(widget.car.price);
    return _totalDays * pricePerDay;
  }

  bool get _isValidBooking {
    if (_pickupDate == null || _dropDate == null) return false;
    return _dropDate!.isAfter(_pickupDate!);
  }

  Future<void> _selectPickupDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFC107),
              onPrimary: Color(0xFF000000),
              surface: Color(0xFF1C1C1C),
              onSurface: Color(0xFFFFFFFF),
            ),
            dialogBackgroundColor: const Color(0xFF1C1C1C),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _pickupDate = picked;
        if (_dropDate != null && _dropDate!.isBefore(picked)) {
          _dropDate = null;
        }
      });
    }
  }

  Future<void> _selectDropDate() async {
    final DateTime initialDate = _dropDate ??
        (_pickupDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1)));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _pickupDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFC107),
              onPrimary: Color(0xFF000000),
              surface: Color(0xFF1C1C1C),
              onSurface: Color(0xFFFFFFFF),
            ),
            dialogBackgroundColor: const Color(0xFF1C1C1C),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dropDate = picked;
      });
    }
  }

  Future<void> _initiatePayment() async {
    if (!_isValidBooking) return;

    try {
      // Generate unique booking ID
      final bookingId = 'BKG${DateTime.now().millisecondsSinceEpoch}';

      // Create booking object
      final booking = Booking(
        id: bookingId,
        car: widget.car,
        pickupDate: _pickupDate!,
        dropDate: _dropDate!,
        totalDays: _totalDays,
        totalPrice: _totalPrice,
        bookingDate: DateTime.now(),
        status: 'confirmed', // or 'pending' if you want later payment
      );

      // Save booking
      await _bookingManager.addBooking(booking);

      // ✅ Directly navigate to confirmation screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              booking: booking,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Booking failed: $e');
    }
  }


  String _buildUpiUrl() {
    final amount = _totalPrice.toStringAsFixed(2);
    final String transactionNote = 'Car Rental - ${widget.car.name}';

    return 'upi://pay?pa=$_upiId&pn=$_upiName&am=$amount&cu=INR&tn=${Uri.encodeComponent(transactionNote)}';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          'Payment Error',
          style: TextStyle(color: Color(0xFFFFC107)),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFFFFFFFF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFFFFC107)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Your Ride',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCarDetailsCard(),
              const SizedBox(height: 24),
              const Text(
                'Select Dates',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDateSelector(
                label: 'Pickup Date',
                date: _pickupDate,
                onTap: _selectPickupDate,
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 12),
              _buildDateSelector(
                label: 'Drop Date',
                date: _dropDate,
                onTap: _selectDropDate,
                icon: Icons.event,
              ),
              const SizedBox(height: 24),
              if (_totalDays > 0) _buildPriceBreakdown(),
              const SizedBox(height: 32),
              _buildPaymentButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              widget.car.image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: const Color(0xFF2C2C2C),
                  child: const Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Color(0xFFFFC107),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.car.name,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee,
                      color: Color(0xFFFFC107),
                      size: 20,
                    ),
                    Text(
                      widget.car.price,
                      style: const TextStyle(
                        color: Color(0xFFFFC107),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ' / day',
                      style: TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null ? const Color(0xFFFFC107) : const Color(0xFF2C2C2C),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFFFC107),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null ? _dateFormatter.format(date) : 'Select Date',
                    style: TextStyle(
                      color: date != null ? const Color(0xFFFFFFFF) : const Color(0xFF666666),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF666666),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Breakdown',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Price per day', '₹${widget.car.price}'),
          const SizedBox(height: 8),
          _buildPriceRow('Total days', '$_totalDays ${_totalDays == 1 ? 'day' : 'days'}'),
          const Divider(color: Color(0xFF2C2C2C), height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.currency_rupee,
                    color: Color(0xFFFFC107),
                    size: 24,
                  ),
                  Text(
                    _totalPrice.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFAAAAAA),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isValidBooking ? _initiatePayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC107),
          disabledBackgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        Image.asset(
              'images/google_pay_logo.png',
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.payment,
                  color: Color(0xFF000000),
                  size: 24,
                );
              },
            ),
            // const Icon(
            //   Icons.payment,
            //   color: Color(0xFF000000),
            //   size: 24,
            // ),
            const SizedBox(width: 12),
            Text(
              _isValidBooking
                  ? 'Pay ₹${_totalPrice.toStringAsFixed(0)} with Google Pay'
                  : 'Select dates to continue',
              style: TextStyle(
                color: _isValidBooking ? const Color(0xFF000000) : const Color(0xFF666666),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Booking Confirmation Screen
class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Booking Confirmed',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [

                const SizedBox(height: 20),

                // Success Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFFFFC107),
                    size: 80,
                  ),
                ),

                const SizedBox(height: 32),

                // Success Text
                const Text(
                  'Booking Successful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Your payment has been processed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                // Booking Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Booking ID', booking.id),
                      const Divider(color: Color(0xFF2C2C2C), height: 24),
                      _buildDetailRow('Car', booking.car.name),
                      const Divider(color: Color(0xFF2C2C2C), height: 24),
                      _buildDetailRow(
                        'Pickup',
                        dateFormatter.format(booking.pickupDate),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Drop',
                        dateFormatter.format(booking.dropDate),
                      ),
                      const Divider(color: Color(0xFF2C2C2C), height: 24),
                      _buildDetailRow(
                        'Total Days',
                        '${booking.totalDays} days',
                      ),
                      const SizedBox(height: 12),

                      // Total Paid Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Paid',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.currency_rupee,
                                color: Color(0xFFFFC107),
                                size: 20,
                              ),
                              Text(
                                booking.totalPrice.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: Color(0xFFFFC107),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Back To Home Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFAAAAAA),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}