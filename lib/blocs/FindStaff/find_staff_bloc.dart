import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/FindStaff/find_staff_state.dart';
import 'package:socbay/data/model/user_address.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/data/response/api_response.dart';

import 'find_staff_event.dart';

class FindStaffBloc extends Bloc<FindStaffEvent, FindStaffState> {
  final ApiRepository apiRepository;
  List<UserAddress> listUserAddress = [];
  List<UserProfile> staffsInfo = [];
  bool isLoading = false;
  FindStaffBloc({required this.apiRepository}) : super(FindStaffStartState()) {
    on<FindStaffGetUserAddressEvent>(_mapGetListUserAddressEventToState);
    on<FindStaffScreenGetStaffEvent>(_mapStartedEventToState);
  }
  FutureOr<void> _mapGetListUserAddressEventToState(
    FindStaffGetUserAddressEvent event,
    Emitter<FindStaffState> emit,
  ) async {
    isLoading = true;
    //emit(FindStaffStartState());
    final DefaultResponse result = await apiRepository.getListUserAddress();
    if (result.status == 200 && result.data != null) {
      listUserAddress = result.data;
      //emit(FindStartGetUserAddressSuccessState());
    }
    isLoading = false;
    emit(FindStaffStartState());
  }

  FutureOr<void> _mapStartedEventToState(
    FindStaffScreenGetStaffEvent event,
    Emitter<FindStaffState> emit,
  ) async {
    isLoading = true;
    emit(FindStaffStartState());

    final res = await apiRepository.getListStaffByDistance(
      event.staffByDistanceRequest,
    );
    if (res.data != null && res.status == HttpStatus.ok) {
      staffsInfo = res.data!;
      //add(SearchStaffScreenGetTaskEvent());
    }
    isLoading = false;
    emit(FindStaffStartState());
  }
}
