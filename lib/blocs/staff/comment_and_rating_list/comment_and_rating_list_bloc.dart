import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/staff/comment_and_rating_list/comment_and_rating_list_event.dart';
import 'package:socbay/blocs/staff/comment_and_rating_list/comment_and_rating_list_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import 'package:socbay/utils/logger_util.dart';

class CommentAndRatingBloc
    extends Bloc<CommentAndRatingEvent, CommentAndRatingState> {
  CommentAndRatingBloc({required this.apiRepository})
    : super(CommentAndRatingInitState()) {
    on<CommentAndRatingListEvent>(_mapGetListCommentAndRatingEventToState);
  }
  final ApiRepository apiRepository;
  UserProfile? userProfile;
  double rating = 0;
  int dem = 0;
  bool isLoading = true;
  List<OrderDetailModel>? lstOrder;
  FutureOr<void> _mapGetListCommentAndRatingEventToState(
    CommentAndRatingListEvent event,
    Emitter<CommentAndRatingState> emit,
  ) async {
    isLoading = true;
    await _getProfile();
    await _getRating();
    isLoading = false;
    emit(CommentAndRatingInitState());
  }

  Future<void> _getProfile() async {
    var url = AppConfig.instance.apiUri(
      ApiEndpoints.userById(App.instance.userApp!.id),
    );
    try {
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var map = Map<String, dynamic>.from(json.decode(res.body));
        userProfile = UserProfile.fromJson(map["data"]);
      }
    } catch (ex) {
      LoggerUtil.log(ex.toString());
    }
  }

  Future<void> _getRating() async {
    int diem = 0;
    var url = AppConfig.instance.apiUri(ApiEndpoints.listOrderRatingByStaff, {
      'user_id': App.instance.userApp?.id.toString(),
    });
    try {
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var map = Map<String, dynamic>.from(json.decode(res.body));
        lstOrder = List<OrderDetailModel>.from(
          map["data"].map((model) => OrderDetailModel.fromJson(model)),
        );
        dem = 0;
        lstOrder?.forEach((element) {
          // if(element.rate != null){
          //   diem = diem + int.parse(element.rate!);
          //   dem =dem+1;
          // }
          diem = diem + int.parse(element.rate!);
          dem = dem + 1;
        });
        if (dem > 0) {
          rating = diem / dem;
        } else {
          rating = 0;
        }
      }
    } catch (ex) {
      LoggerUtil.log(ex.toString());
    }
  }
}
