import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/custom_card.dart';
import '../../bloc/booking/booking_bloc.dart';

/// Màn hình danh sách đơn đặt phòng của người dùng.
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<BookingBloc>().add(const FetchBookings());
    return Scaffold(
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const LoadingIndicator();
          } else if (state is BookingsLoaded) {
            final bookings = state.bookings;
            if (bookings.isEmpty) {
              return const Center(child: Text('Bạn chưa có đơn đặt phòng nào'));
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<BookingBloc>().add(const FetchBookings()),
              child: ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đơn #${booking.id}', style: Theme.of(context).textTheme.titleMedium),
                        Text('Phòng: ${booking.room?.roomCode ?? ''}'),
                        Text('Ngày vào ở: ${booking.checkInDate}'),
                        Text('Trạng thái: ${booking.status}'),
                      ],
                    ),
                  );
                },
              ),
            );
          } else if (state is BookingError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}