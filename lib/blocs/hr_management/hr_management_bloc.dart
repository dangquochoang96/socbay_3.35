import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/hr_management/hr_management_event.dart';
import 'package:socbay/blocs/hr_management/hr_management_state.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/data/response/api_response.dart';

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
      final results = await Future.wait([
        apiRepository.getKPIs(event.userId),
        apiRepository.getUserInfo(),
      ]);

      final kpiResponse = results[0] as DefaultResponse<UserProfile>;
      final userResponse = results[1] as DefaultResponse<UserModel>;

      if (kpiResponse.status == 200 || kpiResponse.status == 1) {
        if (kpiResponse.data != null) {
          emit(
            HRManagementLoaded(
              userProfile: kpiResponse.data!,
              userInfoProfile: userResponse.status == 200
                  ? userResponse.data?.userProfile
                  : null,
            ),
          );
        } else {
          emit(
            const HRManagementError(message: "Không tìm thấy dữ liệu nhân sự"),
          );
        }
      } else {
        emit(
          HRManagementError(message: kpiResponse.message ?? "Lỗi tải dữ liệu"),
        );
      }
    } catch (e) {
      emit(HRManagementError(message: e.toString()));
    }
  }
}
