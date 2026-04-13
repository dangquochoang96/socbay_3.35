import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/home/staff_info/staff_info_screen_event.dart';
import 'package:socbay/blocs/home/staff_info/staff_info_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/utils/logger_util.dart';

import '../../../data/model/order_detail_model.dart';
import '../../../data/model/user_profile.dart';
import '../../../data/repository/auth/api_repository.dart';
import 'package:http/http.dart' as http;

class StaffInfoScreenBloc
    extends Bloc<StaffInfoScreenEvent, StaffInfoScreenState> {
  StaffInfoScreenBloc({required this.apiRepository, required this.args})
      : super(StaffInfoScreenInitialState()) {
    on<StaffInfoScreenListEvent>(_mapGetListCommentAndRatingEventToState);
    on<StaffInfoScreenStartedEvent>(_mapStaffInfoStartedEventToState);
    on<StaffInfoScreenLikeStaffEvent>(_mapLikeStaffEventToState);
    on<StaffInfoScreenUnLikeStaffEvent>(_mapUnLikeStaffEventToState);
  }

  final ApiRepository apiRepository;
  bool isLoading = false;
  Map<String, dynamic> args;
  List<UserProfile> favouriteStaffs = [];
  bool isFavourite = false;
  String localte = "";
  List<String> services = [];

  UserProfile? userProfile;
  double rating = 0;
  int dem = 0;
  List<OrderDetailModel>? lstOrder;

  FutureOr<void> _mapStaffInfoStartedEventToState(
      StaffInfoScreenStartedEvent event,
      Emitter<StaffInfoScreenState> emit) async {
    try{
      isLoading = true;
      emit(StaffInfoScreenInitialState());
      var url = Uri.http(AppConfig.instance.values.apiUrl,"/api/user/listFavorite",{
        'user_id':App.instance.userApp?.id.toString()
      });
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String,dynamic>.from(json.decode(res.body));
        favouriteStaffs = List<UserProfile>.from(l["data"].map((model)=> UserProfile.fromJson(model)));
        for(var i in favouriteStaffs){
          if(i.id == (args["staffInfo"] as UserProfile).id){
            isFavourite = true;
          }
        }
      }
      var url1 = Uri.http(AppConfig.instance.values.apiUrl,"/api/user/staff-detail/${(args["staffInfo"] as UserProfile).id}");
      var res1 = await http.get(url1);
      if (res1.statusCode == HttpStatus.ok) {
        var l = Map<String,dynamic>.from(json.decode(res1.body));
        var m = l["data"][0];
        localte = m["locate"]??"";
        services = m["services"]!=null?m["services"].split(","):[];
      }
      isLoading = false;
      emit(StaffInfoScreenInitialState());
    }catch(ex){
      LoggerUtil.error(jsonEncode(ex));
    }
    add(const StaffInfoScreenListEvent());
  }

  FutureOr<void> _mapLikeStaffEventToState(StaffInfoScreenLikeStaffEvent event,
      Emitter<StaffInfoScreenState> emit) async {
    isLoading = true;
    emit(StaffInfoScreenInitialState());
    var url = Uri.http(AppConfig.instance.values.apiUrl,"/api/user/addFavorite",{
      'user_id':App.instance.userApp?.id.toString(),
      'staff_id': event.id.toString()
    });
    var res = await http.post(url);
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String,dynamic>.from(json.decode(res.body));
      if(l["code"]  == 1){
        isFavourite = true;
      }
    }
    isLoading = false;
    emit(StaffInfoScreenInitialState());
  }

  FutureOr<void> _mapUnLikeStaffEventToState(StaffInfoScreenUnLikeStaffEvent event,
      Emitter<StaffInfoScreenState> emit) async {
    isLoading = true;
    emit(StaffInfoScreenInitialState());
    var url = Uri.http(AppConfig.instance.values.apiUrl,"/api/user/unFavorite",{
      'user_id':App.instance.userApp?.id.toString(),
      'staff_id': event.id.toString()
    });
    var res = await http.post(url);
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String,dynamic>.from(json.decode(res.body));
      if(l["code"]  == 1){
        isFavourite = false;
      }
    }
    // final res = await apiRepository.unlikeStaff(event.id);
    // if (res.data != null && res.status == 200) {
    //   isFavourite = false;
    // }
    isLoading = false;
    emit(StaffInfoScreenInitialState());
  }

  FutureOr<void> _mapGetListCommentAndRatingEventToState(
      StaffInfoScreenListEvent event,
      Emitter<StaffInfoScreenState> emit) async {
    isLoading = true;
    await _getProfile();
    await _getRating();
    isLoading = false;
    emit(StaffInfoScreenInitialState());

  }
  Future<void> _getProfile() async {
    var url = Uri.http(AppConfig.instance.values.apiUrl,"/api/user/${(args["id"])}");
    try{
      var res = await http.get(url);
      if(res.statusCode == HttpStatus.ok){
        var map = Map<String,dynamic>.from(json.decode(res.body));
        userProfile = UserProfile.fromJson(map["data"]);
      }
    }catch(ex){
      LoggerUtil.log(ex.toString());
    }
  }
  Future<void> _getRating() async{
    int diem = 0;
    var url = Uri.http(AppConfig.instance.values.apiUrl,"/api/order/get-list-order-rating-by-staff",
        {
          'user_id':args["id"].toString()
        });
    try{
      var res = await http.get(url);
      if(res.statusCode == HttpStatus.ok){
        var map = Map<String,dynamic>.from(json.decode(res.body));
        lstOrder = List<OrderDetailModel>.from(map["data"].map((model)=>OrderDetailModel.fromJson(model)));
        dem = 0;
        lstOrder?.forEach((element) {
          diem = diem + int.parse(element.rate!);
          dem =dem+1;
        });
        print("lstOrder");
        print(lstOrder);
        if(dem > 0){
          rating = diem/dem;
        }else{
          rating = 0;
        }
      }
    }catch(ex){
      LoggerUtil.log(ex.toString());
    }
  }
}
