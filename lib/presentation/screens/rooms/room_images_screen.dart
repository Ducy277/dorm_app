import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/room/room_bloc.dart';
import '../../../core/widgets/custom_button.dart';

class RoomImagesScreen extends StatefulWidget {
  final int roomId;
  const RoomImagesScreen({super.key, required this.roomId});

  @override
  State<RoomImagesScreen> createState() => _RoomImagesScreenState();
}

class _RoomImagesScreenState extends State<RoomImagesScreen> {
  final picker = ImagePicker();
  List<File> selected = [];

  Future<void> _pickImages() async {
    final files = await picker.pickMultiImage();
    setState(() {
      selected = files.map((x) => File(x.path)).toList();
    });
    }

  void _upload() {
    if (selected.isNotEmpty) {
      context.read<RoomBloc>().add(UploadRoomImages(id: widget.roomId, files: selected));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ảnh phòng')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              children: selected
                  .map((file) => Image.file(file, width: 100, height: 100, fit: BoxFit.cover))
                  .toList(),
            ),
            const SizedBox(height: 16),
            CustomButton(label: 'Chọn ảnh', onPressed: _pickImages),
            const SizedBox(height: 8),
            CustomButton(label: 'Tải lên', onPressed: _upload),
          ],
        ),
      ),
    );
  }
}
