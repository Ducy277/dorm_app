import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_button.dart';
import '../../bloc/room/room_bloc.dart';
import '../../../data/models/room_model.dart';

class RoomFormScreen extends StatefulWidget {
  final RoomModel? room; // null = tạo mới
  const RoomFormScreen({super.key, this.room});

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController codeCtrl;
  late TextEditingController priceDayCtrl;
  late TextEditingController priceMonthCtrl;
  late TextEditingController capacityCtrl;
  late TextEditingController descCtrl;
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    codeCtrl = TextEditingController(text: room?.roomCode ?? '');
    priceDayCtrl = TextEditingController(text: room?.pricePerDay.toString() ?? '');
    priceMonthCtrl = TextEditingController(text: room?.pricePerMonth.toString() ?? '');
    capacityCtrl = TextEditingController(text: room?.capacity.toString() ?? '');
    descCtrl = TextEditingController(text: room?.description ?? '');
    isActive = room?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.room != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa phòng' : 'Tạo phòng mới'),
      ),
      body: BlocListener<RoomBloc, RoomState>(
        listener: (context, state) {
          if (state is RoomLoaded && !isEditing) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tạo phòng thành công')),
            );
            Future.microtask(() {
              context.go('/rooms/${state.room.id}/images');
            });
          } else if (state is RoomError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is RoomSuccess && isEditing) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context); // Quay lại danh sách
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Mã phòng'),
                  validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                ),
                TextFormField(
                  controller: priceDayCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Giá theo ngày'),
                ),
                TextFormField(
                  controller: priceMonthCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Giá theo tháng'),
                ),
                TextFormField(
                  controller: capacityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sức chứa'),
                ),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 3,
                ),
                SwitchListTile(
                  title: const Text('Hoạt động'),
                  value: isActive,
                  onChanged: (v) => setState(() => isActive = v),
                ),
                const SizedBox(height: 20),
                BlocBuilder<RoomBloc, RoomState>(
                  builder: (context, state) => CustomButton(
                  label: isEditing ? 'Cập nhật' : 'Tạo mới',
                  isLoading: state is RoomLoading,
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final room = RoomModel(
                        id: isEditing ? widget.room!.id : 0,
                        roomCode: codeCtrl.text,
                        pricePerDay: double.tryParse(priceDayCtrl.text) ?? 0,
                        pricePerMonth: double.tryParse(priceMonthCtrl.text) ?? 0,
                        capacity: int.tryParse(capacityCtrl.text) ?? 1,
                        currentOccupancy: widget.room?.currentOccupancy ?? 0,
                        floorId: widget.room?.floorId ?? 1,
                        isActive: isActive,
                        description: descCtrl.text,
                      );
                      if (isEditing) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đang cập nhật phòng...')),
                        );
                        context.read<RoomBloc>().add(UpdateRoom(room: room));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đang tạo phòng...')),
                        );
                        context.read<RoomBloc>().add(CreateRoom(room: room));
                      }
                    }
                  },
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}