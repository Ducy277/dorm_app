part of 'repair_bloc.dart';

abstract class RepairState extends Equatable {
  const RepairState();

  @override
  List<Object> get props => [];
}

class RepairInitial extends RepairState {}

class RepairLoading extends RepairState {}

class RepairsLoaded extends RepairState {
  final List<RepairModel> repairs;

  const RepairsLoaded({required this.repairs});

  @override
  List<Object> get props => [repairs];
}

class RepairCreated extends RepairState {}

class RepairError extends RepairState {
  final String message;

  const RepairError({required this.message});

  @override
  List<Object> get props => [message];
}
