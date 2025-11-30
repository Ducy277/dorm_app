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
  final String? roomCode;

  const BookingRequestScreen({
    super.key,
    this.initialType = BookingRequestType.registration,
    this.roomId,
    this.roomCode,
  });

  @override
  State<BookingRequestScreen> createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomIdController = TextEditingController();
  final _checkInController = TextEditingController();
  final _durationController = TextEditingController();
  final _noteController = TextEditingController();

  BookingRequestType _selectedType = BookingRequestType.registration;
  String _rentalType = 'monthly';
  bool _isSubmitting = false;
  int? _selectedRoomId;
  String? _selectedRoomCode;
  String? _computedExpectedCheckOut;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedRoomId = widget.roomId;
    _selectedRoomCode = widget.roomCode;

    if (_selectedRoomCode != null && _selectedRoomCode!.isNotEmpty) {
      _roomIdController.text = _selectedRoomCode!;
    } else if (_selectedRoomId != null) {
      _roomIdController.text = _selectedRoomId.toString();
    }

    _checkInController.addListener(_updateExpectedCheckout);
    _durationController.addListener(_updateExpectedCheckout);
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    _checkInController.dispose();
    _durationController.dispose();
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
      _updateExpectedCheckout();
    }
  }

  void _updateExpectedCheckout({bool notify = true}) {
    final checkIn = DateTime.tryParse(_checkInController.text.trim());
    final durationRaw = _durationController.text.trim();
    final duration = int.tryParse(durationRaw);
    if (checkIn == null || duration == null || duration <= 0) {
      if (notify) {
        setState(() => _computedExpectedCheckOut = null);
      } else {
        _computedExpectedCheckOut = null;
      }
      return;
    }

    DateTime expected;
    if (_rentalType == 'monthly') {
      final month = checkIn.month + duration;
      final yearAddition = (month - 1) ~/ 12;
      final newMonth = ((month - 1) % 12) + 1;
      final day = checkIn.day;
      expected = DateTime(checkIn.year + yearAddition, newMonth, day);
    } else {
      expected = checkIn.add(Duration(days: duration));
    }

    final formatted =
        '${expected.year.toString().padLeft(4, '0')}-${expected.month.toString().padLeft(2, '0')}-${expected.day.toString().padLeft(2, '0')}';
    if (notify) {
      setState(() => _computedExpectedCheckOut = formatted);
    } else {
      _computedExpectedCheckOut = formatted;
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

    int? roomId = _selectedRoomId ?? int.tryParse(_roomIdController.text.trim());
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

    if (_computedExpectedCheckOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập ngày vào và số ngày/tháng hợp lệ.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    context.read<BookingBloc>().add(
          CreateBookingEvent(
            roomId: roomId,
            bookingType: _selectedType.apiValue,
            checkInDate: _checkInController.text.trim(),
            expectedCheckOutDate: _computedExpectedCheckOut ?? '',
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

        if ((isExtension || isTransfer) &&
            activeBooking != null &&
            _rentalType != activeBooking.rentalType) {
          _rentalType = activeBooking.rentalType;
          _updateExpectedCheckout(notify: false);
        }
        if (isExtension && activeBooking != null) {
          _selectedRoomId = activeBooking.roomId;
          _selectedRoomCode = activeBooking.room?.roomCode;
          _roomIdController.text = _selectedRoomCode ?? activeBooking.roomId.toString();
        }

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
                    _RoomCodeHeader(
                      isReadOnly: _selectedRoomId != null,
                      controller: _roomIdController,
                      isTransfer: isTransfer,
                    ),
                    if (isTransfer && activeBooking != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Phòng hiện tại: ${activeBooking.room?.roomCode ?? activeBooking.roomId}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[700]),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _DropdownSection<BookingRequestType>(
                      label: 'Loại yêu cầu',
                      value: _selectedType,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedType = value);
                      },
                      items: BookingRequestType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    _DropdownSection<String>(
                      label: 'Hình thức thuê',
                      value: _rentalType,
                      onChanged: (value) {
                        if (value == null) return;
                        if ((isExtension || isTransfer) && activeBooking != null) return;
                        setState(() {
                          _rentalType = value;
                          _updateExpectedCheckout();
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: 'monthly', child: Text('Theo tháng')),
                        DropdownMenuItem(value: 'daily', child: Text('Theo ngày')),
                      ],
                      enabled: !(isExtension || isTransfer) || activeBooking == null,
                    ),
                    const SizedBox(height: 12),
                    _DateField(
                      controller: _checkInController,
                      label: 'Ngày vào',
                      onPick: () => _pickDate(_checkInController),
                    ),
                    const SizedBox(height: 12),
                    _DurationField(
                      controller: _durationController,
                      rentalType: _rentalType,
                    ),
                    if (_computedExpectedCheckOut != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ngày trả dự kiến'),
                          Text(
                            _computedExpectedCheckOut ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
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
  final String? roomCode;

  const BookingRequestPayload({
    this.type = BookingRequestType.registration,
    this.roomId,
    this.roomCode,
  });
}

class _RoomCodeHeader extends StatelessWidget {
  final bool isReadOnly;
  final TextEditingController controller;
  final bool isTransfer;

  const _RoomCodeHeader({
    required this.isReadOnly,
    required this.controller,
    this.isTransfer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        color: Colors.blueAccent.withOpacity(0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTransfer ? 'Mã phòng mới' : 'Mã phòng',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: isReadOnly,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: 'Nhập mã phòng (ví dụ: A0103)',
              suffixIcon: isReadOnly ? const Icon(Icons.lock_outline) : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập mã phòng';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _DropdownSection<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  const _DropdownSection({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: items,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}

class _DurationField extends StatelessWidget {
  final TextEditingController controller;
  final String rentalType;

  const _DurationField({
    required this.controller,
    required this.rentalType,
  });

  @override
  Widget build(BuildContext context) {
    final isMonthly = rentalType == 'monthly';
    final label = isMonthly ? 'Số tháng thuê' : 'Số ngày thuê';
    final hint = isMonthly ? 'Ví dụ: 1 (tháng)' : 'Ví dụ: 7 (ngày)';

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final raw = value?.trim() ?? '';
        final number = int.tryParse(raw);
        if (raw.isEmpty) return 'Vui lòng nhập $label';
        if (number == null || number <= 0) return '$label phải lớn hơn 0';
        return null;
      },
    );
  }
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
