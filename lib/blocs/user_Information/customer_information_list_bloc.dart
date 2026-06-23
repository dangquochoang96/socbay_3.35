import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import '../../config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import '../../data/repository/auth/api_repository.dart';
import 'customer_information_list_event.dart';
import 'customer_information_list_state.dart';
import 'package:socbay/data/model/user_model.dart';

class CustomerInformationListBloc
    extends Bloc<CustomerInformationListEvent, CustomerInformationListState> {
  CustomerInformationListBloc(this.apiRepository)
    : super(CustomerInformationListInitialState()) {
    on<CustomerInformationListStartEvent>(_getStartEventToState);
    on<CustomerInformationListSearchEvent>(_getSearchEventToState);
  }

  Future<void> _getStartEventToState(
    CustomerInformationListStartEvent event,
    Emitter<CustomerInformationListState> emit,
  ) async {
    await _getSearchEventToState(CustomerInformationListSearchEvent(), emit);
  }

  final ApiRepository apiRepository;
  List<UserModel> users = [];

  bool isLoading = false;

  Future<void> _getSearchEventToState(
    CustomerInformationListSearchEvent event,
    Emitter<CustomerInformationListState> emit,
  ) async {
    isLoading = true;
    emit(CustomerInformationListInitialState());

    try {
      final name = event.name ?? "";
      final phone = event.phone ?? "";
      final address = event.address ?? "";
      var url = AppConfig.instance.apiUri(ApiEndpoints.userSearchList, {
        'name': name,
        'search': phone,
        'address ': address,
      });

      final response = await http.get(url);

      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> userData = data["data"];

        final List<UserModel> searchedUsers = userData
            .map((model) => UserModel.fromJson(model))
            .toList();
        users = searchedUsers;
        emit(CustomerInformationListLoadedState(users));
      } else {
        emit(
          const CustomerInformationListErrorState("Failed to fetch user data"),
        );
      }
    } catch (error) {
      emit(CustomerInformationListErrorState("An error occurred: $error"));
    } finally {
      isLoading = false;
    }
  }
}
