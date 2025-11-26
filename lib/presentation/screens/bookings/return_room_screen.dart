import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/custom_card.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/booking/booking_bloc.dart';
import '../../bloc/my_room/my_room_bloc.dart';

class ReturnRoomScreen extends StatefulWidget {
  const ReturnRoomScreen({super.key});

  @override
  State<ReturnRoomScreen> createState() => _ReturnRoomScreenState();
}

class _ReturnRoomScreenState extends State<ReturnRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  bool _requestedMyRoom = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final myRoomState = context.read<MyRoomBloc>().state;
    if (!_requestedMyRoom && myRoomState is! MyRoomLoaded) {
      final auth = context.read<AuthBloc>().state;
      final userId = auth is AuthAuthenticated ? auth.user.id : null;
      context.read<MyRoomBloc>().add(MyRoomRequested(userId: userId));
      _requestedMyRoom = true;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập.')),
      );
      Navigator.pop(context);
      return;
    }
    final myRoomState = context.read<MyRoomBloc>().state;
    final activeBooking =
    myRoomState is MyRoomLoaded ? myRoomState.activeBooking : null;
    if (activeBooking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy hợp đồng đang hoạt động.')),
      );
      Navigator.pop(context);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<BookingBloc>().add(
      RequestReturnBookingEvent(
        reason: _reasonController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myRoomState = context.watch<MyRoomBloc>().state;
    final activeBooking =
    myRoomState is MyRoomLoaded ? myRoomState.activeBooking : null;
    final room = activeBooking?.room;

    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã gửi yêu cầu trả phòng.')),
          );
          Navigator.pop(context, true);
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is BookingLoading;
        if (activeBooking == null || room == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trả phòng')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Text(
                  myRoomState is MyRoomEmpty
                      ? 'Bạn chưa có phòng.'
                      : 'Không tìm thấy hợp đồng đang hoạt động.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Trả phòng')),
          body: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: AbsorbPointer(
              absorbing: isLoading,
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phòng hiện tại', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('Phòng ${room.roomCode}'),
                          if (room.branchName != null)
                            Text(room.branchName!, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Lý do trả phòng',
                        hintText: 'Nhập lý do của bạn',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập lý do';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: isLoading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.send),
                      label: Text(isLoading ? 'Đang gửi...' : 'Gửi yêu cầu'),
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
