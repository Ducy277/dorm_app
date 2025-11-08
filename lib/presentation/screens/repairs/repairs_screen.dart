import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../bloc/repair/repair_bloc.dart';

/// Màn hình yêu cầu sửa chữa.
class RepairsScreen extends StatelessWidget {
  const RepairsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<RepairBloc>().add(const FetchRepairs());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu cầu sửa chữa'),
      ),
      body: BlocBuilder<RepairBloc, RepairState>(
        builder: (context, state) {
          if (state is RepairLoading) {
            return const LoadingIndicator();
          } else if (state is RepairsLoaded) {
            final repairs = state.repairs;
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<RepairBloc>().add(const FetchRepairs()),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomButton(
                      label: 'Gửi yêu cầu sửa chữa mới',
                      onPressed: () {
                        // TODO: mở form gửi yêu cầu
                      },
                    ),
                  ),
                  ...repairs.map((repair) => CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã yêu cầu: ${repair.id}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text('Phòng: ${repair.room?.roomCode ?? ''}'),
                        Text('Trạng thái: ${repair.status}'),
                        Text('Mô tả: ${repair.description}'),
                      ],
                    ),
                  )),
                ],
              ),
            );
          } else if (state is RepairError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
