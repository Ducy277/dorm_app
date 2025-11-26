import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/booking/booking_bloc.dart';
import '../../bloc/my_room/my_room_bloc.dart';

enum BookingRequestType { registration, extension, transfer }

extension on BookingRequestType {
  String get label {
    switch (this) {
      case BookingRequestType.registration:
        return 'Đăng ký mới';
      case BookingRequestType.extension:
        return 'Gia hạn';
      case BookingRequestType.transfer:
        return 'Đổi phòng';
    }
  }

  String get apiValue {
    switch (this) {
      case BookingRequestType.registration:
        return 'registration';
      case BookingRequestType.extension:
        return 'extension';
      case BookingRequestType.transfer:
        return 'transfer';
    }
  }
}

class BookingRequestScreen extends StatefulWidget {
  final BookingRequestType initialType;
  final int? roomId;

  const BookingRequestScreen({
    super.key,
    this.initialType = BookingRequestType.registration,
    this.roomId,
  });

  @override
  State<BookingRequestScreen> createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomIdController = TextEditingController();
  final _checkInController = TextEditingController();
  final _checkOutController = TextEditingController();
  final _noteController = TextEditingController();

  BookingRequestType _selectedType = BookingRequestType.registration;
  String _rentalType = 'monthly';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    if (widget.roomId != null) {
      _roomIdController.text = widget.roomId.toString();
    }
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    _checkInController.dispose();
    _checkOutController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      final formatted =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      controller.text = formatted;
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final myRoomState = context.read<MyRoomBloc>().state;
    final activeBooking =
        myRoomState is MyRoomLoaded ? myRoomState.activeBooking : null;

    if (_selectedType == BookingRequestType.registration && activeBooking != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn đang có hợp đồng hoạt động.')),
      );
      return;
    }

    if ((_selectedType == BookingRequestType.extension ||
            _selectedType == BookingRequestType.transfer) &&
        activeBooking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa có hợp đồng để thực hiện yêu cầu này.')),
      );
      return;
    }

    if (_selectedType == BookingRequestType.extension ||
        _selectedType == BookingRequestType.transfer) {
      _rentalType = activeBooking?.rentalType ?? _rentalType;
    }

    int? roomId = int.tryParse(_roomIdController.text.trim());
    if (_selectedType == BookingRequestType.extension) {
      roomId = activeBooking?.roomId;
    }
    if (roomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã phòng phải là số hợp lệ')),
      );
      return;
    }

    if (_selectedType == BookingRequestType.transfer && activeBooking != null) {
      if (roomId == activeBooking.roomId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn phòng khác phòng hiện tại.')),
        );
        return;
      }
    }

    if (_selectedType == BookingRequestType.extension && activeBooking != null) {
      final newCheckIn = DateTime.tryParse(_checkInController.text.trim());
      final currentExpected = DateTime.tryParse(activeBooking.expectedCheckOutDate);
      if (newCheckIn != null && currentExpected != null && !newCheckIn.isAfter(currentExpected)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ngày gia hạn phải sau ngày kết thúc hợp đồng hiện tại.')),
        );
        return;
      }
    }

    if (_selectedType == BookingRequestType.registration && _rentalType == 'monthly') {
      final checkIn = DateTime.tryParse(_checkInController.text.trim());
      final checkOut = DateTime.tryParse(_checkOutController.text.trim());
      if (checkIn != null && checkOut != null) {
        final diffMonths = (checkOut.year - checkIn.year) * 12 + (checkOut.month - checkIn.month);
        if (diffMonths < 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thuê theo tháng phải lớn hơn 1 tháng.')),
          );
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);
    context.read<BookingBloc>().add(
          CreateBookingEvent(
            roomId: roomId,
            bookingType: _selectedType.apiValue,
            checkInDate: _checkInController.text.trim(),
            expectedCheckOutDate: _checkOutController.text.trim(),
            rentalType: _rentalType,
            reason: _noteController.text.trim().isNotEmpty
                ? _noteController.text.trim()
                : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (_isSubmitting && state is BookingLoaded) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gửi yêu cầu thành công')),
          );
          Navigator.pop(context, true);
        } else if (_isSubmitting && state is BookingError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = _isSubmitting && state is BookingLoading;
        final myRoomState = context.watch<MyRoomBloc>().state;
        final activeBooking =
            myRoomState is MyRoomLoaded ? myRoomState.activeBooking : null;
        final isExtension = _selectedType == BookingRequestType.extension;
        final isTransfer = _selectedType == BookingRequestType.transfer;

        return Scaffold(
          appBar: AppBar(
            title: Text('Yêu cầu ${_selectedType.label.toLowerCase()}'),
          ),
          body: AbsorbPointer(
            absorbing: isLoading,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text(
                      'Chọn loại yêu cầu',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: BookingRequestType.values.map((type) {
                        final selected = _selectedType == type;
                        return ChoiceChip(
                          label: Text(type.label),
                          selected: selected,
                          onSelected: (_) {
                            setState(() => _selectedType = type);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (isExtension && activeBooking != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phòng hiện tại', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text('Phòng ${activeBooking.room?.roomCode ?? activeBooking.roomId}'),
                        ],
                      )
                    else
                      TextFormField(
                        controller: _roomIdController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: isTransfer ? 'ID phòng mới' : 'ID phòng',
                          hintText: isTransfer ? 'Nhập mã phòng mới (số)' : 'Nhập mã phòng (số)',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập phòng';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 12),
                    _DateField(
                      controller: _checkInController,
                      label: 'Ngày vào',
                      onPick: () => _pickDate(_checkInController),
                    ),
                    const SizedBox(height: 12),
                    _DateField(
                      controller: _checkOutController,
                      label: 'Ngày trả dự kiến',
                      onPick: () => _pickDate(_checkOutController),
                    ),
                    const SizedBox(height: 12),
                    Text('Hình thức thuê', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Theo tháng'),
                          selected: _rentalType == 'monthly',
                          onSelected: _selectedType == BookingRequestType.registration
                              ? (_) => setState(() => _rentalType = 'monthly')
                              : null,
                        ),
                        ChoiceChip(
                          label: const Text('Theo ngày'),
                          selected: _rentalType == 'daily',
                          onSelected: _selectedType == BookingRequestType.registration
                              ? (_) => setState(() => _rentalType = 'daily')
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Lý do (tùy chọn)',
                        hintText: 'Nhập lý do đổi phòng/nội dung thêm',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        isLoading ? 'Đang gửi...' : 'Gửi yêu cầu',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BookingRequestPayload {
  final BookingRequestType type;
  final int? roomId;

  const BookingRequestPayload({
    this.type = BookingRequestType.registration,
    this.roomId,
  });
}

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback onPick;

  const _DateField({
    required this.controller,
    required this.label,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: onPick,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn $label';
        }
        return null;
      },
      onTap: onPick,
    );
  }
}
