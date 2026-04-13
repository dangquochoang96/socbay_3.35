import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/user_info/user_address/user_address_screen_event.dart';
import 'package:socbay/blocs/user_info/user_address/user_address_screen_state.dart';
import 'package:socbay/data/model/request/user_address_request.dart';
import 'package:socbay/data/model/user_address.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';

class UserAddressScreenBloc
    extends Bloc<UserAddressScreenEvent, UserAddressScreenState> {
  UserAddressScreenBloc({required this.apiRepository})
      : super(UserAddressScreenInitialState()) {
    on<UserAddressScreenGetAddressEvent>(_mapGetAddressToState);
    on<UserAddressScreenCreateUserAddressEvent>(_mapCreateUserAddressToState);
    on<UserAddressScreenSetDefaultEvent>(_mapSetDefaultAddressToState);
    on<UserAddressScreenDeleteAddressEvent>(_mapDeleteAddressToState);
    on<UserAddressScreenUpdateAddressEvent>(_mapUpdateAddressToState);
  }

  final ApiRepository apiRepository;
  bool isLoading = false;
  bool isChange = false;
  List<UserAddress> listUserAddress = [];
  UserProfile? user = App.instance.userApp;

  FutureOr<void> _mapGetAddressToState(UserAddressScreenGetAddressEvent event,
      Emitter<UserAddressScreenState> emit) async {
    isLoading = true;
    emit(UserAddressScreenInitialState());
    final res = await apiRepository.getListUserAddress();
    isLoading = false;
    if (res.status == HttpStatus.ok && res.data != null) {
      listUserAddress = (res.data!);
    } else {}
    emit(UserAddressScreenInitialState());
  }

  FutureOr<void> _mapCreateUserAddressToState(
      UserAddressScreenCreateUserAddressEvent event,
      Emitter<UserAddressScreenState> emit) async {
    isLoading = true;
    emit(UserAddressScreenInitialState());
    final res = await apiRepository.createUserAddress(event.userAddressRequest);
    isLoading = false;
    if (res.status == HttpStatus.ok && res.data != null) {
      add(UserAddressScreenGetAddressEvent());
      emit(const UserAddressScreenCreateAddressSuccessState());
    } else {
      emit(
        UserAddressScreenCreateAddressSuccessState(
          error: res.message.toString(),
        ),
      );
    }
  }

  FutureOr<void> _mapSetDefaultAddressToState(
      UserAddressScreenSetDefaultEvent event,
      Emitter<UserAddressScreenState> emit) async {
    isLoading = true;
    emit(UserAddressScreenInitialState());
    final res = await apiRepository.updateUserAddress(
      UserAddressRequest(
          name: event.userAddress.name ?? "",
          phone: event.userAddress.phone ?? "",
          address: event.userAddress.address ?? "",
          lat: event.userAddress.lat ?? 0,
          lng: event.userAddress.lng ?? 0,
          isDefault: 1,
          stateCode: event.userAddress.stateCode,
          cityCode: "AGG",
          id: event.userAddress.id),
    );
    isLoading = false;
    if (res.status == HttpStatus.ok && res.data != null) {
      // add(UserAddressScreenGetAddressEvent());
      isChange = true;
      emit(UserAddressScreenInitialState());
    } else {
      emit(
        UserAddressScreenCreateAddressSuccessState(
          error: res.message.toString(),
        ),
      );
    }
  }

  FutureOr<void> _mapDeleteAddressToState(
      UserAddressScreenDeleteAddressEvent event,
      Emitter<UserAddressScreenState> emit) async {
    isLoading = true;
    emit(UserAddressScreenInitialState());
    final res =
        await apiRepository.deleteUserAddress(event.userAddress.id ?? "");
    isLoading = false;
    if (res.status == HttpStatus.ok && res.data != null) {
      add(UserAddressScreenGetAddressEvent());
    } else {
      emit(
        UserAddressScreenCreateAddressSuccessState(
          error: res.message.toString(),
        ),
      );
    }
  }

  FutureOr<void> _mapUpdateAddressToState(
      UserAddressScreenUpdateAddressEvent event,
      Emitter<UserAddressScreenState> emit) async {
    isLoading = true;
    emit(UserAddressScreenInitialState());
    final res = await apiRepository.updateUserAddress(event.userAddressRequest);
    isLoading = false;
    if (res.status == HttpStatus.ok && res.data != null) {
      add(UserAddressScreenGetAddressEvent());
      emit(const UserAddressScreenUpdateAddressSuccessState());
    } else {
      emit(
        UserAddressScreenUpdateAddressSuccessState(
          error: res.message.toString(),
        ),
      );
    }
  }
}
