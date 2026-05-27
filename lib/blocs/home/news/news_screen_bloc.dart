import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/home/news/news_screen_event.dart';
import 'package:socbay/blocs/home/news/news_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/blog_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/utils/auth_http.dart' as http;

class NewsScreenBloc extends Bloc<NewsScreenEvent, NewsScreenState> {
  NewsScreenBloc({required this.apiRepository})
    : super(NewsScreenInitialState()) {
    on<NewsScreenGetNewsEvent>(_mapGetNewsEventToState);
  }

  final ApiRepository apiRepository;

  List<BlogModel> blogs = [];
  bool isLoading = false;
  int page = 1;
  int total = 1;

  FutureOr<void> _mapGetNewsEventToState(
    NewsScreenGetNewsEvent event,
    Emitter<NewsScreenState> emit,
  ) async {
    try {
      isLoading = true;
      emit(NewsScreenInitialState());

      var url = AppConfig.instance.apiUri(ApiEndpoints.blogs, {'page': '0'});
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        if (event.isRefresh) {
          blogs.clear();
          page = 0;
        }
        page = page + page * 20;
        blogs = List<BlogModel>.from(
          l["data"].map((model) => BlogModel.fromJson(model)),
        );
      }
      // final res = await apiRepository.getBlogs(page: event.isRefresh ? 1 : page);
      // if (res.data != null && res.status == HttpStatus.ok) {
      //   if (event.isRefresh) {
      //     blogs.clear();
      //     page = 1;
      //   }
      //   //total = res.total;
      //   page++;
      //   blogs.addAll(res.data!);
      // } else {}
      isLoading = false;
      emit(NewsScreenInitialState());
    } catch (ex) {
      LoggerUtil.error("---GET BLOGS LIST ERROR--- \n$ex");
    }
  }

  bool isHasMore() => blogs.length < total;
}
