import 'package:flutter/material.dart';
import 'package:restaurant_management/features/admin/widgets/event_booking/add_event_dialog_label_widget.dart';

import '../../../../model/booking_model.dart';
import 'add_event_dialog_input_field_widget.dart';

class AddEventBookingDialogWidget extends StatefulWidget {
  final BookingModel? booking;
  final Function(BookingModel) onSave;

  const AddEventBookingDialogWidget({super.key, this.booking, required this.onSave});

  @override
  State<AddEventBookingDialogWidget> createState() => _AddEventBookingDialogWidgetState();
}

class _AddEventBookingDialogWidgetState extends State<AddEventBookingDialogWidget> {
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
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.booking?.customerName ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.booking?.customerPhone ?? '',
    );
    _priceController = TextEditingController(
      text: widget.booking?.totalPrice.toString() ?? '0',
    );

    // ডাটাবেস থেকে আসা মানটি যদি লিস্টে না থাকে, তবে সেটি লিস্টে যোগ করা হচ্ছে ক্র্যাশ এড়াতে
    String initialType = widget.booking?.eventType ?? 'Party';
    if (!_eventTypes.contains(initialType)) {
      _eventTypes.add(initialType);
    }
    _eventType = initialType;

    _startDate = widget.booking?.startDate ?? DateTime.now();
    _endDate =
        widget.booking?.endDate ?? DateTime.now().add(const Duration(hours: 2));
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
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 24),
              AddEventDialogInputFieldWidget(
                label: "CUSTOMER NAME",
                controller: _nameController,
                hint: "Enter name",
              ),
              const SizedBox(height: 16),
              AddEventDialogInputFieldWidget(
                label: "PHONE NUMBER",
                controller: _phoneController,
                hint: "Enter phone number",
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AddEventDialogLabelWidget("EVENT TYPE"),
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
                              items: _eventTypes
                                  .map(
                                    (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                                  .toList(),
                              onChanged: (v) => setState(() => _eventType = v!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AddEventDialogInputFieldWidget(
                      label: "PRICE (৳)",
                      controller: _priceController,
                      hint: "0.00",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const AddEventDialogLabelWidget("START DATE & TIME"),
              DateTimeSelector(
                dateTime: _startDate,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
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
              const AddEventDialogLabelWidget("END DATE & TIME"),
              DateTimeSelector(
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
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                      child: Text(
                        widget.booking == null
                            ? "Create Booking"
                            : "Save Changes",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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