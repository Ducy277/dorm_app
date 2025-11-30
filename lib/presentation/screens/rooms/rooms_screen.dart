import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/room_model.dart';
import '../../bloc/room/room_bloc.dart';

/// Màn hình duyệt danh sách phòng cho sinh viên.
class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      context.read<RoomBloc>().add(const FetchRooms());
      _hasLoaded = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = 200;
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - threshold) {
      context.read<RoomBloc>().add(const LoadMoreRooms());
    }
  }

  void _onSearchChanged(RoomFilters newFilters) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<RoomBloc>().add(UpdateRoomFilters(newFilters));
    });
  }

  void _toggleAvailable(RoomFilters filters, bool value) {
    context.read<RoomBloc>().add(
      UpdateRoomFilters(filters.copyWith(onlyAvailable: value)),
    );
  }

  void _setMaxPrice(RoomFilters filters, double? price) {
    context.read<RoomBloc>().add(
      UpdateRoomFilters(
        filters.copyWith(maxPrice: price, clearMaxPrice: price == null),
      ),
    );
  }

  void _openFilterSheet(RoomsLoaded state) {
    // Lấy danh sách chi nhánh (id + name) từ rooms hiện có
    final branchMap = <int, String>{};
    for (final room in state.rooms) {
      if (room.branchId != null && room.branchName != null) {
        branchMap[room.branchId!] = room.branchName!;
      }
    }
    final branches = branchMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // cho phép sheet cao hơn, scroll được
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        int? selectedBranch = state.filters.branchId;
        double? selectedPrice = state.filters.maxPrice;
        double? selectedMinPrice = state.filters.minPrice;
        String? selectedGender = state.filters.gender;

        RangeValues range = RangeValues(
          (selectedMinPrice ?? 0) / 1000000,
          (selectedPrice ?? 10000000) / 1000000,
        );

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Bộ lọc',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                selectedBranch = null;
                                selectedPrice = null;
                                selectedMinPrice = null;
                                selectedGender = null;
                                range = const RangeValues(0, 10);
                              });
                            },
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 🔽 Chi nhánh: ĐỔI SANG DROPDOWN
                      Text(
                        'Chi nhánh',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        hint: const Text('Chọn chi nhánh'),
                        value: selectedBranch,
                        items: branches
                            .map(
                              (branch) => DropdownMenuItem<int>(
                                value: branch.key,
                                child: Text(branch.value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedBranch = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Giá
                      Text(
                        'Giá theo tháng (0 - 10tr)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      RangeSlider(
                        min: 0,
                        max: 10,
                        divisions: 20,
                        values: range,
                        labels: RangeLabels(
                          '${range.start.toStringAsFixed(1)}tr',
                          '${range.end.toStringAsFixed(1)}tr',
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            range = val;
                            selectedMinPrice = val.start * 1000000;
                            selectedPrice = val.end * 1000000;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Giới tính
                      Text(
                        'Giới tính phòng',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Tất cả'),
                            selected: selectedGender == null,
                            onSelected: (_) =>
                                setModalState(() => selectedGender = null),
                          ),
                          ChoiceChip(
                            label: const Text('Nam'),
                            selected: selectedGender == 'male',
                            onSelected: (_) =>
                                setModalState(() => selectedGender = 'male'),
                          ),
                          ChoiceChip(
                            label: const Text('Nữ'),
                            selected: selectedGender == 'female',
                            onSelected: (_) =>
                                setModalState(() => selectedGender = 'female'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<RoomBloc>().add(
                              UpdateRoomFilters(
                                state.filters.copyWith(
                                  branchId: selectedBranch,
                                  clearBranch: selectedBranch == null,
                                  minPrice: selectedMinPrice,
                                  clearMinPrice: selectedMinPrice == null,
                                  maxPrice: selectedPrice,
                                  clearMaxPrice: selectedPrice == null,
                                  gender: selectedGender,
                                  clearGender: selectedGender == null,
                                ),
                              ),
                            );
                          },
                          child: const Text('Áp dụng'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách phòng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {
              final state = context.read<RoomBloc>().state;
              if (state is RoomsLoaded) {
                _openFilterSheet(state);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) {
            return const LoadingIndicator();
          } else if (state is RoomsLoaded) {
            return Column(
              children: [
                _FilterBar(
                  controller: _searchController,
                  filters: state.filters,
                  onSearchChanged: _onSearchChanged,
                  onToggleAvailable: _toggleAvailable,
                  onPriceSelected: (price) =>
                      _setMaxPrice(state.filters, price),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<RoomBloc>().add(
                        const FetchRooms(showLoading: false),
                      );
                    },
                    child: state.rooms.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            itemBuilder: (context, index) {
                              final showLoader =
                                  state.isLoadingMore &&
                                  index == state.rooms.length;
                              if (index >= state.rooms.length) {
                                return _ListLoader(isVisible: showLoader);
                              }
                              final room = state.rooms[index];
                              return _RoomCard(room: room);
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemCount:
                                state.rooms.length +
                                (state.hasMore || state.isLoadingMore ? 1 : 0),
                          ),
                  ),
                ),
              ],
            );
          } else if (state is RoomError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<RoomBloc>().add(const FetchRooms()),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final TextEditingController controller;
  final RoomFilters filters;
  final void Function(RoomFilters filters) onSearchChanged;
  final void Function(RoomFilters filters, bool value) onToggleAvailable;
  final void Function(double? price) onPriceSelected;

  const _FilterBar({
    required this.controller,
    required this.filters,
    required this.onSearchChanged,
    required this.onToggleAvailable,
    required this.onPriceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Tìm mã phòng...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              onSearchChanged(filters.copyWith(searchQuery: value));
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomModel room;

  const _RoomCard({required this.room});

  String _statusText() {
    if (room.availableSlots <= 0) return 'Đầy';
    if (room.availableSlots <= 1) return 'Sắp đầy';
    return 'Còn chỗ';
  }

  Color _statusColor() {
    if (room.availableSlots <= 0) return Colors.redAccent;
    if (room.availableSlots <= 1) return const Color(0xFFFF9800);
    return const Color(0xFF2E7D32);
  }

  double _rating() {
    if (room.reviews.isEmpty) return 0;
    final total = room.reviews
        .map((e) => e.rating)
        .fold<int>(0, (a, b) => a + b);
    return total / room.reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (room.branchName != null) room.branchName!,
      if (room.floorName != null) 'Tầng ${room.floorName}',
      if (room.genderType != null) room.genderType!,
    ].where((e) => e.isNotEmpty).join(' • ');

    final amenities = room.amenities.take(4).toList();
    final extraAmenities = room.amenities.length - amenities.length;
    final rating = _rating();

    return GestureDetector(
      onTap: () => context.push('/rooms/${room.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: AppColors.primary.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (room.images.isNotEmpty)
                      Image.network(
                        room.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ImagePlaceholder(),
                      )
                    else
                      _ImagePlaceholder(),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.05),
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          room.roomCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor().withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statusText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (room.branchName != null)
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            room.branchName!,
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Phòng ${room.roomCode}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '${room.pricePerMonth.toStringAsFixed(0)} đ/th',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Chip(
                        label: Text(
                          '${room.currentOccupancy}/${room.capacity} người',
                          style: const TextStyle(fontSize: 12),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        label: Text(
                          room.availableSlots > 0
                              ? '${room.availableSlots} chỗ trống'
                              : 'Đầy',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: _statusColor().withOpacity(0.12),
                        labelStyle: TextStyle(color: _statusColor()),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (amenities.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ...amenities.map(
                          (a) => Chip(
                            label: Text(
                              a.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        if (extraAmenities > 0)
                          Chip(
                            label: Text(
                              '+$extraAmenities',
                              style: const TextStyle(fontSize: 12),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        rating > 0
                            ? rating.toStringAsFixed(1)
                            : 'Chưa có đánh giá',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (rating > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '(${room.reviews.length})',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.heroBlue),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white,
        size: 36,
      ),
    );
  }
}

class _ListLoader extends StatelessWidget {
  final bool isVisible;
  const _ListLoader({required this.isVisible});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox(height: 48);
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.meeting_room_outlined,
              size: 72,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              'Không có phòng phù hợp',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Thử thay đổi bộ lọc hoặc từ khoá tìm kiếm',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final String label;
  final double value;
  final double? selectedValue;
  final void Function(double? value) onSelected;

  const _PriceChip({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedValue == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(selected ? null : value),
    );
  }
}
