import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/booking_provider.dart';
import '../model/booking_model.dart';

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

  void _showCreateBookingModal() {
    showDialog(
      context: context,
      builder: (context) => _CreateBookingModal(
        onSave: (booking) {
          Provider.of<BookingProvider>(
            context,
            listen: false,
          ).createBooking(booking);
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
          "Event Bookings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Manage and schedule\nrestaurant events",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showCreateBookingModal,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text("Create Booking"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (provider.bookings.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 80),
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No bookings scheduled yet.",
                              style: TextStyle(color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: constraints.maxWidth > 900
                                ? 3
                                : constraints.maxWidth > 600
                                ? 2
                                : 1,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: provider.bookings.length,
                          itemBuilder: (context, index) {
                            final booking = provider.bookings[index];

                            return _BookingCard(
                              booking: booking,
                              formatCurrency: formatCurrency,
                              onDelete: () => provider.deleteBooking(booking.id),
                            );
                          },
                        );
                      },
                    )
                ],
              ),
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final String Function(double) formatCurrency;
  final VoidCallback onDelete;

  const _BookingCard({
    required this.booking,
    required this.formatCurrency,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isConfirmed = booking.status == 'confirmed';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 6,
            child: Container(color: isConfirmed ? Colors.green : Colors.orange),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.eventType.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatCurrency(booking.totalPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF4F18),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: DateFormat('PPP p').format(booking.startDate),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.access_time,
                  text: "Till ${DateFormat('p').format(booking.endDate)}",
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  text: booking.customerPhone,
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          "Edit Details",
                          style: TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Booking"),
                            content: const Text(
                              "Are you sure you want to delete this booking?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  onDelete();
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
        ),
      ],
    );
  }
}

class _CreateBookingModal extends StatefulWidget {
  final Function(BookingModel) onSave;

  const _CreateBookingModal({required this.onSave});

  @override
  State<_CreateBookingModal> createState() => _CreateBookingModalState();
}

class _CreateBookingModalState extends State<_CreateBookingModal> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();
  final String _eventType = 'Party';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 2));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New Event Booking",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _InputField(
                    label: "CUSTOMER NAME",
                    controller: _nameController,
                    hint: "John Doe",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InputField(
                    label: "PHONE",
                    controller: _phoneController,
                    hint: "555-0123",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "START DATE & TIME",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            _DateTimeSelector(
              dateTime: _startDate,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_startDate),
                  );
                  if (time != null) {
                    setState(
                      () => _startDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              "END DATE & TIME",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            _DateTimeSelector(
              dateTime: _endDate,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: _startDate,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_endDate),
                  );
                  if (time != null) {
                    setState(
                      () => _endDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            _InputField(
              label: "TOTAL PRICE",
              controller: _priceController,
              hint: "0.00",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final booking = BookingModel(
                        id: '',
                        customerName: _nameController.text,
                        customerPhone: _phoneController.text,
                        eventType: _eventType,
                        startDate: _startDate,
                        endDate: _endDate,
                        status: 'confirmed',
                        totalPrice:
                            double.tryParse(_priceController.text) ?? 0.0,
                      );
                      widget.onSave(booking);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4F18),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Create Booking",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateTimeSelector extends StatelessWidget {
  final DateTime dateTime;
  final VoidCallback onTap;

  const _DateTimeSelector({required this.dateTime, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('PPP p').format(dateTime),
              style: const TextStyle(color: Color(0xFF0F172A)),
            ),
            const Icon(
              Icons.calendar_today,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
