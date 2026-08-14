import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../model/booking_model.dart';
import '../../provider/booking_provider.dart';
import 'widgets/event_booking/add_event_booking_dialog_widget.dart';
import 'widgets/event_booking/event_booking_card.dart';

class BookingsManagementScreen extends StatefulWidget {
  const BookingsManagementScreen({super.key});

  @override
  State<BookingsManagementScreen> createState() =>
      _BookingsManagementScreenState();
}

class _BookingsManagementScreenState extends State<BookingsManagementScreen> {
  final Color primaryColor = const Color(0xFFFF4F18);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<BookingProvider>(context, listen: false).listenBookings(),
    );
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '৳', decimalDigits: 2).format(amount);
  }

  void _showBookingModal([BookingModel? booking]) {
    showDialog(
      context: context,
      builder: (context) => AddEventBookingDialogWidget(
        booking: booking,
        onSave: (newBooking) {
          final provider = Provider.of<BookingProvider>(context, listen: false);
          if (booking == null) {
            provider.createBooking(newBooking);
          } else {
            provider.updateBooking(newBooking);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Bookings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () => _showBookingModal(),
              icon: const Icon(
                Icons.add_circle,
                color: Color(0xFFFF4F18),
                size: 32,
              ),
            ),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Manage your restaurant event schedules",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: provider.bookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "No bookings found",
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: provider.bookings.length,
                          itemBuilder: (context, index) {
                            final booking = provider.bookings[index];
                            return EventBookingCard(
                              booking: booking,
                              formatCurrency: formatCurrency,
                              onEdit: () => _showBookingModal(booking),
                              onDelete: () =>
                                  provider.deleteBooking(booking.id),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
