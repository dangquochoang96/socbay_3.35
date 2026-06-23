import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/hr_management/hr_management_event.dart';
import 'package:socbay/blocs/hr_management/hr_management_state.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';

class HRManagementBloc extends Bloc<HRManagementEvent, HRManagementState> {
  final ApiRepository apiRepository;

  HRManagementBloc({required this.apiRepository})
    : super(HRManagementInitial()) {
    on<FetchHRManagementData>(_onFetchHRManagementData);
  }

  Future<void> _onFetchHRManagementData(
    FetchHRManagementData event,
    Emitter<HRManagementState> emit,
  ) async {
    emit(HRManagementLoading());
    try {
      final response = await apiRepository.getKPIs(event.userId);
      if (response.status == 200 || response.status == 1) {
        if (response.data != null) {
          emit(HRManagementLoaded(userProfile: response.data!));
        } else {
          emit(
            const HRManagementError(message: "Không tìm thấy dữ liệu nhân sự"),
          );
        }
      } else {
        emit(HRManagementError(message: response.message ?? "Lỗi tải dữ liệu"));
      }
    } catch (e) {
      emit(HRManagementError(message: e.toString()));
    }
  }
}
