import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../bloc/room/room_bloc.dart';

/// Màn hình chi tiết phòng.
class RoomDetailScreen extends StatefulWidget {
  final int? roomId;
  const RoomDetailScreen({super.key, required this.roomId});


  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded && widget.roomId != null) {
      context.read<RoomBloc>().add(FetchRoomDetail(id: widget.roomId!));
      _hasLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<RoomBloc>().add(const FetchRooms());
        return true;
      },
      child: Scaffold(
      appBar: AppBar(title: const Text('Chi tiết phòng')),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) {
            return const LoadingIndicator();
          } else if (state is RoomLoaded) {
            final room = state.room;
            final services = room.services;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mã phòng: ${room.roomCode}', style: Theme.of(context).textTheme.titleLarge),
                    Text('Giá/ngày: ${room.pricePerDay}'),
                    Text('Giá/tháng: ${room.pricePerMonth}'),
                    Text('Sức chứa: ${room.capacity}'),
                    Text('Đang sử dụng: ${room.currentOccupancy}'),
                    const SizedBox(height: 12),
                    Text('Mô tả: ${room.description ?? 'Không có'}'),
                    const SizedBox(height: 12),
                    if (services != null && services.isNotEmpty) ...[
                      const Text('Dịch vụ:', style: TextStyle(fontWeight: FontWeight.bold)),
                      for (final s in services) Text('• ${s.name} (${s.unitPrice}/${s.unit})'),
                    ],
                  ],
                ),
              ),
            );
          } else if (state is RoomError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    ),
    );
  }
}