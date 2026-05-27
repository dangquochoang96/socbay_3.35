import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';

import '../../../data/model/user_profile.dart';
import '../../../data/repository/auth/api_repository.dart';
import 'choose_favourite_staff_event.dart';
import 'choose_favourite_staff_state.dart';
import 'package:socbay/utils/auth_http.dart' as http;

class ChooseFavouriteStaffBloc
    extends Bloc<ChooseFavouriteStaffEvent, ChooseFavouriteStaffState> {
  ChooseFavouriteStaffBloc({required this.apiRepository, required this.args})
    : super(ChooseFavouriteStaffInitialState()) {
    on<ChooseFavouriteStaffStartedEvent>(_mapStartedEventToState);
  }

  final ApiRepository apiRepository;
  Map<String, dynamic> args;
  List<UserProfile> favouriteStaffs = [];
  bool isLoading = false;

  FutureOr<void> _mapStartedEventToState(
    ChooseFavouriteStaffStartedEvent event,
    Emitter<ChooseFavouriteStaffState> emit,
  ) async {
    isLoading = true;
    emit(ChooseFavouriteStaffInitialState());
    var url = AppConfig.instance.apiUri(ApiEndpoints.userFavorites, {
      'user_id': App.instance.userApp?.id.toString(),
    });
    var res = await http.get(url);
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res.body));
      favouriteStaffs = List<UserProfile>.from(
        l["data"].map((model) => UserProfile.fromJson(model)),
      );
    }
    // final res = await apiRepository.getStaffs(isLike: 1);
    // if (res.data != null && res.status == HttpStatus.ok) {
    //   favouriteStaffs = res.data!;
    // }
    isLoading = false;
    emit(ChooseFavouriteStaffInitialState());
  }
}
