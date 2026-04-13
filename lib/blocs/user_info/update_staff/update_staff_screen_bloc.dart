import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repository/auth/api_repository.dart';
import '../../../data/response/api_response.dart';
import '../../user_info/update_staff/update_staff_screen_event.dart';
import '../../user_info/update_staff/update_staff_screen_state.dart';

class UpdateStaffScreenBloc extends Bloc<UpdateStaffEvent, UpdateStaffState> {
  UpdateStaffScreenBloc({required this.apiRepository})
      : super(UpdateStaffScreenInitialState()) {
    on<UpdateStaffScreenEvent>(_mapUpdateStaffEventToState);
  }

  final ApiRepository apiRepository;
  bool isLoading = false;

  Future _mapUpdateStaffEventToState(
      UpdateStaffScreenEvent event, Emitter<UpdateStaffState> emit) async {
    isLoading = true;
    emit(UpdateStaffScreenInitialState());
    final DefaultResponse res =
        await apiRepository.updateStaff(event.updateStaffRequestModel);
    if (res.status == 200) {
      emit(UpdateStaffScreenSuccessState());
    }
    isLoading = false;
    emit(UpdateStaffScreenInitialState());
  }
}
