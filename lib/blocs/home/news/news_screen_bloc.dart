import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/home/news/news_screen_event.dart';
import 'package:socbay/blocs/home/news/news_screen_state.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
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
  int lastPage = 1;

  FutureOr<void> _mapGetNewsEventToState(
    NewsScreenGetNewsEvent event,
    Emitter<NewsScreenState> emit,
  ) async {
    try {
      isLoading = true;
      emit(NewsScreenInitialState());

      if (event.isRefresh) {
        blogs.clear();
        page = 1;
        total = 1;
        lastPage = 1;
      }

      final url = Uri.parse(
        ApiEndpoints.geyserBlogs,
      ).replace(queryParameters: {'page': page.toString()});
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(
          json.decode(utf8.decode(res.bodyBytes)),
        );
        final data = Map<String, dynamic>.from(l["data"]);
        total = _toInt(data["total"]) ?? total;
        final currentPage = _toInt(data["current_page"]) ?? page;
        lastPage = _toInt(data["last_page"]) ?? lastPage;
        blogs.addAll(
          List<BlogModel>.from(
            data["data"].map((model) => BlogModel.fromJson(model)),
          ),
        );
        page = currentPage + 1;
      }
      isLoading = false;
      emit(NewsScreenInitialState());
    } catch (ex) {
      LoggerUtil.error("---GET BLOGS LIST ERROR--- \n$ex");
      isLoading = false;
      emit(NewsScreenInitialState());
    }
  }

  bool isHasMore() => page <= lastPage && blogs.length < total;

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? "");
  }
}
