import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/user_info/favourite_staff/favourite_staff_event.dart';
import 'package:socbay/blocs/user_info/favourite_staff/favourite_staff_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/auth_http.dart' as http;

class FavouriteStaffBloc
    extends Bloc<FavouriteStaffEvent, FavouriteStaffState> {
  FavouriteStaffBloc({required this.apiRepository})
    : super(FavouriteStaffInitialState()) {
    on<FavouriteStaffStartedEvent>(_mapStartedEventToState);
  }

  final ApiRepository apiRepository;
  List<UserModel> favouriteStaffs = [];
  bool isLoading = false;

  FutureOr<void> _mapStartedEventToState(
    FavouriteStaffStartedEvent event,
    Emitter<FavouriteStaffState> emit,
  ) async {
    isLoading = true;
    emit(FavouriteStaffInitialState());
    var url = AppConfig.instance.apiUri(ApiEndpoints.userFavorites, {
      'user_id': App.instance.userApp?.id.toString(),
    });
    var res = await http.get(url);
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res.body));
      favouriteStaffs = List<UserModel>.from(
        l["data"].map((model) => UserModel.fromJson(model)),
      );
    }
    // final res = await apiRepository.getStaffs(isLike: 1);
    // if (res.data != null && res.status == HttpStatus.ok) {
    //   favouriteStaffs = res.data!;
    // }
    isLoading = false;
    emit(FavouriteStaffInitialState());
  }
}
