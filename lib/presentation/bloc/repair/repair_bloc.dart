import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/exceptions.dart';
import '../../../data/models/repair_model.dart';
import '../../../data/repositories/repair_repository.dart';

part 'repair_event.dart';
part 'repair_state.dart';

/// Bloc xử lý yêu cầu sửa chữa.
class RepairBloc extends Bloc<RepairEvent, RepairState> {
  final RepairRepository repairRepository;

  RepairBloc({required this.repairRepository}) : super(RepairInitial()) {
    on<FetchRepairs>(_onFetchRepairs);
    on<CreateRepairEvent>(_onCreateRepair);
  }

  Future<void> _onFetchRepairs(FetchRepairs event, Emitter<RepairState> emit) async {
    emit(RepairLoading());
    try {
      final repairs = await repairRepository.getRepairs(page: event.page);
      emit(RepairsLoaded(repairs: repairs));
    } on AppException catch (e) {
      emit(RepairError(message: e.message));
    }
  }

  Future<void> _onCreateRepair(CreateRepairEvent event, Emitter<RepairState> emit) async {
    emit(RepairLoading());
    try {
      await repairRepository.createRepair(roomId: event.roomId, description: event.description);
      emit(RepairCreated());
    } on AppException catch (e) {
      emit(RepairError(message: e.message));
    }
  }
}
