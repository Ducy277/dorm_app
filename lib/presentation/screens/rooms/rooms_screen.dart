import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/room_model.dart';
import '../../bloc/room/room_bloc.dart';

/// Màn hình danh sách phòng.
class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      context.read<RoomBloc>().add(const FetchRooms());
      _hasLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: thay bằng role thực tế từ user (vd: context.read<AuthBloc>().state.user.role)
    final String currentRole = 'admin'; // tạm hardcode để test

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách phòng')),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) {
            return const LoadingIndicator();
          } else if (state is RoomsLoaded) {
            final rooms = state.rooms;

            if (rooms.isEmpty) {
              return const Center(child: Text('Chưa có phòng nào'));
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<RoomBloc>().add(const FetchRooms()),
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return CustomCard(
                    onTap: () => context.go('/rooms/${room.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Phòng ${room.roomCode}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (currentRole == 'admin' || currentRole == 'staff')
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    context.push('/rooms/edit/${room.id}',
                                        extra: room);
                                  } else if (value == 'delete') {
                                    _confirmDelete(context, room);
                                  } else if (value == 'images') {
                                    context.push('/rooms/${room.id}/images');
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Chỉnh sửa'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'images',
                                    child: Text('Ảnh phòng'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Xóa'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Giá/ngày: ${room.pricePerDay}'),
                        Text('Giá/tháng: ${room.pricePerMonth}'),
                        Text('Sức chứa: ${room.capacity}'),
                        Text('Đang ở: ${room.currentOccupancy}'),
                      ],
                    ),
                  );
                },
              ),
            );
          } else if (state is RoomError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: (currentRole == 'admin' || currentRole == 'staff')
          ? FloatingActionButton(
        onPressed: () => context.push('/rooms/create'),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  void _confirmDelete(BuildContext context, RoomModel room) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có chắc muốn xóa phòng ${room.roomCode}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<RoomBloc>().add(DeleteRoom(id: room.id));
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
