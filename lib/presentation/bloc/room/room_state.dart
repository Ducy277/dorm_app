part of 'room_bloc.dart';

/// Các trạng thái cho RoomBloc.
abstract class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class RoomsLoaded extends RoomState {
  final List<RoomModel> rooms;
  final RoomFilters filters;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  const RoomsLoaded({
    required this.rooms,
    required this.filters,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  RoomsLoaded copyWith({
    List<RoomModel>? rooms,
    RoomFilters? filters,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return RoomsLoaded(
      rooms: rooms ?? this.rooms,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        rooms,
        filters,
        currentPage,
        hasMore,
        isLoadingMore,
        isRefreshing,
      ];
}

class RoomLoaded extends RoomState {
  final RoomModel room;
  const RoomLoaded({required this.room});

  @override
  List<Object?> get props => [room];
}

class RoomSuccess extends RoomState {
  final String message;
  const RoomSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class RoomError extends RoomState {
  final String message;
  const RoomError({required this.message});

  @override
  List<Object?> get props => [message];
}

