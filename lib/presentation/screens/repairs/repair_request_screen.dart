import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/my_room/my_room_bloc.dart';
import '../../bloc/repair/repair_bloc.dart';

class RepairRequestScreen extends StatefulWidget {
  const RepairRequestScreen({super.key});

  @override
  State<RepairRequestScreen> createState() => _RepairRequestScreenState();
}

class _RepairRequestScreenState extends State<RepairRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final myRoomState = context.read<MyRoomBloc>().state;
    if (myRoomState is! MyRoomLoaded) {
      final authState = context.read<AuthBloc>().state;
      final userId = authState is AuthAuthenticated ? authState.user.id : null;
      context.read<MyRoomBloc>().add(MyRoomRequested(userId: userId));
    }
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để gửi yêu cầu.')),
      );
      Navigator.pop(context);
      return;
    }

    final myRoomState = context.read<MyRoomBloc>().state;
    final activeBooking =
    myRoomState is MyRoomLoaded ? myRoomState.activeBooking : null;

    if (activeBooking?.room == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa có phòng nên không thể gửi yêu cầu sửa chữa.')),
      );
      Navigator.pop(context);
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final roomId = activeBooking!.room!.id;
    context.read<RepairBloc>().add(
      CreateRepairEvent(
        roomId: roomId,
        description: _descriptionCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RepairBloc, RepairState>(
      listener: (context, state) {
        if (state is RepairCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã gửi yêu cầu sửa chữa.')),
          );
          Navigator.pop(context, true);
        } else if (state is RepairError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is RepairLoading;
        final myRoomState = context.watch<MyRoomBloc>().state;
        final activeBooking =
        myRoomState is MyRoomLoaded ? myRoomState.activeBooking : null;

        if (myRoomState is MyRoomLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Gửi yêu cầu sửa chữa')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (myRoomState is MyRoomEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Gửi yêu cầu sửa chữa')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  myRoomState.message ?? 'Bạn chưa có phòng đang ở, vui lòng đăng ký phòng trước.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (activeBooking?.room == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Gửi yêu cầu sửa chữa')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Bạn chưa có phòng đang ở, vui lòng đăng ký phòng trước.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final room = activeBooking!.room!;

        return Scaffold(
          appBar: AppBar(title: const Text('Gửi yêu cầu sửa chữa')),
          body: AbsorbPointer(
            absorbing: isSubmitting,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                                child: const Icon(Icons.meeting_room_outlined, color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Phòng ${room.roomCode}', style: Theme.of(context).textTheme.titleMedium),
                                    if (room.branchName != null)
                                      Text(room.branchName!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    TextFormField(
                      controller: _descriptionCtrl,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả vấn đề',
                        hintText: 'Hãy mô tả chi tiết vấn đề bạn gặp phải...',
                      ),
                      validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Vui lòng mô tả vấn đề' : null,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.attachment_outlined),
                      label: const Text('Đính kèm (tùy chọn)'),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      label: isSubmitting ? 'Đang gửi...' : 'Gửi yêu cầu',
                      onPressed: _submit,
                      icon: Icons.send,
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
