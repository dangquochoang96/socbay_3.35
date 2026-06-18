import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/user_info/account_info/account_info_event.dart';
import 'package:socbay/blocs/user_info/account_info/account_info_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/request/user_info_request.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import 'package:path/path.dart';
import 'package:socbay/db/database.dart';
import 'package:socbay/db/entity/users.dart';
import 'package:socbay/db/object_mapper/object_mapper.dart';
import 'package:socbay/utils/logger_util.dart';

class AccountInfoBloc extends Bloc<AccountInfoEvent, AccountInfoState> {
  AccountInfoBloc({required this.apiRepository})
    : super(AccountInfoInitialState()) {
    on<AccountInfoInitEvent>(_mapGetInfoState);
    on<AccountInfoUpdateUserEvent>(_mapUpdateUserEventToState);
    on<UploadImageEvent>(_mapUploadImageEventToState);
  }

  final ApiRepository apiRepository;
  bool isLoading = false;
  UserProfile? user;
  String path = "";

  FutureOr<void> _mapGetInfoState(
    AccountInfoInitEvent event,
    Emitter<AccountInfoState> emit,
  ) async {
    isLoading = true;
    if (App.instance.userApp == null) {
      final database = await $FloorAppDatabase
          .databaseBuilder('socbay.db')
          .build();
      List<User> usrs = await database.userDao.findAllUsers();
      await database.close();
      var usr = usrs.first;
      final userprofileGetMapper = UserToUserProfile();
      App.instance.userApp = userprofileGetMapper(usr);
      user = App.instance.userApp;
    } else {
      user = App.instance.userApp;
    }
    isLoading = false;
    emit(AccountInfoGetDetailState());
  }

  FutureOr<void> _mapUpdateUserEventToState(
    AccountInfoUpdateUserEvent event,
    Emitter<AccountInfoState> emit,
  ) async {
    isLoading = true;
    emit(AccountInfoInitialState());
    AppDatabase? database;

    try {
      UserInfoRequest userInfoRequest = event.userInfoRequest;
      userInfoRequest.avatar = event.userInfoRequest.avatar;
      database = await $FloorAppDatabase
          .databaseBuilder('socbay.db')
          .build();
      final resUpdateUserInfo = await apiRepository.updateUserInfo(
        userInfoRequest,
      );
      if (resUpdateUserInfo.data != null && resUpdateUserInfo.status == 1) {
        user = resUpdateUserInfo.data;
        if ((user?.id ?? 0) > 0) {
          final userGetMapper = UserProfileToUser();
          final usr = userGetMapper(user!);
          await database.userDao.deleteAllUser();
          await database.userDao.insertUser(usr);
        }
        App.instance.userApp = user;
        emit(const AccountInfoUpdateDoneState(isSuccess: true));
      } else {
        emit(
          AccountInfoUpdateDoneState(
            isSuccess: false,
            error: resUpdateUserInfo.message ?? 'Xáº£y ra lá»—i',
          ),
        );
      }
    } catch (ex) {
      LoggerUtil.log(jsonEncode(ex));
    } finally {
      await database?.close();
      isLoading = false;
    }
  }

  Future<void> _mapUploadImageEventToState(
    UploadImageEvent event,
    Emitter<AccountInfoState> emit,
  ) async {
    isLoading = true;
    try {
      emit(AccountInfoInitialState());
      var uri = AppConfig.instance.apiSecureUri(ApiEndpoints.orderUploadImage);
      var request = http.MultipartRequest('POST', uri);
      var file = event.files;
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          file.readAsBytesSync(),
          filename: basename(file.path),
        ),
      );
      // add file to multipart
      var resStream = await request.send();
      var response = await http.Response.fromStream(resStream);
      if (response.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(response.body));
        if (l["data"]["image_link"] != "") {
          path = l["data"]["image_link"];
        }
      }

      if (path.isNotEmpty) {
        emit(UploadImageSuccessState(path));
      } else {
        emit(const UploadImageFailedState('Error'));
      }
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
    }
    isLoading = false;
    emit(AccountInfoInitialState());
  }
}
