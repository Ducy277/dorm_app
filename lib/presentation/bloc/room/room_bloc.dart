import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/room_model.dart';
import '../../../data/repositories/room_repository.dart';
import '../../../data/repositories/review_repository.dart';

part 'room_event.dart';
part 'room_state.dart';

/// Bloc xử lý dữ liệu phòng cho sinh viên.
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository roomRepository;
  final ReviewRepository reviewRepository;
  final List<RoomModel> _allRooms = [];
  final Set<int> _favouritesCache = {};

  RoomFilters _filters = const RoomFilters();
  int _currentPage = 1;
  bool _hasMore = true;

  RoomBloc({
    required this.roomRepository,
    required this.reviewRepository,
    Set<int>? initialFavourites,
  }) : super(RoomInitial()) {
    if (initialFavourites != null) {
      _favouritesCache.addAll(initialFavourites);
    }
    on<FetchRooms>(_onFetchRooms);
    on<LoadMoreRooms>(_onLoadMoreRooms);
    on<UpdateRoomFilters>(_onUpdateRoomFilters);
    on<FetchRoomDetail>(_onFetchRoomDetail);
    on<SubmitReview>(_onSubmitReview);
    on<ToggleFavouriteRoom>(_onToggleFavouriteRoom);
  }

  Future<void> _onFetchRooms(
    FetchRooms event,
    Emitter<RoomState> emit,
  ) async {
    final currentState = state;
    if (currentState is RoomsLoaded && !event.showLoading) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(RoomLoading());
    }

    _currentPage = 1;
    _hasMore = true;
    final result = await roomRepository.getRooms(page: _currentPage);
    result.fold(
      (failure) => emit(RoomError(message: failure.message)),
      (paginated) {
        _allRooms
          ..clear()
          ..addAll(_markFavourites(paginated.data));
        _currentPage = paginated.currentPage;
        _hasMore = paginated.hasMore;
        emit(
          RoomsLoaded(
            rooms: _applyFilters(),
            filters: _filters,
            currentPage: _currentPage,
            hasMore: _hasMore,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreRooms(
    LoadMoreRooms event,
    Emitter<RoomState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RoomsLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));
    final nextPage = currentState.currentPage + 1;

    final result = await roomRepository.getRooms(page: nextPage);
    result.fold(
      (failure) => emit(RoomError(message: failure.message)),
      (paginated) {
        _mergeRooms(paginated.data);
        _currentPage = paginated.currentPage;
        _hasMore = paginated.hasMore;
        emit(
          currentState.copyWith(
            rooms: _applyFilters(),
            currentPage: _currentPage,
            hasMore: _hasMore,
            isLoadingMore: false,
            isRefreshing: false,
          ),
        );
      },
    );
  }

  Future<void> _onUpdateRoomFilters(
    UpdateRoomFilters event,
    Emitter<RoomState> emit,
  ) async {
    _filters = event.filters;
    final currentState = state;
    if (currentState is RoomsLoaded) {
      emit(currentState.copyWith(rooms: _applyFilters(), filters: _filters));
    }
  }

  Future<void> _onFetchRoomDetail(
    FetchRoomDetail event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomLoading());
    final result = await roomRepository.getRoom(event.id);
    result.fold(
      (failure) => emit(RoomError(message: failure.message)),
      (room) {
        final marked = _favouritesCache.contains(room.id)
            ? room.copyWith(isFavourite: true)
            : room;
        emit(RoomLoaded(room: marked));
      },
    );
  }

  Future<void> _onSubmitReview(
    SubmitReview event,
    Emitter<RoomState> emit,
  ) async {
    try {
      await reviewRepository.submitReview(
        roomId: event.roomId,
        rating: event.rating,
        comment: event.comment,
      );

      // Reload room detail
      final result = await roomRepository.getRoom(event.roomId);
      result.fold(
        (failure) => emit(RoomError(message: failure.message)),
        (room) => emit(RoomLoaded(room: room)),
      );
    } catch (e) {
      emit(RoomError(message: e.toString()));
    }
  }

  Future<void> _onToggleFavouriteRoom(
    ToggleFavouriteRoom event,
    Emitter<RoomState> emit,
  ) async {
    final previousState = state;
    RoomModel? target;
    bool? toggledValue;
    if (state is RoomLoaded && (state as RoomLoaded).room.id == event.roomId) {
      target = (state as RoomLoaded).room;
      toggledValue = !target.isFavourite;
      emit(RoomLoaded(room: target.copyWith(isFavourite: toggledValue)));
    }
    if (state is RoomsLoaded) {
      final current = state as RoomsLoaded;
      final updatedRooms = current.rooms
          .map((r) {
            if (r.id == event.roomId) {
              toggledValue = !r.isFavourite;
              return r.copyWith(isFavourite: toggledValue);
            }
            return r;
          })
          .toList();
      emit(current.copyWith(rooms: updatedRooms));
    }
    if (target == null && state is! RoomsLoaded) return;

    if (toggledValue != null) {
      for (var i = 0; i < _allRooms.length; i++) {
        if (_allRooms[i].id == event.roomId) {
          _allRooms[i] = _allRooms[i].copyWith(isFavourite: toggledValue);
        }
      }
    }

    if (toggledValue != null) {
      if (toggledValue == true) {
        _favouritesCache.add(event.roomId);
      } else {
        _favouritesCache.remove(event.roomId);
      }
    }

    try {
      await roomRepository.toggleFavourite(event.roomId);
    } catch (e) {
      emit(previousState);
      // revert cache on failure
      if (toggledValue != null) {
        if (toggledValue == true) {
          _favouritesCache.remove(event.roomId);
        } else {
          _favouritesCache.add(event.roomId);
        }
      }
    }
  }

  List<RoomModel> _applyFilters() {
    Iterable<RoomModel> filtered = _allRooms;
    if (_filters.onlyAvailable) {
      filtered = filtered.where((room) => room.availableSlots > 0);
    }
    if (_filters.minPrice != null) {
      filtered = filtered.where((room) => room.pricePerMonth >= _filters.minPrice!);
    }
    if (_filters.maxPrice != null) {
      filtered =
          filtered.where((room) => room.pricePerMonth <= _filters.maxPrice!);
    }
    if (_filters.branch != null && _filters.branch!.isNotEmpty) {
      final branchLower = _filters.branch!.toLowerCase();
      filtered = filtered.where(
        (room) => (room.branchName ?? '').toLowerCase().contains(branchLower),
      );
    }
    if (_filters.gender != null && _filters.gender!.isNotEmpty) {
      final g = _filters.gender!.toLowerCase();
      filtered = filtered.where((room) {
        final gender = (room.genderType ?? '').toLowerCase();
        return gender == g;
      });
    }
    if (_filters.searchQuery.isNotEmpty) {
      final query = _filters.searchQuery.toLowerCase();
      filtered = filtered.where(
        (room) =>
            room.roomCode.toLowerCase().contains(query) ||
            (room.branchName?.toLowerCase().contains(query) ?? false) ||
            (room.floorName?.toLowerCase().contains(query) ?? false),
      );
    }
    return List<RoomModel>.unmodifiable(filtered.toList());
  }

  void _mergeRooms(List<RoomModel> newRooms) {
    for (final room in _markFavourites(newRooms)) {
      final index = _allRooms.indexWhere((r) => r.id == room.id);
      if (index >= 0) {
        _allRooms[index] = room;
      } else {
        _allRooms.add(room);
      }
    }
  }

  List<RoomModel> _markFavourites(List<RoomModel> rooms) {
    final List<RoomModel> result = [];
    for (final r in rooms) {
      if (r.isFavourite) {
        _favouritesCache.add(r.id);
        result.add(r);
      } else if (_favouritesCache.contains(r.id)) {
        result.add(r.copyWith(isFavourite: true));
      } else {
        result.add(r);
      }
    }
    return result;
  }
}

class RoomFilters extends Equatable {
  final String searchQuery;
  final bool onlyAvailable;
  final double? minPrice;
  final double? maxPrice;
  final String? branch;
  final String? gender;

  const RoomFilters({
    this.searchQuery = '',
    this.onlyAvailable = false,
    this.minPrice,
    this.maxPrice,
    this.branch,
    this.gender,
  });

  RoomFilters copyWith({
    String? searchQuery,
    bool? onlyAvailable,
    double? minPrice,
    double? maxPrice,
    bool clearMaxPrice = false,
    bool clearMinPrice = false,
    String? branch,
    bool clearBranch = false,
    String? gender,
    bool clearGender = false,
  }) {
    return RoomFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      branch: clearBranch ? null : (branch ?? this.branch),
      gender: clearGender ? null : (gender ?? this.gender),
    );
  }

  @override
  List<Object?> get props => [searchQuery, onlyAvailable, minPrice, maxPrice, branch, gender];
}
