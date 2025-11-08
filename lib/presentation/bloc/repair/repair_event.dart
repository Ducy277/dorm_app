part of 'repair_bloc.dart';

/// Các sự kiện của RepairBloc.
abstract class RepairEvent extends Equatable {
  const RepairEvent();
  @override
  List<Object?> get props => [];
}

class FetchRepairs extends RepairEvent {
  final int? page;
  const FetchRepairs({this.page});
  @override
  List<Object?> get props => [page];
}

class CreateRepairEvent extends RepairEvent {
  final int roomId;
  final String description;
  const CreateRepairEvent({required this.roomId, required this.description});
  @override
  List<Object?> get props => [roomId, description];
}