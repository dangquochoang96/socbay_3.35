import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import '../../data/repository/auth/api_repository.dart';
import 'customer_information_list_event.dart';
import 'customer_information_list_state.dart';
import 'package:socbay/data/model/user_profile.dart';

class CustomerInformationListBloc
    extends Bloc<CustomerInformationListEvent, CustomerInformationListState> {
  CustomerInformationListBloc(this.apiRepository)
    : super(CustomerInformationListInitialState()) {
    on<CustomerInformationListSearchEvent>(_getSearchEventToState);
  }

  final ApiRepository apiRepository;
  List<UserProfile> users = [];

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

        final List<UserProfile> searchedUsers = userData
            .map((model) => UserProfile.fromJson(model))
            .toList();
        users =
            searchedUsers; // CÃ¡ÂºÂ­p nhÃ¡ÂºÂ­t danh sÃƒÂ¡ch ngÃ†Â°Ã¡Â»Âi dÃƒÂ¹ng
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
