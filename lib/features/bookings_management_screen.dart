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
      () => Provider.of<BookingProvider>(context, listen: false).listenBookings(),
    );
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '৳', decimalDigits: 2).format(amount);
  }

  void _showBookingModal([BookingModel? booking]) {
    showDialog(
      context: context,
      builder: (context) => _BookingModal(
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () => _showBookingModal(),
              icon: const Icon(Icons.add_circle, color: Color(0xFFFF4F18), size: 32),
            ),
          )
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
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
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
                              Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              const Text(
                                "No bookings found",
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: provider.bookings.length,
                          itemBuilder: (context, index) {
                            final booking = provider.bookings[index];
                            return _BookingCard(
                              booking: booking,
                              formatCurrency: formatCurrency,
                              onEdit: () => _showBookingModal(booking),
                              onDelete: () => provider.deleteBooking(booking.id),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final String Function(double) formatCurrency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BookingCard({
    required this.booking,
    required this.formatCurrency,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              booking.eventType.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFC2410C),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatCurrency(booking.totalPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF4F18),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _IconInfo(icon: Icons.calendar_today_outlined, text: DateFormat('MMM dd, yyyy').format(booking.startDate)),
                    const SizedBox(width: 24),
                    _IconInfo(icon: Icons.access_time, text: "${DateFormat('hh:mm a').format(booking.startDate)} - ${DateFormat('hh:mm a').format(booking.endDate)}"),
                  ],
                ),
                const SizedBox(height: 12),
                _IconInfo(icon: Icons.phone_outlined, text: booking.customerPhone),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                     showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Booking"),
                            content: const Text("Are you sure you want to delete this booking?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                              TextButton(
                                onPressed: () {
                                  onDelete();
                                  Navigator.pop(context);
                                },
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                  },
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                  label: const Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF334155),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Edit", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _IconInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _BookingModal extends StatefulWidget {
  final BookingModel? booking;
  final Function(BookingModel) onSave;

  const _BookingModal({this.booking, required this.onSave});

  @override
  State<_BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends State<_BookingModal> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _priceController;
  late String _eventType;
  late DateTime _startDate;
  late DateTime _endDate;

  final List<String> _eventTypes = [
    'Party',
    'Birthday',
    'Birthday Party',
    'Wedding',
    'Corporate',
    'Seminar',
    'Meeting',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.booking?.customerName ?? '');
    _phoneController = TextEditingController(text: widget.booking?.customerPhone ?? '');
    _priceController = TextEditingController(text: widget.booking?.totalPrice.toString() ?? '0');
    
    // ডাটাবেস থেকে আসা মানটি যদি লিস্টে না থাকে, তবে সেটি লিস্টে যোগ করা হচ্ছে ক্র্যাশ এড়াতে
    String initialType = widget.booking?.eventType ?? 'Party';
    if (!_eventTypes.contains(initialType)) {
      _eventTypes.add(initialType);
    }
    _eventType = initialType;

    _startDate = widget.booking?.startDate ?? DateTime.now();
    _endDate = widget.booking?.endDate ?? DateTime.now().add(const Duration(hours: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.booking == null ? "New Booking" : "Edit Booking",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 24),
              _InputField(label: "CUSTOMER NAME", controller: _nameController, hint: "Enter name"),
              const SizedBox(height: 16),
              _InputField(label: "PHONE NUMBER", controller: _phoneController, hint: "Enter phone number", keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _ModalLabel("EVENT TYPE"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _eventType,
                              items: _eventTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                              onChanged: (v) => setState(() => _eventType = v!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _InputField(label: "PRICE (৳)", controller: _priceController, hint: "0.00", keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _ModalLabel("START DATE & TIME"),
              _DateTimeSelector(
                dateTime: _startDate,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_startDate),
                    );
                    if (time != null) {
                      setState(() => _startDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              const _ModalLabel("END DATE & TIME"),
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
                      setState(() => _endDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                    }
                  }
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        final booking = BookingModel(
                          id: widget.booking?.id ?? '',
                          customerName: _nameController.text,
                          customerPhone: _phoneController.text,
                          eventType: _eventType,
                          startDate: _startDate,
                          endDate: _endDate,
                          status: widget.booking?.status ?? 'confirmed',
                          totalPrice: double.tryParse(_priceController.text) ?? 0.0,
                        );
                        widget.onSave(booking);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4F18),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(widget.booking == null ? "Create Booking" : "Save Changes", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        _ModalLabel(label),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF4F18))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime), style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500)),
            const Icon(Icons.calendar_month, size: 20, color: Color(0xFFFF4F18)),
          ],
        ),
      ),
    );
  }
}

class _ModalLabel extends StatelessWidget {
  final String text;
  const _ModalLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1),
      ),
    );
  }
}